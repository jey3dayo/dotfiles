# Home Manager configuration for dotfiles
{ config, pkgs, inputs, username, homeDirectory, ... }:

{
  # Basic home-manager settings
  home.username = username;
  home.homeDirectory = homeDirectory;

  # Fundamental packages (if needed)
  home.packages = with pkgs; [
    rsync  # Required for copy-tree deployment
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Enable dotfiles module
  programs.dotfiles = {
    enable = true;
    repoPath = ./.;  # dotfiles repository root
    repoWorktreePath = null;  # Auto-detect from repoPath or fallback paths
    environment = null;  # Auto-detect (override with "ci"/"pi"/"wsl2"/"macos"/"default")

    # Deployment options (Phase 2: enable file deployment)
    deployEntryPoints = true;   # Deploy ~/.gitconfig, ~/.zshenv, etc.
    deployXdgConfig = true;     # Deploy ~/.config/{zsh,nvim,git,tmux,mise,etc.}
    deploySsh = true;           # Deploy ~/.ssh/config
    deployBash = true;          # Deploy ~/.bashrc, ~/.bash_profile
    deployAwsume = true;        # Deploy ~/.awsume/config.yaml
    initSubmodules = true;      # Initialize Git submodules (tmux plugins)
  };

  # Enable agent-skills module (from ~/.agents)
  # Configuration mirrors ~/.agents/home.nix for compatibility
  programs.agent-skills = {
    enable = true;

    # Local skills directory from ~/.agents
    # Note: Cannot use dynamic path in pure Nix evaluation
    # For local skills, use ~/.agents flake directly or add as flake input
    localSkillsPath = null;

    # External skill sources (using inputs from flake.nix)
    sources = {
      openai-curated.path = "${inputs.openai-skills}/skills/.curated";
      openai-system.path = "${inputs.openai-skills}/skills/.system";
      vercel.path = "${inputs.vercel-agent-skills}/skills";
      agent-browser.path = "${inputs.vercel-agent-browser}/skills/agent-browser";
      ui-ux-pro-max.path = "${inputs.ui-ux-pro-max}";
    };

    # Skill selection (null = all discovered skills)
    skills.enable = null;

    # Deployment targets (claude, codex, cursor, opencode, openclaw, shared)
    targets = {
      claude   = { enable = true; dest = ".claude/skills"; configDest = ".claude"; };
      codex    = { enable = true; dest = ".codex/skills";  configDest = ".codex"; };
      cursor   = { enable = true; dest = ".cursor/skills"; configDest = ".cursor"; };
      opencode = { enable = true; dest = ".opencode/skills"; configDest = ".opencode"; };
      openclaw = { enable = true; dest = ".openclaw/skills"; configDest = ".openclaw"; };
      shared   = { enable = true; dest = ".skills"; };
    };

    # Config files distribution
    configFiles = [
      {
        src = "${homeDirectory}/.agents/AGENTS.md";
        default = "AGENTS.md";
        rename = { claude = "CLAUDE.md"; };
      }
    ];
  };

  # This value determines the Home Manager release that your configuration is compatible with.
  # You should not change this value, even if you update Home Manager.
  home.stateVersion = "24.11";
}
