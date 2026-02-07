{
  description = "Dotfiles with Home Manager for mise configuration";

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
    }:
    {
      # Home Manager module (usable by external flakes)
      homeManagerModules.default = import ./nix/mise-module.nix;

      # Home Manager configuration: `home-manager switch --flake ~/src/github.com/jey3dayo/dotfiles --impure`
      # --impure required: builtins.getEnv for environment detection
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
          extraSpecialArgs = {
            inherit
              username
              homeDirectory
              ;
          };
        };
    };
}
