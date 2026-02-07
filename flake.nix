{
  description = "Dotfiles - Unified configuration management with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agent-skills external sources (flake = false: raw git repos)
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
    };
    vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };
    vercel-agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };
    ui-ux-pro-max = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      gitignore,
      ...
    }@inputs:
    let
      # Import helper modules
      mkDotfilesModule = import ./nix/dotfiles-module.nix { inherit gitignore; };
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
          # Import agent-skills module directly using HOME environment variable
          # This requires --impure flag when running home-manager switch
          agentSkillsModule = import "${homeDirectory}/.agents/nix/module.nix";
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
          modules = [
            self.homeManagerModules.default  # dotfiles module
            agentSkillsModule                # agent-skills module (direct import)
            ./home.nix
          ];
          extraSpecialArgs = { inherit inputs username homeDirectory; };
        };
    };
}
