# Agent skills source definitions (single source of truth)
{
  # Agent-skills external sources (flake = false: raw git repos)
  benjitaylor-agentation = {
    url = "github:benjitaylor/agentation";
    flake = false;
    baseDir = ".";
    catalogs = {
      benjitaylor-agentation = "skills";
    };
    selection.enable = [
      "agentation"
      "agentation-self-driving"
    ];
  };
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
  millionco-react-doctor = {
    url = "github:millionco/react-doctor";
    flake = false;
    baseDir = ".";
    catalogs = {
      millionco-react-doctor = "skills";
    };
    selection.enable = [
      "react-doctor"
    ];
  };
  tokoroten-prompt-review = {
    url = "github:tokoroten/prompt-review";
    flake = false;
    baseDir = ".";
    catalogs = {
      tokoroten-prompt-review = ".claude/skills";
    };
    selection.enable = [
      "prompt-review"
    ];
  };
  nyosegawa-skills = {
    url = "github:nyosegawa/skills";
    flake = false;
    baseDir = ".";
    catalogs = {
      nyosegawa-skills = "skills";
    };
    selection.enable = [
      "skill-auditor"
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
  sawyerhood-dev-browser = {
    url = "github:SawyerHood/dev-browser";
    flake = false;
    baseDir = ".";
    catalogs = {
      sawyerhood-dev-browser = "skills";
    };
    selection.enable = [
      "dev-browser"
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
  anthropics-claude-code = {
    url = "github:anthropics/claude-code";
    flake = false;
    baseDir = ".";
    catalogs = {
      anthropics-claude-code = "plugins/frontend-design/skills";
    };
    selection.enable = [
      "frontend-design"
    ];
  };
  trailofbits-agentic-actions-auditor = {
    url = "github:trailofbits/skills";
    flake = false;
    baseDir = ".";
    catalogs = {
      trailofbits-agentic-actions-auditor = "plugins/agentic-actions-auditor/skills";
    };
    selection.enable = [
      "agentic-actions-auditor"
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
  trailofbits-supply-chain-risk-auditor = {
    url = "github:trailofbits/skills";
    flake = false;
    baseDir = ".";
    catalogs = {
      trailofbits-supply-chain-risk-auditor = "plugins/supply-chain-risk-auditor/skills";
    };
    selection.enable = [
      "supply-chain-risk-auditor"
    ];
  };
  epicenterhq-epicenter = {
    url = "github:EpicenterHQ/epicenter";
    flake = false;
    baseDir = ".";
    catalogs = {
      epicenterhq-epicenter = ".agents/skills";
    };
    selection.enable = [
      "tauri"
    ];
  };
}
