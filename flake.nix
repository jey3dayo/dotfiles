{
  description = "Dotfiles - Unified configuration management with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      # Import helper modules
      mkDotfilesModule = import ./nix/dotfiles-module.nix;
    in
    {
      # HM module (usable by external flakes)
      homeManagerModules.default = mkDotfilesModule;

      # HM configuration: `home-manager switch --flake ~/src/github.com/jey3dayo/dotfiles --impure`
      # --impure required: builtins.getEnv for $USER/$HOME, builtins.currentSystem for pkgs
      homeConfigurations.${builtins.getEnv "USER"} =
        let
          username = builtins.getEnv "USER";
          homeDirectory = builtins.getEnv "HOME";
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
          modules = [
            self.homeManagerModules.default
            ./home.nix
          ];
          extraSpecialArgs = { inherit inputs username homeDirectory; };
        };
    };
}
