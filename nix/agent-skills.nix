# Agent skills sources + selection
let
  inputs = {
    # Agent-skills external sources (flake = false: raw git repos)
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
      baseDir = "skills";
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
      selection.enable = [
        "web-design-guidelines"
      ];
    };
    vercel-agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
      baseDir = "skills";
      selection.enable = [
        "agent-browser"
      ];
    };
    ui-ux-pro-max = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
      baseDir = ".";
      selection.enable = [
        "ui-ux-pro-max"
      ];
    };
  };

  selection = {
    enable =
      builtins.concatLists (builtins.map
        (source: source.selection.enable or [])
        (builtins.attrValues inputs));
  };
in
{
  inherit inputs selection;
}
