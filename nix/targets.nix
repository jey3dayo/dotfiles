# Deployment targets for skill distribution
# Fields: enable (bool), dest (string), structure? ("link"|"copy-tree", default "link"),
#         configDest? (string|null, default null) — destination for configFiles
{
  claude   = { enable = true; dest = ".claude/skills"; configDest = ".claude"; };
  codex    = { enable = true; dest = ".codex/skills";  configDest = ".codex"; };
  cursor   = { enable = true; dest = ".cursor/skills"; configDest = ".cursor"; };
  opencode = { enable = true; dest = ".opencode/skills"; configDest = ".opencode"; };
  openclaw = { enable = true; dest = ".openclaw/skills"; configDest = ".openclaw"; };
  shared   = { enable = true; dest = ".skills"; };
}
