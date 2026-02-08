# External skill source mappings (flake inputs -> source paths)
{ inputs, agentSkills ? import ./agent-skills.nix }:
let
  sources = agentSkills.inputs;
  openaiSkillsBase = "${inputs.openai-skills}/${sources.openai-skills.baseDir}";
  vercelSkillsBase = "${inputs.vercel-agent-skills}/${sources.vercel-agent-skills.baseDir}";
  agentBrowserBase = "${inputs.vercel-agent-browser}/${sources.vercel-agent-browser.baseDir}";
  uiUxProMaxBase = "${inputs.ui-ux-pro-max}/${sources.ui-ux-pro-max.baseDir}";
in
{
  openai-curated.path = "${openaiSkillsBase}/.curated";
  openai-system.path = "${openaiSkillsBase}/.system";
  vercel.path = vercelSkillsBase;
  agent-browser.path = "${agentBrowserBase}/agent-browser";
  # Use repo root so symlink targets under src/ are included in Nix store.
  ui-ux-pro-max.path = uiUxProMaxBase;
}
