# Agent skills sources + selection
{
  inputs = {
    # Agent-skills external sources (flake = false: raw git repos)
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
    };
    vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };
    vercel-agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };
    ui-ux-pro-max = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
    };
  };

  selection = {
    # Enabled skill IDs (shared between home.nix and `nix run .#install`)
    # If `enable` is omitted or null, all discovered skills are enabled.
    enable = [
      "agent-browser"
      "gh-address-comments"
      "gh-fix-ci"
      "skill-creator"
      "ui-ux-pro-max"
      "web-design-guidelines"
    ];
  };
}
