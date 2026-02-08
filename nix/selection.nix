# Enabled skill IDs (shared between home.nix and `nix run .#install`)
# If `enable` is omitted or null, all discovered skills are enabled.
{
  enable = [
    "agent-browser"
    "gh-address-comments"
    "gh-fix-ci"
    "skill-creator"
    "ui-ux-pro-max"
    "web-design-guidelines"
  ];
}
