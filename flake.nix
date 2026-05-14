{
  description = "Dotfiles - Unified configuration management with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
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

      # macOS system configuration: `sudo darwin-rebuild switch --flake "$HOME/.config#CA-20031129"`
      darwinConfigurations.CA-20031129 = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [
          {
            # Keep Nix itself managed by the existing installer/profile setup.
            nix.enable = false;

            # This flake only owns the PAM change; keep the existing system bashrc untouched.
            programs.bash.enable = false;

            # Enable Touch ID for sudo, including tmux/screen sessions via pam_reattach.
            security.pam.services.sudo_local = {
              touchIdAuth = true;
              reattach = true;
            };

            environment.etc."pam.d/sudo_local".knownSha256Hashes = [
              # macOS default sudo_local template with Touch ID commented out.
              "6bcbb9339dbc848d7af6a2b69bf798d12e3184152d9b314828f71477a0660387"
            ];

            # Required by nix-darwin for backwards compatibility.
            system.stateVersion = 6;

            nixpkgs.hostPlatform = "aarch64-darwin";
          }
        ];
        specialArgs = { inherit inputs; };
      };

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
              list = mkLegacyRemovedApp "skills-list" "Legacy Nix agent distribution has been removed. Use the ~/.apm workspace instead.";
              report = mkLegacyRemovedApp "skills-report" "Legacy Nix agent distribution has been removed. Use the ~/.apm workspace instead.";
              validate = mkLegacyRemovedApp "skills-validate" "Legacy Nix agent distribution has been removed. Use `cd ~/.apm && mise run validate:catalog` instead.";
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
                echo "  cd ~/.apm && mise run deploy"
              '';
            };

            formatter = pkgs.nixfmt;
          }
        );
}
