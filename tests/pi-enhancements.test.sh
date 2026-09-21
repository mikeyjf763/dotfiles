#!/usr/bin/env bash
# Static wiring checks for the repository-authored Pi enhancements.
set -u

# shellcheck source=tests/lib.sh
. "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

SETTINGS="$ROOT/home/.pi/agent/settings.json"
EXTENSIONS="$ROOT/home/.pi/agent/extensions"

settings_json=$(cat "$SETTINGS")

node - "$ROOT/home/.pi/agent/mcp.json" <<'NODE'
const fs = require("node:fs");
const config = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const server = config.mcpServers?.["inspire-mcp"];
if (server?.command !== "bun") throw new Error("inspire-mcp command is not Bun");
if (server?.cwd !== "${HOME}/dev/inspire-cli") throw new Error("inspire-mcp cwd is not portable");
if (server?.args?.join(" ") !== "run bin/elliot.ts inspire-mcp") throw new Error("inspire-mcp auth wrapper is not configured");
NODE

node - "$SETTINGS" <<'NODE' || fail "Pi settings are not valid JSON or are missing required package pins"
const fs = require("node:fs");
const settings = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const packages = settings.packages ?? [];
const sources = packages.map((entry) => typeof entry === "string" ? entry : entry.source);
const required = [
  "npm:pi-herdr-subagents@0.2.0",
  "npm:pi-ask-user@0.14.0",
  "npm:pi-lean-portal@0.4.0",
  "npm:pi-web-access@0.27.0",
];
for (const source of required) {
  if (!sources.includes(source)) throw new Error(`missing package pin: ${source}`);
}
if (settings.toolsetDefaults?.["toolset-state:pi-lean-dimension.web"]?.enabled !== false) {
  throw new Error("browser tools are not disabled by default");
}
if (settings.browser?.defaultProfile !== "session") {
  throw new Error("browser default profile is not session-scoped");
}
if (sources.includes("npm:pi-observational-memory-extension@0.2.1")) {
  throw new Error("observational memory package is still enabled");
}
NODE

for path in \
  "$EXTENSIONS/ask-user-policy/index.ts" \
  "$EXTENSIONS/rose-pine-ui/index.ts" \
  "$EXTENSIONS/web-access-policy/index.ts" \
  "$EXTENSIONS/mcp-provider-compat/index.ts"
do
  [ -f "$path" ] || fail "missing Pi extension: $path"
done

assert_contains "$settings_json" '"toolset-state:pi-lean-dimension.web-learn"' \
  "browser guide-authoring tools are not disabled by default"
assert_not_contains "$settings_json" "pi-observational-memory-extension" \
  "observational memory package is still present"
assert_not_contains "$(cat "$EXTENSIONS/rose-pine-ui/index.ts")" "/om" \
  "Rose Pine UI still advertises observational memory"
assert_contains "$settings_json" '"!extensions/subagent/**"' \
  "pi-code's duplicate subagent extension is not excluded"
assert_contains "$settings_json" '"!extensions/question.ts"' \
  "pi-code's duplicate question extension is not excluded"
assert_contains "$(cat "$EXTENSIONS/ask-user-policy/index.ts")" "MAX_AGENT_OPTIONS = 4" \
  "ask-user policy does not reserve four agent choices"
assert_contains "$(cat "$EXTENSIONS/ask-user-policy/index.ts")" "input.allowFreeform = true" \
  "ask-user policy does not force the Other/freeform choice"
rose_pine_ui=$(cat "$EXTENSIONS/rose-pine-ui/index.ts")
assert_contains "$rose_pine_ui" "PI WORKSPACE" \
  "Rose Pine startup logo is missing"
assert_contains "$rose_pine_ui" "working" \
  "Rose Pine UI working state is missing"
assert_not_contains "$rose_pine_ui" "setInterval" \
  "Rose Pine UI redraw timer can cause terminal flicker"
assert_contains "$(cat "$EXTENSIONS/web-access-policy/index.ts")" "delete input.queries" \
  "web-search compatibility normalization is missing"
assert_contains "$(cat "$EXTENSIONS/mcp-provider-compat/index.ts")" "stripUnsupportedRegexPatterns" \
  "MCP provider schema compatibility is missing"
assert_contains "$(cat "$ROOT/home.nix")" 'home.file.".pi/agent/mcp.json".source' \
  "Home Manager does not link the MCP configuration"

pass "Pi package pins, browser default, ask-user policy, Rose Pine UI, and web compatibility are wired"
