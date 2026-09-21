#!/usr/bin/env bash
# Static wiring checks for reusable Pi workflows and role agents.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

WORKFLOW_EXT="$ROOT/home/.pi/agent/extensions/workflows/index.ts"
WORKFLOW_PROMPT="$ROOT/home/.pi/agent/workflows/ticket-implementation.md"
WORKFLOW_CONFIG="$ROOT/home/.pi/agent/workflows/config.json"
AGENTS_DIR="$ROOT/home/.pi/agent/agents"

node - "$WORKFLOW_CONFIG" <<'NODE' || fail "workflow config is not valid JSON"
const fs = require("node:fs");
const config = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
if (config.defaultModel !== "github-copilot/gpt-5.6-luna") throw new Error("unexpected workflow default model");
if (config.workflows?.["ticket-implementation"]?.prompt !== "ticket-implementation.md") {
  throw new Error("ticket-implementation workflow is not registered");
}
for (const role of [
  "ticket-refiner",
  "code-scout",
  "edge-case-detector",
  "test-strategy-scout",
  "test-implementor",
  "technical-planner",
  "implementer",
]) {
  if (!(role in config.roles)) throw new Error(`missing role config: ${role}`);
}
NODE

[ -f "$WORKFLOW_EXT" ] || fail "workflow extension is missing"
[ -f "$WORKFLOW_PROMPT" ] || fail "ticket workflow prompt is missing"
[ -d "$AGENTS_DIR" ] || fail "global workflow agent directory is missing"

for role in ticket-refiner code-scout edge-case-detector test-strategy-scout test-implementor technical-planner implementer; do
  [ -f "$AGENTS_DIR/$role.md" ] || fail "missing role agent: $role"
  grep -q "name: $role" "$AGENTS_DIR/$role.md" || fail "$role frontmatter name is missing"
  grep -q "spawning: false" "$AGENTS_DIR/$role.md" || fail "$role can unexpectedly spawn children"
done

workflow_source=$(cat "$WORKFLOW_EXT")
prompt_source=$(cat "$WORKFLOW_PROMPT")
assert_contains "$workflow_source" 'name: "workflow_state"' "workflow state tool is missing"
assert_contains "$workflow_source" 'getArgumentCompletions' "workflow command does not offer autocomplete"
assert_contains "$workflow_source" 'workflowDefinitions(loadConfig())' "workflow autocomplete is not registry-driven"
assert_contains "$workflow_source" 'action === "lock-tests"' "test-lock state transition is missing"
assert_contains "$workflow_source" 'PI_SUBAGENT_AGENT' "role-aware protected test guard is missing"
assert_contains "$workflow_source" 'agent === "test-implementor" && !state.testsLocked' "test implementor can bypass the locked test contract"
assert_contains "$prompt_source" "ask_user" "workflow does not stop at an approval gate"
assert_not_contains "$prompt_source" "lavish" "workflow still depends on Lavish"
assert_contains "$prompt_source" "workflow_state" "workflow does not record stage state"
assert_contains "$prompt_source" "test-implementor" "workflow does not use the protected test role"
assert_contains "$prompt_source" "technical-planner" "workflow does not use the technical planning role"
assert_contains "$prompt_source" "implementer" "workflow does not use the implementation role"
assert_contains "$(cat "$ROOT/home.nix")" 'home.file.".pi/agent/agents".source' "Home Manager does not link workflow agents"
assert_contains "$(cat "$ROOT/home.nix")" 'home.file.".pi/agent/workflows".source' "Home Manager does not link workflow definitions"
assert_contains "$(cat "$ROOT/.gitignore")" '/home/.pi/agent/workflow-runs/' "workflow runtime state is not ignored"

pass "workflow runtime, stage roles, model config, protected test guard, approval gates, and Home Manager links are wired"
