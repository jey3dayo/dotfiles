# Core library functions for agent-skills management
{ pkgs, nixlib }:

let
  inherit (nixlib) filterAttrs mapAttrsToList concatStringsSep
    hasAttr attrNames length elem;
  inherit (builtins) readDir pathExists toJSON seq;

  # Scan a single source path and return { skillId = { id, path, source }; }
  scanSource = sourceName: sourcePath:
    let
      entries = readDir sourcePath;
      dirs = attrNames (filterAttrs (_: type: type == "directory") entries);
      skills = builtins.filter (name: pathExists (sourcePath + "/${name}/SKILL.md")) dirs;
    in
      builtins.listToAttrs (map (name: {
        inherit name;
        value = {
          id = name;
          path = sourcePath + "/${name}";
          source = sourceName;
        };
      }) skills);

  # Detect if source root is itself a skill, or contains sub-skills
  scanSourceAutoDetect = sourceName: sourcePath:
    let
      claudeSkillsPath = sourcePath + "/.claude/skills";
      direct =
        if pathExists sourcePath then
          scanSource sourceName sourcePath
        else
          {};
      claudeSkills =
        if direct == {} && pathExists claudeSkillsPath then
          scanSource sourceName claudeSkillsPath
        else
          {};
    in
      if pathExists (sourcePath + "/SKILL.md") then
        { ${sourceName} = { id = sourceName; path = sourcePath; source = sourceName; }; }
      else if direct != {} then
        direct
      else
        claudeSkills;

in {
  # Discover all available skills from sources + local path
  # Returns: { skillId = { id, path, source }; ... }
  discoverCatalog = { sources, localPath }:
    let
      # Scan each external source
      externalSkills = builtins.foldl' (acc: srcName:
        let
          src = sources.${srcName};
          scanned = scanSourceAutoDetect srcName src.path;
          duplicates = builtins.filter (id: hasAttr id acc) (attrNames scanned);
          duplicateDetails = builtins.map (id:
            "${id} (existing: ${acc.${id}.source}, new: ${scanned.${id}.source})"
          ) duplicates;
        in
          # External sources: error on duplicate skill IDs to avoid silent overrides
          if duplicates != [] then
            throw "Duplicate skill ids found across external sources: ${concatStringsSep ", " duplicateDetails}. Resolve by renaming or removing the duplicates."
          else
            acc // scanned
      ) {} (attrNames sources);

      # Scan local skills (skills-internal)
      localSkills =
        if localPath != null && pathExists localPath then
          scanSource "local" localPath
        else {};

      # Local overrides external (local wins on conflict)
    in
      externalSkills // localSkills;

  # Filter catalog by enable list
  # Returns: { skillId = { id, path, source }; ... } (only enabled ones)
  selectSkills = { catalog, enable }:
    let
      missing = builtins.filter (id: !(hasAttr id catalog)) enable;
    in
      # Force evaluation of missing check
      seq
        (if missing != [] then
          throw "Skills not found in catalog: ${concatStringsSep ", " missing}"
        else null)
        (filterAttrs (id: _: elem id enable) catalog);

  # Create a Nix store derivation bundling all selected skills
  mkBundle = { skills, name ? "agent-skills-bundle" }:
    let
      skillList = mapAttrsToList (id: skill: { inherit id; inherit (skill) path source; }) skills;
      copyCommands = concatStringsSep "\n" (map (s:
        ''
          ${pkgs.rsync}/bin/rsync -aL "${s.path}/" "$out/${s.id}/"
        ''
      ) skillList);
      bundleInfo = toJSON {
        skills = map (s: { inherit (s) id source; }) skillList;
        count = length skillList;
      };
      bundleInfoFile = pkgs.writeText "bundle-info.json" bundleInfo;
    in
      pkgs.runCommand name {} ''
        set -euo pipefail
        mkdir -p "$out"
        ${copyCommands}
        cp ${bundleInfoFile} "$out/.bundle-info"
        chmod -R u+r "$out"
      '';

  # Create a sync script (fallback for non-HM usage)
  mkSyncScript = { bundle, targets }:
    pkgs.writeShellApplication {
      name = "skills-install";
      runtimeInputs = [ pkgs.coreutils pkgs.jq pkgs.rsync ];
      text = ''
        echo "Installing agent skills..."
        ${concatStringsSep "\n" (map (t: ''
          dest="$HOME/${t.dest}"
          mkdir -p "$dest"
          rsync -aL --delete --exclude='/.system' "${bundle}/" "$dest/"
          chmod -R u+w "$dest"
          echo "  -> ${t.tool}: $dest"
        '') targets)}
        echo "Done. $(jq -r '.count' "${bundle}/.bundle-info") skills installed to ${toString (length targets)} targets."
      '';
    };

  # Create a script that lists catalog & selected skills as JSON
  mkListScript = { catalog, selectedSkills }:
    let
      catalogInfo = mapAttrsToList (id: s: {
        inherit id;
        inherit (s) source;
        enabled = hasAttr id selectedSkills;
      }) catalog;
      jsonData = toJSON {
        skills = catalogInfo;
        total = length (attrNames catalog);
        enabled = length (attrNames selectedSkills);
      };
      jsonFile = pkgs.writeText "skills-list.json" jsonData;
    in
      pkgs.writeShellScriptBin "skills-list" ''
        ${pkgs.jq}/bin/jq . "${jsonFile}"
      '';

  # Create a validation script that checks bundle integrity
  mkValidateScript = { catalog, selectedSkills, bundle }:
    let
      catalogIds = attrNames catalog;
      selectedIds = attrNames selectedSkills;
    in
      pkgs.writeShellScriptBin "skills-validate" ''
        echo "Validating skill catalog..."
        echo "  Total skills in catalog: ${toString (length catalogIds)}"
        echo "  Selected skills: ${toString (length selectedIds)}"

        errors=0

        # Verify each selected skill exists in bundle and has SKILL.md
        selected_ids="${concatStringsSep " " selectedIds}"
        if [ -n "$selected_ids" ]; then
          for skill_name in $selected_ids; do
            if [ ! -d "${bundle}/$skill_name" ]; then
              echo "  ERROR: $skill_name missing from bundle"
              errors=$((errors + 1))
              continue
            fi
            if [ ! -f "${bundle}/$skill_name/SKILL.md" ]; then
              echo "  ERROR: $skill_name missing SKILL.md"
              errors=$((errors + 1))
            fi
          done
        fi

        # Verify no unexpected directories are missing SKILL.md
        for skill_dir in "${bundle}"/*/; do
          skill_name=$(basename "$skill_dir")
          if [ ! -f "$skill_dir/SKILL.md" ]; then
            echo "  ERROR: $skill_name missing SKILL.md"
            errors=$((errors + 1))
          fi
        done

        echo ""
        if [ "$errors" -gt 0 ]; then
          echo "FAIL: $errors validation errors found"
          exit 1
        else
          echo "All ${toString (length selectedIds)} selected skills validated."
          echo "OK: All checks passed"
        fi
      '';

  # Create nix flake checks
  mkChecks = { bundle, catalog, selectedSkills }:
    pkgs.runCommand "agent-skills-check" {} ''
      # Verify bundle exists and has content
      test -f "${bundle}/.bundle-info"

      # Verify expected skill count
      count=$(${pkgs.jq}/bin/jq -r '.count' "${bundle}/.bundle-info")
      expected="${toString (length (attrNames selectedSkills))}"
      if [ "$count" != "$expected" ]; then
        echo "FAIL: Expected $expected skills, got $count"
        exit 1
      fi

      echo "All checks passed ($count skills)" > "$out"
    '';
}
