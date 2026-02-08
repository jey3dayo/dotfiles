{
  description = "Dotfiles - Unified configuration management with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Agent-skills external sources (flake = false: raw git repos)
    # NOTE: These must be manually kept in sync with nix/agent-skills-sources.nix
    #       Flake spec requires literal inputs - dynamic generation not allowed
    #       agent-skills-sources.nix remains the SSoT for baseDir and selection metadata
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
      flake-utils,
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
          # Agent-skills module is bundled in this repo
          agentSkillsPath = ./agents/nix/module.nix;
          agentSkillsModule =
            if builtins.pathExists agentSkillsPath
            then import agentSkillsPath
            else { config, ... }: { };

          # Base modules that always exist
          baseModules = [
            self.homeManagerModules.default  # dotfiles module
            ./home.nix
          ];

          # Add agent-skills module if it exists in repo
          allModules =
            if builtins.pathExists agentSkillsPath
            then baseModules ++ [ agentSkillsModule ]
            else baseModules;
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
          modules = allModules;
          extraSpecialArgs = { inherit inputs username homeDirectory; };
        };
    }
    // flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        targets = import ./nix/targets.nix;
        agentLib = import ./agents/nix/lib.nix { inherit pkgs; nixlib = nixpkgs.lib; };
        agentSkills = import ./nix/agent-skills.nix;
        sources = import ./nix/sources.nix { inherit inputs agentSkills; };
        selection = agentSkills.selection;
        catalog = agentLib.discoverCatalog {
          inherit sources;
          localPath = ./agents/skills-internal;
        };
        enableConfig = if selection ? enable then selection.enable else null;
        localSkillIds = nixpkgs.lib.attrNames
          (nixpkgs.lib.filterAttrs (_: skill: skill.source == "local") catalog);
        enableList =
          if enableConfig == null then
            nixpkgs.lib.attrNames catalog
          else
            nixpkgs.lib.unique (enableConfig ++ localSkillIds);
        selectedSkills =
          if enableConfig == null then
            catalog
          else
            agentLib.selectSkills {
              inherit catalog;
              enable = enableList;
            };
        bundle = agentLib.mkBundle {
          skills = selectedSkills;
          name = "agent-skills-bundle";
        };
      in
      {
        packages.default = bundle;
        packages.bundle = bundle;

        apps = {
          install = {
            type = "app";
            program =
              let
                targetsList = nixpkgs.lib.mapAttrsToList
                  (tool: t: { inherit tool; inherit (t) dest; })
                  (nixpkgs.lib.filterAttrs (_: t: t.enable) targets);
              in
              "${agentLib.mkSyncScript { inherit bundle; targets = targetsList; }}/bin/skills-install";
          };
          list = {
            type = "app";
            program = "${agentLib.mkListScript { inherit catalog selectedSkills; }}/bin/skills-list";
          };
          validate = {
            type = "app";
            program = "${agentLib.mkValidateScript { inherit catalog selectedSkills bundle; }}/bin/skills-validate";
          };
        };

        checks.default = agentLib.mkChecks { inherit bundle catalog selectedSkills; };

        devShells.default = pkgs.mkShell {
          buildInputs = [ home-manager.packages.${system}.default ];
          shellHook = ''
            echo "Agent Skills Dev Shell"
            echo "  home-manager switch --flake . --impure  # Apply skills"
            echo "  nix run .#list                          # List skills"
          '';
        };

        formatter = pkgs.nixfmt;
      }
    );
}
