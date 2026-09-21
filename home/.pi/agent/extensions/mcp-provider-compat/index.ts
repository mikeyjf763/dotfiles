import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

function stripUnsupportedRegexPatterns(value: unknown): number {
  if (!value || typeof value !== "object") return 0;

  let removed = 0;
  const record = value as Record<string, unknown>;
  if (typeof record.pattern === "string" && /\(\?[=!<]/.test(record.pattern)) {
    delete record.pattern;
    removed += 1;
  }

  for (const child of Object.values(record)) {
    removed += stripUnsupportedRegexPatterns(child);
  }
  return removed;
}

export default function mcpProviderCompat(pi: ExtensionAPI) {
  pi.on("before_provider_request", (event, ctx) => {
    // GitHub Copilot's OpenAI-compatible Responses endpoint rejects JSON
    // schemas containing lookahead/lookbehind regexes. MCP servers still
    // validate their own inputs, so removing only those provider-side hints
    // preserves runtime validation while allowing the tool catalog through.
    if (ctx.model?.provider !== "github-copilot") return;
    stripUnsupportedRegexPatterns(event.payload);
  });
}
