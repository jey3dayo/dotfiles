# Centralized dotfiles sync targets (home.file mappings)
# Paths on left are destination paths relative to $HOME (or XDG config home for xdg.*).
{
  entryPointFiles = {
    ".aicommits" = ".aicommits";
    ".gitconfig" = "home/.gitconfig";
    ".tmux.conf" = "home/.tmux.conf";
    ".zshenv" = "home/.zshenv";
    ".zshrc" = "home/.zshrc";
  };

  bashFiles = {
    ".bashrc" = "bash/.bashrc";
    ".bash_profile" = "bash/.bash_profile";
  };

  xdg = {
    # Directories synced as a whole under ~/.config
    dirs = [
      # Core tools (already managed)
      "git"
      # mise: excluded - writable trust DB required (managed individually below)
      "nvim"
      # tmux: excluded - submodule plugins/ require real directory (managed via activation script)
      "zsh"

      # Terminal emulators
      "alacritty"
      "wezterm"

      # Shell enhancements
      "zsh-abbr"

      # Editors and IDEs
      "cursor"
      "ghostty"

      # Development tools
      "helm"
      "efm-langserver"
      "needle"
      "opencode"

      # System monitoring
      "btop"
      "htop"

      # Misc tools
      "flipper"
      "scripts"
      "yamllint"
    ];

    # Individual files under ~/.config
    files = [
      ".agignore"
      ".asdfrc"
      ".busted"
      ".clang-format"
      ".colordiffrc"
      ".ctags"
      ".cvimrc"
      ".editorconfig"
      ".env"                # dotenvx暗号化済み
      ".fdignore"
      ".gvimrc"
      ".ignore"
      ".luacheckrc"
      ".luarc.json"
      ".markdown-link-check.json"
      ".markdownlint-cli2.jsonc"
      ".marksman.toml"
      ".mise.toml"
      ".prettierignore"
      ".rainbarf.conf"
      ".ripgreprc"
      ".rubocop.yml"
      ".screenrc"
      ".styluaignore"
      ".surfingkeys.js"
      ".vimperatorrc"
      "Brewfile"
      "typos.toml"
      # mise static configs (dynamic files like trusted-configs/ need writable directory)
      "mise/config.toml"
      "mise/config.default.toml"
      "mise/config.pi.toml"
      "mise/config.ci.toml"
      "mise/README.md"
      # gh static config (hosts.yml is dynamic and user-managed)
      "gh/config.yml"
      # tmux static config files (plugins/ managed via activation script)
      "tmux/copy-paste.conf"
      "tmux/default.session.conf"
      "tmux/keyconfig.conf"
      "tmux/options.conf"
      "tmux/tmux.conf"
      "tmux/tpm.conf"
    ];
  };

  sshFiles = {
    ".ssh/config" = "ssh/config";
  };

  awsumeFiles = {
    ".awsume/config.yaml" = "awsume/config.yaml";
  };
}
