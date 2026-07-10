# Home Manager configuration for dotfiles
#
# NOTE: dotfiles 配布・launchd agents・headroom venv 構築は mise bootstrap へ移管済み。
# 定義: mise/config.default.toml の [dotfiles] / [bootstrap.*] / [tasks.bootstrap]
{
  username,
  homeDirectory,
  ...
}:

{
  # Basic home-manager settings
  home = {
    inherit username homeDirectory;

    # This value determines the Home Manager release that your configuration is compatible with.
    # You should not change this value, even if you update Home Manager.
    stateVersion = "24.11";
  };

  # Tools are installed via mise; Home Manager focuses on config distribution.

  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    # dotfiles 配布は mise bootstrap へ移管済み（mise/config.default.toml [dotfiles]）
    dotfiles = {
      enable = true;
      repoPath = ../..; # dotfiles repository root
      repoWorktreePath = null; # Auto-detect from repoPath or fallback paths
      environment = null; # Auto-detect (override with "ci"/"pi"/"default")

      deployEntryPoints = false;
      deploySsh = false;
      deployBash = false;
      deployAwsume = false;
      deployMacosServices = false;
      initSubmodules = false;
    };

  };
}
