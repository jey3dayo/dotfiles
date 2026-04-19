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
    anthropics-claude-code = {
      url = "github:anthropics/claude-code";
      flake = false;
    };
    benjitaylor-agentation = {
      url = "github:benjitaylor/agentation";
      flake = false;
    };
    epicenterhq-epicenter = {
      url = "github:EpicenterHQ/epicenter";
      flake = false;
    };
    heyvhuang-ship-faster = {
      url = "github:Heyvhuang/ship-faster";
      flake = false;
    };
    lum1104-understand-anything = {
      url = "github:Lum1104/Understand-Anything";
      flake = false;
    };
    millionco-react-doctor = {
      url = "github:millionco/react-doctor";
      flake = false;
    };
    mizchi-chezmoi-dotfiles = {
      url = "github:mizchi/chezmoi-dotfiles";
      flake = false;
    };
    nyosegawa-skills = {
      url = "github:nyosegawa/skills";
      flake = false;
    };
    obra-superpowers = {
      url = "github:obra/superpowers";
      flake = false;
    };
    openai-codex-plugin-cc = {
      url = "github:openai/codex-plugin-cc";
      flake = false;
    };
    openai-skills = {
      url = "github:openai/skills";
      flake = false;
    };
    tokoroten-prompt-review = {
      url = "github:tokoroten/prompt-review";
      flake = false;
    };
    trailofbits-agentic-actions-auditor = {
      url = "github:trailofbits/skills";
      flake = false;
    };
    trailofbits-audit-context-building = {
      url = "github:trailofbits/skills";
      flake = false;
    };
    trailofbits-sharp-edges = {
      url = "github:trailofbits/skills";
      flake = false;
    };
    trailofbits-static-analysis = {
      url = "github:trailofbits/skills";
      flake = false;
    };
    trailofbits-supply-chain-risk-auditor = {
      url = "github:trailofbits/skills";
      flake = false;
    };
    ui-ux-pro-max = {
      url = "github:nextlevelbuilder/ui-ux-pro-max-skill";
      flake = false;
    };
    vercel-agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };
    vercel-agent-skills = {
      url = "github:vercel-labs/agent-skills";
      flake = false;
    };
    # END Agent-skills external sources
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

      # HM configuration: `home-manager switch --flake "$HOME/.config" --impure`
      # --impure required: builtins.getEnv for $USER/$HOME, builtins.currentSystem for pkgs
      homeConfigurations.${builtins.getEnv "USER"} =
        let
          username = builtins.getEnv "USER";
          homeDirectory = builtins.getEnv "HOME";
          # Base modules that always exist
          baseModules = [
            self.homeManagerModules.default # dotfiles module
            ./home.nix
          ];
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
          modules = baseModules;
          extraSpecialArgs = { inherit inputs username homeDirectory; };
        };
    }
    //
      flake-utils.lib.eachSystem
        [
          "x86_64-linux"
          "aarch64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ]
        (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            mkLegacyRemovedApp = name: message: {
              type = "app";
              program = "${pkgs.writeShellScriptBin name ''
                echo "${message}" >&2
                exit 1
              ''}/bin/${name}";
            };
          in
          {
            packages.default = pkgs.writeTextFile {
              name = "legacy-agent-skills-removed";
              text = "Legacy Nix agent distribution has been removed. Use ~/.apm/catalog instead.\n";
              destination = "/README.txt";
            };
            packages.bundle = self.packages.${system}.default;

            apps = {
              install = mkLegacyRemovedApp "skills-install" "Legacy Nix agent distribution has been removed. Use ~/.apm/catalog and APM tasks instead.";
              list = mkLegacyRemovedApp "skills-list" "Legacy Nix agent distribution has been removed. Use `cd ~/.apm && mise run list` instead.";
              report = mkLegacyRemovedApp "skills-report" "Legacy Nix agent distribution has been removed. Use the ~/.apm workspace instead.";
              validate = mkLegacyRemovedApp "skills-validate" "Legacy Nix agent distribution has been removed. Use `cd ~/.apm && mise run validate-catalog` instead.";
            };

            checks = {
              default = pkgs.runCommand "legacy-agent-skills-removed-check" { } ''
                mkdir -p "$out"
              '';
              nullSelection = pkgs.runCommand "legacy-agent-skills-removed-null-check" { } ''
                mkdir -p "$out"
              '';
            };

            devShells.default = pkgs.mkShell {
              buildInputs = [ home-manager.packages.${system}.default ];
              shellHook = ''
                echo "Dotfiles Dev Shell"
                echo "  home-manager switch --flake . --impure"
                echo "  cd ~/.apm && mise run doctor"
              '';
            };

            formatter = pkgs.nixfmt;
          }
        );
}
