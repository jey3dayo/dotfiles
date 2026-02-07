# User Home Manager configuration for dotfiles
{ username, homeDirectory, ... }:

{
  programs.mise-config = {
    enable = true;
    configDir = ./mise;
    environment = null; # 自動検出
    installTasks = true;
  };

  # Home Manager basics (username/homeDirectory provided via extraSpecialArgs)
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "24.11";

  # Avoid profile conflicts when home-manager is already installed elsewhere.
  programs.home-manager.enable = false;
}
