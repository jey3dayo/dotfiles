# External skill source mappings (flake inputs -> source paths)
{ inputs }:
{
  openai-curated.path = "${inputs.openai-skills}/skills/.curated";
  openai-system.path = "${inputs.openai-skills}/skills/.system";
  vercel.path = "${inputs.vercel-agent-skills}/skills";
  agent-browser.path = "${inputs.vercel-agent-browser}/skills/agent-browser";
  # Use repo root so symlink targets under src/ are included in Nix store.
  ui-ux-pro-max.path = "${inputs.ui-ux-pro-max}";
}
