import { createHash, randomUUID } from "node:crypto";
import { dirname, isAbsolute, join, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";
import { mkdir, readFile, readFileSync, rename, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import type { AutocompleteItem } from "@earendil-works/pi-tui";
import { Type } from "typebox";

const EXTENSION_DIR = dirname(fileURLToPath(import.meta.url));
const DEFAULT_AGENT_DIR = join(homedir(), ".pi", "agent");
const AGENT_DIR = process.env.PI_CODING_AGENT_DIR ?? DEFAULT_AGENT_DIR;
const LINKED_WORKFLOW_DIR = join(AGENT_DIR, "workflows");
const WORKFLOW_DIR = existsSync(join(LINKED_WORKFLOW_DIR, "config.json"))
  ? LINKED_WORKFLOW_DIR
  : join(EXTENSION_DIR, "../../workflows");
const CONFIG_PATH = join(WORKFLOW_DIR, "config.json");

type WorkflowDefinition = {
  prompt: string;
  description?: string;
};

type WorkflowConfig = {
  defaultModel: string;
  defaultThinking: string;
  roles: Record<string, { model?: string; thinking?: string }>;
  workflows: Record<string, WorkflowDefinition>;
};

type WorkflowState = {
  runId: string;
  workflow: string;
  cwd: string;
  runDir: string;
  stage: string;
  status: "running" | "waiting" | "completed" | "failed";
  testsLocked: boolean;
  protectedPaths: string[];
  runnerCommand?: string;
  testChecksum?: string;
  updatedAt: string;
  note?: string;
};

function workflowDefinitions(config: WorkflowConfig): Array<[string, WorkflowDefinition]> {
  return Object.entries(config.workflows).filter(([name, definition]) =>
    name.length > 0 && !!definition && typeof definition.prompt === "string" && definition.prompt.length > 0,
  );
}

function workflowPromptPath(definition: WorkflowDefinition): string {
  const root = resolve(WORKFLOW_DIR);
  const path = resolve(root, definition.prompt);
  if (!path.startsWith(`${root}/`)) {
    throw new Error("Workflow prompt must stay inside the workflow definitions directory");
  }
  return path;
}

function runtimeRoot(): string {
  return join(process.env.PI_CODING_AGENT_DIR ?? DEFAULT_AGENT_DIR, "workflow-runs");
}

function activeStatePath(): string {
  return join(runtimeRoot(), "active.json");
}

function loadConfig(): WorkflowConfig {
  const fallback: WorkflowConfig = {
    defaultModel: "github-copilot/gpt-5.6-luna",
    defaultThinking: "high",
    roles: {},
    workflows: {
      "ticket-implementation": {
        prompt: "ticket-implementation.md",
        description: "Refine, test, plan, and implement a ticket with human gates",
      },
    },
  };

  try {
    const parsed = JSON.parse(readFileSync(CONFIG_PATH, "utf8")) as Partial<WorkflowConfig>;
    return {
      defaultModel: parsed.defaultModel || fallback.defaultModel,
      defaultThinking: parsed.defaultThinking || fallback.defaultThinking,
      roles: parsed.roles ?? fallback.roles,
      workflows: parsed.workflows ?? fallback.workflows,
    };
  } catch {
    return fallback;
  }
}

function roleModels(config: WorkflowConfig): Record<string, { model: string; thinking: string }> {
  const roleNames = [
    "ticket-refiner",
    "code-scout",
    "edge-case-detector",
    "test-strategy-scout",
    "test-implementor",
    "technical-planner",
    "implementer",
  ];
  return Object.fromEntries(roleNames.map((role) => [
    role,
    {
      model: config.roles[role]?.model ?? config.defaultModel,
      thinking: config.roles[role]?.thinking ?? config.defaultThinking,
    },
  ]));
}

async function writeJsonAtomic(path: string, value: unknown): Promise<void> {
  await mkdir(dirname(path), { recursive: true, mode: 0o700 });
  const tempPath = `${path}.${process.pid}.${randomUUID()}.tmp`;
  await writeFile(tempPath, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600 });
  await rename(tempPath, path);
}

async function readState(): Promise<WorkflowState | undefined> {
  try {
    return JSON.parse(await readFile(activeStatePath(), "utf8")) as WorkflowState;
  } catch {
    return undefined;
  }
}

async function saveState(state: WorkflowState): Promise<void> {
  state.updatedAt = new Date().toISOString();
  await writeJsonAtomic(join(state.runDir, "state.json"), state);
  await writeJsonAtomic(activeStatePath(), state);
}

function normalizePath(value: string, cwd: string): string {
  const absolute = isAbsolute(value) ? resolve(value) : resolve(cwd, value);
  return relative(cwd, absolute).replaceAll("\\", "/");
}

function pathMatchesProtected(value: string, state: WorkflowState): boolean {
  const normalized = value.replaceAll("\\", "/");
  return state.protectedPaths.some((protectedPath) => {
    const candidate = protectedPath.replaceAll("\\", "/").replace(/^\.\//, "");
    return normalized.includes(candidate) || normalized.includes(`./${candidate}`);
  });
}

function serializedInput(input: unknown): string {
  try {
    return JSON.stringify(input);
  } catch {
    return String(input);
  }
}

function isTestTool(toolName: string): boolean {
  return ["read", "write", "edit", "grep", "find", "ls", "bash"].includes(toolName);
}

async function checksumFiles(paths: string[], cwd: string): Promise<string> {
  const hash = createHash("sha256");
  for (const path of [...paths].sort()) {
    const absolute = isAbsolute(path) ? path : resolve(cwd, path);
    const contents = await readFile(absolute);
    hash.update(path.replaceAll("\\", "/"));
    hash.update("\0");
    hash.update(contents);
    hash.update("\0");
  }
  return hash.digest("hex");
}

function textResult(text: string, details: Record<string, unknown> = {}) {
  return { content: [{ type: "text" as const, text }], details };
}

async function currentStateFor(runId: string): Promise<WorkflowState> {
  const state = await readState();
  if (!state) throw new Error("No active workflow run exists");
  if (state.runId !== runId) throw new Error(`Workflow run ${runId} is not active`);
  return state;
}

function commandHasProtectedPath(command: string, state: WorkflowState): boolean {
  return state.protectedPaths.some((path) => {
    const normalized = path.replaceAll("\\", "/");
    return command.includes(normalized) || command.includes(`./${normalized}`);
  });
}

export default function workflows(pi: ExtensionAPI) {
  pi.on("tool_call", async (event) => {
    if (!isTestTool(event.toolName)) return;

    const state = await readState();
    if (!state?.testsLocked || state.status === "completed") return;

    const agent = process.env.PI_SUBAGENT_AGENT ?? "parent";
    if (agent === "test-implementor" && !state.testsLocked) return;
    if (agent === "technical-planner" && ["read", "grep", "find", "ls"].includes(event.toolName)) return;

    const rawInput = serializedInput(event.input);
    const command = event.toolName === "bash"
      ? String((event.input as { command?: unknown }).command ?? "")
      : "";

    if (!pathMatchesProtected(rawInput, state) && !commandHasProtectedPath(command, state)) return;

    if (event.toolName === "bash" && state.runnerCommand && command.trim() === state.runnerCommand.trim()) return;

    return {
      block: true,
      reason: `Protected test contract: ${agent} cannot inspect or modify approved test files. Run the approved test command or ask the workflow conductor to route a test correction through test-implementor.`,
    };
  });

  pi.registerTool({
    name: "workflow_state",
    label: "Workflow State",
    description: "Record workflow stage progress, lock or unlock the approved test contract, and mark a run complete or failed.",
    promptSnippet: "record workflow stage, gate, test-lock, or completion state",
    parameters: Type.Object({
      action: Type.String({ description: "One of stage, lock-tests, unlock-tests, complete, or fail" }),
      runId: Type.String({ description: "Active workflow run id" }),
      stage: Type.Optional(Type.String({ description: "Current stage name" })),
      protectedPaths: Type.Optional(Type.Array(Type.String(), { description: "Approved test paths, relative to the repository" })),
      runnerCommand: Type.Optional(Type.String({ description: "The exact command used to run the approved tests" })),
      note: Type.Optional(Type.String({ description: "Short state or gate note" })),
    }),
    async execute(_toolCallId, params) {
      const input = params as {
        action: string;
        runId: string;
        stage?: string;
        protectedPaths?: string[];
        runnerCommand?: string;
        note?: string;
      };
      const state = await currentStateFor(input.runId);
      const action = input.action.trim().toLowerCase();
      const agent = process.env.PI_SUBAGENT_AGENT ?? "parent";

      if (["lock-tests", "unlock-tests"].includes(action) && agent !== "parent") {
        return textResult("Only the workflow conductor can change the protected test lock.", { error: "unauthorized_state_change" });
      }

      if (input.stage) state.stage = input.stage;
      if (input.note) state.note = input.note;

      if (action === "stage") {
        state.status = "running";
      } else if (action === "lock-tests") {
        const paths = (input.protectedPaths ?? []).map((path) => normalizePath(path, state.cwd));
        if (paths.length === 0) return textResult("Cannot lock an empty test contract.", { error: "missing_protected_paths" });
        if (!input.runnerCommand?.trim()) return textResult("Cannot lock tests without an exact runner command.", { error: "missing_runner_command" });
        try {
          state.testChecksum = await checksumFiles(paths, state.cwd);
        } catch (error) {
          const reason = error instanceof Error ? error.message : String(error);
          return textResult(`Cannot checksum protected tests: ${reason}`, { error: "checksum_failed" });
        }
        state.protectedPaths = paths;
        state.runnerCommand = input.runnerCommand.trim();
        state.testsLocked = true;
        state.status = "running";
      } else if (action === "unlock-tests") {
        state.testsLocked = false;
        state.status = "running";
      } else if (action === "complete") {
        if (state.testsLocked && state.testChecksum) {
          try {
            const currentChecksum = await checksumFiles(state.protectedPaths, state.cwd);
            if (currentChecksum !== state.testChecksum) {
              return textResult("Cannot complete workflow: protected test contract drifted.", {
                error: "test_contract_drift",
                expectedChecksum: state.testChecksum,
                actualChecksum: currentChecksum,
              });
            }
          } catch (error) {
            const reason = error instanceof Error ? error.message : String(error);
            return textResult(`Cannot complete workflow: protected tests could not be verified: ${reason}`, {
              error: "checksum_failed",
            });
          }
        }
        state.status = "completed";
      } else if (action === "fail") {
        state.status = "failed";
      } else {
        return textResult(`Unknown workflow state action: ${input.action}`, { error: "unknown_action" });
      }

      await saveState(state);
      return textResult(`Workflow ${state.runId}: ${action} (${state.stage})`, {
        runId: state.runId,
        stage: state.stage,
        status: state.status,
        testsLocked: state.testsLocked,
        testChecksum: state.testChecksum,
      });
    },
  });

  pi.registerTool({
    name: "workflow_status",
    label: "Workflow Status",
    description: "Show the active reusable workflow run and protected test contract status.",
    promptSnippet: "inspect active workflow stage and test lock",
    parameters: Type.Object({}),
    async execute() {
      const state = await readState();
      if (!state) return textResult("No active workflow run.", { active: false });
      return textResult(JSON.stringify(state, null, 2), { active: true, runId: state.runId });
    },
  });

  pi.registerCommand("workflow", {
    description: "Start a reusable workflow and autocomplete available workflow definitions",
    getArgumentCompletions: (prefix: string): AutocompleteItem[] | null => {
      if (prefix.includes(" ")) return null;
      const normalizedPrefix = prefix.trim().toLowerCase();
      const items = workflowDefinitions(loadConfig()).map(([name, definition]) => ({
        value: name,
        label: name,
        description: definition.description,
      }));
      const filtered = items.filter((item) => item.value.toLowerCase().startsWith(normalizedPrefix));
      return filtered.length > 0 ? filtered : null;
    },
    handler: async (args, ctx) => {
      const [workflowName, ...inlineTicketParts] = args.trim().split(/\s+/).filter(Boolean);
      const config = loadConfig();
      const definition = workflowName ? config.workflows[workflowName] : undefined;
      if (!workflowName) {
        ctx.ui.notify("Usage: /workflow <workflow-name>", "warning");
        return;
      }
      if (!definition) {
        const available = workflowDefinitions(config).map(([name]) => name).join(", ") || "none";
        ctx.ui.notify(`Unknown workflow: ${workflowName}. Available: ${available}`, "error");
        return;
      }

      let ticket = inlineTicketParts.join(" ").trim();
      if (!ticket) {
        if (!ctx.hasUI) {
          ctx.ui.notify("Paste the ticket after the command in non-interactive mode.", "error");
          return;
        }
        ticket = (await ctx.ui.editor("Paste ticket", "")).trim();
      }
      if (!ticket) {
        ctx.ui.notify("Workflow cancelled: no ticket was provided.", "warning");
        return;
      }

      const runId = `${new Date().toISOString().replace(/[-:.TZ]/g, "").slice(0, 14)}-${randomUUID().slice(0, 8)}`;
      const runDir = join(runtimeRoot(), runId);
      await mkdir(runDir, { recursive: true, mode: 0o700 });
      await writeFile(join(runDir, "ticket.md"), `${ticket}\n`, { mode: 0o600 });

      const state: WorkflowState = {
        runId,
        workflow: workflowName,
        cwd: ctx.cwd,
        runDir,
        stage: "ticket-refiner",
        status: "running",
        testsLocked: false,
        protectedPaths: [],
        updatedAt: new Date().toISOString(),
      };
      await saveState(state);

      const promptTemplate = await readFile(workflowPromptPath(definition), "utf8");
      const prompt = promptTemplate
        .replaceAll("{{RUN_ID}}", runId)
        .replaceAll("{{RUN_DIR}}", runDir)
        .replaceAll("{{CWD}}", ctx.cwd)
        .replaceAll("{{TICKET}}", ticket)
        .replaceAll("{{MODELS_JSON}}", JSON.stringify(roleModels(loadConfig()), null, 2));

      ctx.ui.notify(`Started ticket-implementation workflow ${runId}`, "info");
      pi.sendUserMessage(prompt);
    },
  });

  pi.registerCommand("workflow-status", {
    description: "Show the active reusable workflow status",
    handler: async (_args, ctx) => {
      const state = await readState();
      if (!state) {
        ctx.ui.notify("No active workflow run.", "info");
        return;
      }
      ctx.ui.notify(
        `${state.workflow} ${state.runId}\nStage: ${state.stage}\nStatus: ${state.status}\nTests locked: ${state.testsLocked ? "yes" : "no"}`,
        "info",
      );
    },
  });
}
