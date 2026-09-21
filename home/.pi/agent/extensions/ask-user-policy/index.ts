import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const MAX_AGENT_OPTIONS = 4;

export default function askUserPolicy(pi: ExtensionAPI) {
  pi.on("before_agent_start", (event) => ({
    systemPrompt: `${event.systemPrompt}

Ask-user policy: When asking the user to choose among alternatives, use ask_user. Provide no more than four agent-authored options because the fifth row is reserved for the always-available freeform "Other" choice. Keep questions focused and use single-select unless multiple selection is genuinely required. Never assume a decision when the user can answer through the Other field.`,
  }));

  pi.on("tool_call", (event) => {
    if (event.toolName !== "ask_user") return;

    const input = event.input as {
      options?: unknown;
      allowFreeform?: boolean;
      allowMultiple?: boolean;
    };

    if (Array.isArray(input.options)) {
      input.options = input.options.slice(0, MAX_AGENT_OPTIONS);
    }

    // pi-ask-user renders this as the final "Type something" / Other row.
    input.allowFreeform = true;
    input.allowMultiple = false;
  });
}
