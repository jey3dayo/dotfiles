# External skill source mappings (flake inputs -> source paths)
{ inputs }:
let
  openaiSkillsBase = "${inputs.openai-skills}/skills";
  vercelSkillsBase = "${inputs.vercel-agent-skills}/skills";
  agentBrowserBase = "${inputs.vercel-agent-browser}/skills";
  uiUxProMaxBase = "${inputs.ui-ux-pro-max}";
in
{
  openai-curated.path = "${openaiSkillsBase}/.curated";
  openai-system.path = "${openaiSkillsBase}/.system";
  vercel.path = vercelSkillsBase;
  agent-browser.path = "${agentBrowserBase}/agent-browser";
  # Use repo root so symlink targets under src/ are included in Nix store.
  ui-ux-pro-max.path = uiUxProMaxBase;
}
