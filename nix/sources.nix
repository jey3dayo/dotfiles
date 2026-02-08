# External skill source mappings (flake inputs -> source paths)
{ inputs, agentSkills ? import ./agent-skills.nix }:
let
  baseDirs = agentSkills.baseDirs;
  openaiSkillsBase = "${inputs.openai-skills}/${baseDirs.openai-skills}";
  vercelSkillsBase = "${inputs.vercel-agent-skills}/${baseDirs.vercel-agent-skills}";
  agentBrowserBase = "${inputs.vercel-agent-browser}/${baseDirs.vercel-agent-browser}";
  uiUxProMaxBase = "${inputs.ui-ux-pro-max}/${baseDirs.ui-ux-pro-max}";
in
{
  openai-curated.path = "${openaiSkillsBase}/.curated";
  openai-system.path = "${openaiSkillsBase}/.system";
  vercel.path = vercelSkillsBase;
  agent-browser.path = "${agentBrowserBase}/agent-browser";
  # Use repo root so symlink targets under src/ are included in Nix store.
  ui-ux-pro-max.path = uiUxProMaxBase;
}
