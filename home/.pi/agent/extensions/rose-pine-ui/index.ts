import type { ExtensionAPI, ExtensionContext, Theme } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

type Styled = (text: string) => string;

function formatCwd(cwd: string): string {
  const home = process.env.HOME;
  if (home && cwd.startsWith(home)) return `~${cwd.slice(home.length)}`;
  return cwd;
}

function formatContext(ctx: ExtensionContext): string {
  const usage = ctx.getContextUsage();
  const contextWindow = usage?.contextWindow ?? ctx.model?.contextWindow;
  if (!usage || usage.percent === null || !contextWindow) return "ctx ?";
  return `ctx ${Math.round(usage.percent)}%/${Math.round(contextWindow / 1000)}k`;
}

function fitLine(left: string, right: string, width: number, border: Styled): string {
  if (width <= 0) return "";
  if (width === 1) return border("│");

  const innerWidth = width - 2;
  let leftText = left;
  let rightText = right;
  const gap = 1;

  while (visibleWidth(leftText) + visibleWidth(rightText) + gap > innerWidth && visibleWidth(rightText) > 0) {
    rightText = truncateToWidth(rightText, Math.max(0, visibleWidth(rightText) - 1), "");
  }
  while (visibleWidth(leftText) + visibleWidth(rightText) + gap > innerWidth && visibleWidth(leftText) > 0) {
    leftText = truncateToWidth(leftText, Math.max(0, visibleWidth(leftText) - 1), "");
  }

  const padding = " ".repeat(Math.max(0, innerWidth - visibleWidth(leftText) - visibleWidth(rightText)));
  return border("│") + leftText + padding + rightText + border("│");
}

function renderLogo(theme: Theme, width: number): string[] {
  const accent = (text: string) => theme.fg("accent", text);
  const muted = (text: string) => theme.fg("muted", text);
  const dim = (text: string) => theme.fg("dim", text);
  const border = (text: string) => theme.fg("border", text);
  const inner = Math.max(0, width - 2);
  const title = ` ${accent("π")} ${theme.bold("PI WORKSPACE")} `;
  const top = border(`╭${"─".repeat(Math.max(0, inner - visibleWidth(title) - 1))}`) + title + border("─╮");
  const bottom = border(`╰${"─".repeat(inner)}╯`);
  const subtitle = `${accent("◆")} ${muted("coding with intention")} ${dim("·")} ${dim("Herdr-ready")}`;

  return [
    truncateToWidth(top, width, ""),
    fitLine(subtitle, accent("● online"), width, border),
    truncateToWidth(bottom, width, ""),
  ];
}

export default function rosePineUi(pi: ExtensionAPI) {
  let activeTui: { requestRender(): void } | undefined;
  let isWorking = false;
  let gitBranch = "";

  const requestRender = () => activeTui?.requestRender();

  pi.on("session_start", (_event, ctx) => {
    gitBranch = "";
    void pi.exec("git", ["branch", "--show-current"], { cwd: ctx.cwd }).then((result) => {
      gitBranch = result.stdout.trim();
      requestRender();
    }).catch(() => {});
    if (ctx.mode !== "tui") return;

    ctx.ui.setHeader((tui, theme) => {
      activeTui = tui;
      return {
        render(width: number): string[] {
          const logo = renderLogo(theme, width);
          const model = ctx.model ? `${ctx.model.provider}/${ctx.model.id}` : "no model";
          const status = isWorking ? `${theme.fg("accent", "●")} working` : `${theme.fg("success", "✓")} ready`;
          const border = (text: string) => theme.fg("border", text);
          const details = fitLine(
            `${theme.fg("muted", formatCwd(ctx.cwd))}`,
            `${theme.fg("dim", model)}`,
            width,
            border,
          );
          const state = fitLine(
            `${theme.fg("dim", pi.getSessionName?.() || "new session")}`,
            `${theme.fg("muted", status)}`,
            width,
            border,
          );
          return [...logo, details, state, ""];
        },
        invalidate() {},
      };
    });

    ctx.ui.setFooter((tui, theme) => {
      activeTui = tui;
      return {
        render(width: number): string[] {
          const branch = gitBranch ? theme.fg("muted", gitBranch) : theme.fg("dim", "no branch");
          const left = `${theme.fg("accent", "π")} ${formatContext(ctx)} ${theme.fg("dim", "·")} ${branch}`;
          const right = `${theme.fg("dim", "ask-user · /web")}`;
          return [fitLine(left, right, width, (text) => theme.fg("border", text))];
        },
        invalidate() {},
      };
    });

    requestRender();
  });

  pi.on("agent_start", () => {
    isWorking = true;
    requestRender();
  });

  pi.on("agent_settled", () => {
    isWorking = false;
    requestRender();
  });

  pi.on("session_shutdown", () => {
    activeTui = undefined;
  });
}
