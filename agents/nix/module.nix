# Home Manager module: programs.agent-skills
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.agent-skills;
  agentLib = import ./lib.nix {
    inherit pkgs;
    nixlib = lib;
  };

  # Get distribution result for rules/agents access
  distributionResult =
    if cfg.distributionsPath != null && builtins.pathExists cfg.distributionsPath then
      agentLib.scanDistribution cfg.distributionsPath
    else
      {
        skills = { };
        config = null;
        rules = { };
        agents = { };
      };

  catalog = agentLib.discoverCatalog {
    inherit (cfg) sources distributionsPath;
    localPath = cfg.localSkillsPath;
  };

  localSkillIds = lib.attrNames (lib.filterAttrs (_: skill: skill.source == "local") catalog);
  distributionSkillIds = lib.attrNames (
    lib.filterAttrs (_: skill: skill.source == "distribution") catalog
  );
  allSkillIds = lib.attrNames catalog;
  enableList =
    if cfg.skills.enable == null then
      allSkillIds
    else
      lib.unique (cfg.skills.enable ++ localSkillIds ++ distributionSkillIds);

  selectedSkills = agentLib.selectSkills {
    inherit catalog;
    enable = enableList;
  };

  selectedSkillSources = lib.unique (map (skill: skill.source) (lib.attrValues selectedSkills));

  bundle = agentLib.mkBundle {
    skills = selectedSkills;
    name = "agent-skills-bundle";
  };

  externalAgents = agentLib.discoverExternalAssets {
    inherit (cfg) sources;
    assetType = "agents";
    enabledSources = selectedSkillSources;
  };

  # Internal bundled agents are the source of truth when external sources ship
  # the same upstream agent ID.
  mergedAgents = externalAgents // distributionResult.agents;

  externalCommands = agentLib.discoverExternalAssets {
    inherit (cfg) sources;
    assetType = "commands";
    enabledSources = selectedSkillSources;
  };

  # Helper: generate mkdir commands for asset subdirectories (rules/agents)
  mkAssetDirCommands =
    assetType: assets: targets:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (
        _name: target:
        if target.enable && (lib.attrNames assets) != [ ] then
          let
            baseDir = lib.removeSuffix "/skills" target.dest;
            parentDirs = lib.unique (
              lib.filter (d: d != "") (
                lib.map (
                  id:
                  let
                    parts = lib.splitString "/" id;
                  in
                  if lib.length parts > 1 then lib.head parts else ""
                ) (lib.attrNames assets)
              )
            );
          in
          ''
            ${pkgs.coreutils}/bin/mkdir -p "$HOME/${baseDir}/${assetType}"
            ${lib.concatMapStringsSep "\n" (dir: ''
              ${pkgs.coreutils}/bin/mkdir -p "$HOME/${baseDir}/${assetType}/${dir}"
            '') parentDirs}
          ''
        else
          ""
      ) targets
    );

  # Helper: generate home.file links for asset files (rules/agents)
  mkAssetFileLinks =
    assetType: assets: targets:
    lib.mapAttrsToList (
      _name: target:
      if target.enable && (lib.attrNames assets) != [ ] then
        let
          baseDir = lib.removeSuffix "/skills" target.dest;
          keepFile = {
            "${baseDir}/${assetType}/.keep".text = "";
          };
          assetFiles = lib.mapAttrs' (
            assetId: asset:
            lib.nameValuePair "${baseDir}/${assetType}/${assetId}.md" {
              source = asset.path;
              force = true;
            }
          ) assets;
        in
        keepFile // assetFiles
      else
        { }
    ) targets;

in
{
  options.programs.agent-skills = {
    enable = lib.mkEnableOption "AI Agent Skills management";

    sources = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.path;
              description = "Path to external skill source directory.";
            };
            idPrefix = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Optional prefix applied to discovered external skill IDs. Top-level external agent/command IDs keep their upstream names.";
            };
            agentsPath = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Optional path to top-level external agent definitions.";
            };
            commandsPath = lib.mkOption {
              type = lib.types.nullOr lib.types.path;
              default = null;
              description = "Optional path to top-level external command definitions.";
            };
          };
        }
      );
      default = { };
      description = "External skill sources (name -> { path, idPrefix?, agentsPath?, commandsPath? }).";
    };

    localSkillsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Optional legacy override path for local skills. Deprecated: use distributionsPath as single source of truth.";
    };

    distributionsPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to internal assets directory (e.g., ./agents/internal). Provides bundled skills, commands, and config.";
    };

    skills.enable = lib.mkOption {
      type = lib.types.nullOr (lib.types.listOf lib.types.str);
      default = null;
      description = "List of skill IDs to enable (null = all discovered skills; local/distribution skills are always included).";
    };

    targets = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "this deployment target";
            dest = lib.mkOption {
              type = lib.types.str;
              description = "Destination path relative to $HOME.";
            };
            structure = lib.mkOption {
              type = lib.types.enum [
                "link"
                "copy-tree"
              ];
              default = "link";
              description = "Deployment structure: link (HM symlink, read-only) or copy-tree (rsync copy, writable).";
            };
            configDest = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "Destination directory for configFiles (relative to $HOME). null = no configFiles.";
            };
          };
        }
      );
      default = { };
      description = "Deployment targets for skill distribution.";
    };

    configFiles = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            src = lib.mkOption {
              type = lib.types.path;
              description = "Source file path.";
            };
            default = lib.mkOption {
              type = lib.types.str;
              description = "Default filename for distribution.";
            };
            rename = lib.mkOption {
              type = lib.types.attrsOf lib.types.str;
              default = { };
              description = "Per-target filename overrides (e.g., { claude = \"CLAUDE.md\"; }).";
            };
            exclude = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Target names to exclude from distribution.";
            };
          };
        }
      );
      default = [ ];
      description = "Configuration files to distribute to target configDest directories.";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      # copy-tree targets: rsync-based sync (writable copy)
      activation.agent-skills = lib.hm.dag.entryAfter [ "writeBoundary" ] (
        let
          copyTargets = lib.filterAttrs (_: t: t.enable && t.structure == "copy-tree") cfg.targets;
          syncCommands = lib.mapAttrsToList (
            _name: target:
            let
              dest = "$HOME/${target.dest}";
            in
            ''
              mkdir -p "${dest}"
              ${pkgs.rsync}/bin/rsync -aL --delete --exclude='/.system' "${bundle}/" "${dest}/"
              chmod -R u+w "${dest}"
            ''
          ) copyTargets;
        in
        builtins.concatStringsSep "\n" syncCommands
      );

      # Ensure parent directories exist for link targets before link generation.
      activation.agent-skills-link-dirs = lib.hm.dag.entryBefore [ "linkGeneration" ] (
        let
          linkTargets = lib.filterAttrs (_: t: t.enable && t.structure == "link") cfg.targets;
          mkdirCommands = lib.mapAttrsToList (_name: target: ''
            ${pkgs.coreutils}/bin/mkdir -p "$HOME/${target.dest}"
          '') linkTargets;
          configDirCommands = lib.mapAttrsToList (_name: target: ''
            ${pkgs.coreutils}/bin/mkdir -p "$HOME/${target.configDest}"
          '') (lib.filterAttrs (_: t: t.enable && t.configDest != null) cfg.targets);
          rulesDirCommands = mkAssetDirCommands "rules" distributionResult.rules cfg.targets;
          agentsDirCommands = mkAssetDirCommands "agents" mergedAgents cfg.targets;
          commandsDirCommands = mkAssetDirCommands "commands" externalCommands cfg.targets;
        in
        builtins.concatStringsSep "\n" (
          mkdirCommands
          ++ configDirCommands
          ++ [
            rulesDirCommands
            agentsDirCommands
            commandsDirCommands
          ]
        )
      );

      # link targets: per-skill directory symlinks to Nix store (default)
      # Each skill dir becomes a symlink: ~/.claude/skills/agent-creator → /nix/store/.../agent-creator
      # This keeps .system and other tool-managed files writable in the parent dir
      file = lib.mkMerge (
        # Skill distribution
        (lib.mapAttrsToList (
          _name: target:
          if target.enable && target.structure == "link" then
            lib.mapAttrs' (
              skillId: _skill:
              lib.nameValuePair "${target.dest}/${skillId}" {
                source = "${bundle}/${skillId}";
              }
            ) selectedSkills
          else
            { }
        ) cfg.targets)
        ++
          # configFiles distribution
          (lib.concatMap (
            cf:
            lib.mapAttrsToList (
              targetName: target:
              if target.enable && target.configDest != null && !(lib.elem targetName cf.exclude) then
                let
                  filename = if lib.hasAttr targetName cf.rename then cf.rename.${targetName} else cf.default;
                in
                {
                  "${target.configDest}/${filename}".source = cf.src;
                }
              else
                { }
            ) cfg.targets
          ) cfg.configFiles)
        ++
          # Rules distribution (symlinks to each target's rules directory)
          (mkAssetFileLinks "rules" distributionResult.rules cfg.targets)
        ++
          # Agents distribution (symlinks to each target's agents directory)
          (mkAssetFileLinks "agents" mergedAgents cfg.targets)
        ++
          # Commands distribution (symlinks to each target's commands directory)
          (mkAssetFileLinks "commands" externalCommands cfg.targets)
      );
    };
  };
}
