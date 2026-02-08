# Agent skills source definitions (single source of truth)
{
  # Agent-skills external sources (flake = false: raw git repos)
  openai-skills = {
    url = "github:openai/skills";
    flake = false;
    baseDir = "skills";
    # Catalog definitions: catalog-name → subdirectory path from baseDir
    catalogs = {
      openai-curated = ".curated";
      openai-system = ".system";
    };
    selection.enable = [
      "gh-address-comments"
      "gh-fix-ci"
      "skill-creator"
    ];
  };
  vercel-agent-skills = {
    url = "github:vercel-labs/agent-skills";
    flake = false;
    baseDir = "skills";
    catalogs = {
      vercel = "."; # baseDir直下
    };
    selection.enable = [
      "web-design-guidelines"
    ];
  };
  vercel-agent-browser = {
    url = "github:vercel-labs/agent-browser";
    flake = false;
    baseDir = "skills";
    catalogs = {
      agent-browser = "agent-browser";
    };
    selection.enable = [
      "agent-browser"
    ];
  };
  ui-ux-pro-max = {
    url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
    flake = false;
    baseDir = ".";
    catalogs = {
      ui-ux-pro-max = "."; # baseDir直下
    };
    selection.enable = [
      "ui-ux-pro-max"
    ];
  };
}
