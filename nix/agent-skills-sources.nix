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
      "composition-patterns"
      "react-best-practices"
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
  heyvhuang-ship-faster = {
    url = "github:Heyvhuang/ship-faster";
    flake = false;
    baseDir = "skills";
    catalogs = {
      heyvhuang-ship-faster = ".";
    };
    selection.enable = [
      "cloudflare"
      "tool-openclaw"
    ];
  };
  obra-superpowers = {
    url = "github:obra/superpowers";
    flake = false;
    baseDir = ".";
    idPrefix = "superpowers:";
    assets = {
      agents = "agents";
    };
    catalogs = {
      superpowers = "skills";
    };
    selection.enable = [
      "superpowers:brainstorming"
      "superpowers:dispatching-parallel-agents"
      "superpowers:executing-plans"
      "superpowers:finishing-a-development-branch"
      "superpowers:receiving-code-review"
      "superpowers:requesting-code-review"
      "superpowers:subagent-driven-development"
      "superpowers:systematic-debugging"
      "superpowers:test-driven-development"
      "superpowers:using-git-worktrees"
      "superpowers:using-superpowers"
      "superpowers:verification-before-completion"
      "superpowers:writing-plans"
      "superpowers:writing-skills"
    ];
  };
  openai-codex-plugin-cc = {
    url = "github:openai/codex-plugin-cc";
    flake = false;
    baseDir = ".";
    assets = {
      agents = "plugins/codex/agents";
      commands = "plugins/codex/commands";
    };
    catalogs = {
      openai-codex-plugin-cc = "plugins/codex/skills";
    };
    selection.enable = [
      "codex-cli-runtime"
      "codex-result-handling"
      "gpt-5-4-prompting"
    ];
  };
  lum1104-understand-anything = {
    url = "github:Lum1104/Understand-Anything";
    flake = false;
    baseDir = ".";
    homeLinks = {
      ".understand-anything-plugin" = "understand-anything-plugin";
    };
    catalogs = {
      lum1104-understand-anything = "understand-anything-plugin/skills";
    };
    selection.enable = [
      "understand"
      "understand-chat"
      "understand-dashboard"
      "understand-diff"
      "understand-explain"
      "understand-onboard"
    ];
  };
  trailofbits-audit-context-building = {
    url = "github:trailofbits/skills";
    flake = false;
    baseDir = ".";
    assets = {
      agents = "plugins/audit-context-building/agents";
      commands = "plugins/audit-context-building/commands";
    };
    catalogs = {
      trailofbits-audit-context-building = "plugins/audit-context-building/skills";
    };
    selection.enable = [
      "audit-context-building"
    ];
  };
  trailofbits-sharp-edges = {
    url = "github:trailofbits/skills";
    flake = false;
    baseDir = ".";
    catalogs = {
      trailofbits-sharp-edges = "plugins/sharp-edges/skills";
    };
    selection.enable = [
      "sharp-edges"
    ];
  };
  trailofbits-static-analysis = {
    url = "github:trailofbits/skills";
    flake = false;
    baseDir = ".";
    assets = {
      agents = "plugins/static-analysis/agents";
    };
    catalogs = {
      trailofbits-static-analysis = "plugins/static-analysis/skills";
    };
    selection.enable = [
      "codeql"
      "sarif-parsing"
      "semgrep"
    ];
  };
}
