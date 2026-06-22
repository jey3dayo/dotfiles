# Nix Dotfiles Structure Adoption Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adopt the useful structural ideas from `nakasyou/dotfiles` while preserving this repository's Home Manager focused behavior.

**Architecture:** Keep the existing `programs.dotfiles` Home Manager module intact. Introduce small host/user entrypoint files and flake helper functions so `flake.nix` becomes an assembly layer instead of carrying host-specific details directly. Avoid importing unrelated overlays, packages, or personal application config from the reference repository.

**Tech Stack:** Nix flakes, Home Manager, nix-darwin, mise task runner, nixfmt.

## Global Constraints

- Preserve the existing `home-manager switch --flake ~/.config --impure` workflow.
- Preserve the existing Darwin target name `CA-20031129`.
- Keep `programs.dotfiles` behavior unchanged unless a task explicitly says otherwise.
- Do not hardcode the current username into Home Manager; continue using `builtins.getEnv "USER"` and `builtins.getEnv "HOME"`.
- Do not add third-party overlays or custom packages from `nakasyou/dotfiles`.
- Dependency channel alignment is out of scope for this execution because it changes the package universe.
- Execute tasks sequentially; do not run task implementation in parallel because Tasks 1-3 share dependent files.

---

## Reference Findings

- `nakasyou/dotfiles` keeps top-level host entrypoints under `hosts/`, with `hosts/mac-mini/default.nix` and `hosts/p14s/default.nix`.
- Its `flake.nix` uses small constructors like `mkNixosHost` and `mkDarwinHost` before declaring `nixosConfigurations.p14s` and `darwinConfigurations.mac-mini`.
- Its reusable system modules live under `modules/darwin` and `modules/nixos`.
- Its Home Manager user config lives under `users/nakasyou/home.nix`.
- This repo currently has `flake.nix`, `home.nix`, and `nix/darwin.nix` as the main Nix entrypoints, plus reusable dotfiles logic in `nix/dotfiles-module.nix`, `nix/dotfiles-files.nix`, and `nix/env-detect.nix`.

## Files

- Modify: `flake.nix`
  - Add `mkHomeConfiguration` and `mkDarwinHost` helpers.
  - Point Home Manager to `./users/current/home.nix`.
  - Point Darwin to `./hosts/CA-20031129/default.nix`.
- Create: `users/current/home.nix`
  - Move the existing Home Manager config from `home.nix` here without behavior changes.
- Modify: `home.nix`
  - Keep as a compatibility shim importing `./users/current/home.nix`.
- Create: `hosts/CA-20031129/default.nix`
  - Move or wrap the existing Darwin host config.
- Modify: `nix/darwin.nix`
  - Keep as a compatibility shim importing `../hosts/CA-20031129/default.nix`.
- Create: `modules/darwin/touch-id-sudo.nix`
  - Extract only the Touch ID sudo/PAM settings from the current Darwin config.
- Inspect: `docs/tools/home-manager.md` and `docs/tools/nix.md`
  - Only modify if they point directly at old Nix file paths.

## Command Preflight

- [x] **Step 1: Resolve mise or choose fallback commands**

  Run:

  ```powershell
  Get-Command mise -ErrorAction SilentlyContinue
  mise which mise
  ```

  Expected: at least one command identifies a usable `mise`. If neither works, use direct Nix commands where possible:

  ```powershell
  nix fmt . -- --check
  home-manager build --flake . --impure
  nix build --no-link --impure .#darwinConfigurations.CA-20031129.system
  nix flake show --impure
  ```

- [x] **Step 2: Use PowerShell environment variables for scoped file checks**

  Use this shape for mise tasks that consume file lists:

  ```powershell
  $env:NIX_FILES = "flake.nix home.nix nix/darwin.nix users/current/home.nix hosts/CA-20031129/default.nix"
  rtk mise run format:nix
  ```

## Task 1: Add Host and User Entrypoints Without Behavior Changes

**Files:**

- Create: `users/current/home.nix`
- Modify: `home.nix`
- Create: `hosts/CA-20031129/default.nix`
- Modify: `nix/darwin.nix`

**Interfaces:**

- Consumes: Current `home.nix` module arguments: `{ pkgs, username, homeDirectory, ... }`.
- Produces: `users/current/home.nix` with the same module interface.
- Consumes: Current `nix/darwin.nix` module arguments: `{ inputs, ... }`.
- Produces: `hosts/CA-20031129/default.nix` with the same module interface.

- [x] **Step 1: Copy current Home Manager config into the new user entrypoint**

  Copy the full current body of `home.nix` into `users/current/home.nix` unchanged.

- [x] **Step 2: Replace `home.nix` with a compatibility shim**

  ```nix
  import ./users/current/home.nix
  ```

- [x] **Step 3: Copy current Darwin config into the new host entrypoint**

  Copy the full current body of `nix/darwin.nix` into `hosts/CA-20031129/default.nix` unchanged.

- [x] **Step 4: Replace `nix/darwin.nix` with a compatibility shim**

  ```nix
  import ../hosts/CA-20031129/default.nix
  ```

- [ ] **Step 5: Format the touched Nix files**

  Run:

  ```powershell
  $env:NIX_FILES = "flake.nix home.nix nix/darwin.nix users/current/home.nix hosts/CA-20031129/default.nix"
  rtk mise run format:nix
  ```

  Expected: command succeeds with no formatting errors.

- [ ] **Step 6: Validate behavior is unchanged**

  Run:

  ```powershell
  rtk mise run hm:check
  rtk mise run nix:build:darwin-system
  ```

  Expected: both commands succeed.

## Task 2: Refactor `flake.nix` Into Small Constructors

**Files:**

- Modify: `flake.nix`

**Interfaces:**

- Produces: `mkHomeConfiguration = { username, homeDirectory, system }: home-manager.lib.homeManagerConfiguration { ... }`.
- Produces: `mkDarwinHost = { hostname, system, modules }: nix-darwin.lib.darwinSystem { ... }`.
- Preserves: `homeConfigurations.${builtins.getEnv "USER"}`.
- Preserves: `darwinConfigurations.CA-20031129`.

- [x] **Step 1: Add local variables for current user and system**

  Add in the existing `let` block:

  ```nix
  currentUsername = builtins.getEnv "USER";
  currentHomeDirectory = builtins.getEnv "HOME";
  currentSystem = builtins.currentSystem;
  ```

- [x] **Step 2: Add `mkHomeConfiguration`**

  The helper should contain the existing `home-manager.lib.homeManagerConfiguration` call and keep these modules:

  ```nix
  [
    self.homeManagerModules.default
    ./users/current/home.nix
  ]
  ```

- [x] **Step 3: Add `mkDarwinHost`**

  The helper should wrap `nix-darwin.lib.darwinSystem` and pass:

  ```nix
  specialArgs = {
    inherit inputs hostname;
  };
  ```

- [x] **Step 4: Rewrite outputs to use helpers**

  Keep the public attribute names stable:

  ```nix
  homeConfigurations.${currentUsername} = mkHomeConfiguration {
    username = currentUsername;
    homeDirectory = currentHomeDirectory;
    system = currentSystem;
  };

  darwinConfigurations.CA-20031129 = mkDarwinHost {
    hostname = "CA-20031129";
    system = "aarch64-darwin";
    modules = [ ./hosts/CA-20031129 ];
  };
  ```

- [ ] **Step 5: Format and validate**

  Run:

  ```powershell
  $env:NIX_FILES = "flake.nix"
  rtk mise run format:nix
  rtk nix flake show --impure
  rtk mise run hm:check
  rtk mise run nix:build:darwin-system
  ```

  Expected: all commands succeed.

## Task 3: Extract Reusable Darwin Touch ID Module

**Files:**

- Create: `modules/darwin/touch-id-sudo.nix`
- Modify: `hosts/CA-20031129/default.nix`

**Interfaces:**

- Produces: Darwin module `modules/darwin/touch-id-sudo.nix`.
- Consumes: Imported by `hosts/CA-20031129/default.nix`.

- [x] **Step 1: Create `modules/darwin/touch-id-sudo.nix`**

  Extract only:

  ```nix
  {
    security.pam.services.sudo_local = {
      touchIdAuth = true;
      reattach = true;
    };

    environment.etc."pam.d/sudo_local".knownSha256Hashes = [
      "6bcbb9339dbc848d7af6a2b69bf798d12e3184152d9b314828f71477a0660387"
    ];
  }
  ```

- [x] **Step 2: Import it from the host file**

  Add to `hosts/CA-20031129/default.nix`:

  ```nix
  imports = [
    ../../modules/darwin/touch-id-sudo.nix
  ];
  ```

- [x] **Step 3: Remove the duplicated Touch ID block from the host file**

  Leave `nix.enable`, `programs.bash.enable`, `system.stateVersion`, `system.configurationRevision`, and `nixpkgs.hostPlatform` in the host file.

- [ ] **Step 4: Format and validate**

  Run:

  ```powershell
  $env:NIX_FILES = "hosts/CA-20031129/default.nix modules/darwin/touch-id-sudo.nix"
  rtk mise run format:nix
  rtk mise run nix:build:darwin-system
  ```

  Expected: Darwin system build succeeds.

## Task 4: Audit Documentation References

**Files:**

- Inspect: `docs/tools/home-manager.md`
- Inspect: `docs/tools/nix.md`

**Interfaces:**

- Produces: no changes unless docs mention `home.nix` or `nix/darwin.nix` as canonical implementation paths.

- [x] **Step 1: Search for old canonical path references**

  Run:

  ```powershell
  rtk rg "home\.nix|nix/darwin\.nix|nix\\darwin\.nix" docs/tools/home-manager.md docs/tools/nix.md
  ```

  Expected: either no direct canonical path references, or a short list that can be updated.

- [x] **Step 2: Update docs only if necessary**

  If a direct canonical path reference is found, update it to mention the new entrypoint and compatibility shim:
  - Home Manager config: `users/current/home.nix`
  - Darwin host config: `hosts/CA-20031129/default.nix`
  - Compatibility shims: `home.nix`, `nix/darwin.nix`

  Expected: no broad docs rewrite.

## Task 5: Final Quality Gate and Review

**Files:**

- Review all files changed in Tasks 1-4.

**Interfaces:**

- Produces: final implementation report.

- [ ] **Step 1: Run focused Nix checks**

  Run:

  ```powershell
  rtk mise run format:nix:check
  rtk mise run hm:check
  rtk mise run nix:build:darwin-system
  ```

  Expected: all commands succeed.

- [ ] **Step 2: Run broader check if the dependency task was included**

  Run:

  ```powershell
  rtk mise run nix:check
  ```

  Expected: command succeeds. Skip this step when only structural refactor tasks were implemented.

- [ ] **Step 3: Manually review the diff**

  Confirm:
  - `programs.dotfiles` options are unchanged.
  - Home Manager still receives `username` and `homeDirectory`.
  - `darwinConfigurations.CA-20031129` still exists.
  - Compatibility shims keep old import paths working.
  - No unrelated packages, overlays, docs rewrites, or personal settings were imported.

- [ ] **Step 4: Report residual risk**

  Mention any command that could not be run, especially if Nix or network access is unavailable.

## Explicit Non-Goals

- Do not convert this repo into a full NixOS configuration.
- Do not add Linux host definitions until there is an actual Linux target to support.
- Do not move `nix/dotfiles-module.nix`, `nix/dotfiles-files.nix`, or `nix/env-detect.nix` in this pass.
- Do not hardcode a username like the reference repo does.
- Do not copy large Home Manager package lists from `users/nakasyou/home.nix`.
- Do not add Cachix substituters from the reference repo.
- Do not update `flake.lock` or change Nix input branches in this pass.

## Execution Choice

Plan complete and saved to `docs/superpowers/plans/2026-06-20-nix-dotfiles-structure-adoption.md`.

1. Subagent-Driven (recommended) - Dispatch a fresh subagent per task sequentially and review between tasks.
2. Inline Execution - Execute tasks in this session using executing-plans with checkpoints.
