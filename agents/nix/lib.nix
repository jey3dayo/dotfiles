# Core library functions for agent-skills management
{ pkgs, nixlib }:

let
  inherit (nixlib)
    filterAttrs
    mapAttrsToList
    concatStringsSep
    hasAttr
    attrNames
    unique
    length
    elem
    sort
    ;
  inherit (builtins)
    readDir
    pathExists
    toJSON
    seq
    stringLength
    substring
    ;

  hasPrefix =
    prefix: str:
    let
      prefixLen = stringLength prefix;
      strLen = stringLength str;
    in
    if strLen < prefixLen then false else substring 0 prefixLen str == prefix;

  removePrefix =
    prefix: str:
    if hasPrefix prefix str then
      substring (stringLength prefix) (stringLength str - stringLength prefix) str
    else
      str;

  stripDotPrefix = str: if hasPrefix "./" str then substring 2 (stringLength str - 2) str else str;

  prefixId = prefix: id: if prefix == "" then id else "${prefix}${id}";

  getIdPrefix =
    sourceConfig:
    if builtins.hasAttr "idPrefix" sourceConfig && sourceConfig.idPrefix != null then
      sourceConfig.idPrefix
    else
      "";

  # Scan a single source path and return { skillId = { id, path, source }; }
  scanSource =
    sourceName: sourceConfig:
    let
      sourcePath = sourceConfig.path;
      idPrefix = getIdPrefix sourceConfig;
      entries = readDir sourcePath;
      dirs = attrNames (filterAttrs (_: type: type == "directory") entries);
      skills = builtins.filter (name: pathExists (sourcePath + "/${name}/SKILL.md")) dirs;
    in
    builtins.listToAttrs (
      map (
        name:
        let
          skillId = prefixId idPrefix name;
        in
        {
          name = skillId;
          value = {
            id = skillId;
            path = sourcePath + "/${name}";
            source = sourceName;
          };
        }
      ) skills
    );

  # Detect if source root is itself a skill, or contains sub-skills
  scanSourceAutoDetect =
    sourceName: sourceConfig:
    let
      sourcePath = sourceConfig.path;
      idPrefix = getIdPrefix sourceConfig;
      claudeSkillsPath = sourcePath + "/.claude/skills";
      direct = if pathExists sourcePath then scanSource sourceName sourceConfig else { };
      claudeSkills =
        if direct == { } && pathExists claudeSkillsPath then
          scanSource sourceName (sourceConfig // { path = claudeSkillsPath; })
        else
          { };
    in
    if pathExists (sourcePath + "/SKILL.md") then
      {
        ${prefixId idPrefix sourceName} = {
          id = prefixId idPrefix sourceName;
          path = sourcePath;
          source = sourceName;
        };
      }
    else if direct != { } then
      direct
    else
      claudeSkills;

  # Generic .md file scanner for rules/agents directories
  # basePath: directory to scan
  # source: source tag (e.g., "distribution")
  scanMdEntries =
    basePath: source: idPrefix:
    if pathExists basePath then
      let
        entries = readDir basePath;
        processEntry =
          name: type:
          let
            entryPath = basePath + "/${name}";
            entryId = prefixId idPrefix (
              if nixlib.hasSuffix ".md" name then nixlib.removeSuffix ".md" name else name
            );
          in
          if (type == "regular" || type == "symlink") && nixlib.hasSuffix ".md" name then
            {
              ${entryId} = {
                id = entryId;
                path = entryPath;
                inherit source;
              };
            }
          else if type == "directory" || type == "symlink" then
            let
              subEntries =
                let
                  result = builtins.tryEval (readDir entryPath);
                in
                if result.success then result.value else { };
              processSubEntry =
                subName: subType:
                let
                  subPath = entryPath + "/${subName}";
                  subId = prefixId idPrefix (
                    if nixlib.hasSuffix ".md" subName then
                      "${name}/${nixlib.removeSuffix ".md" subName}"
                    else
                      "${name}/${subName}"
                  );
                in
                if (subType == "regular" || subType == "symlink") && nixlib.hasSuffix ".md" subName then
                  {
                    ${subId} = {
                      id = subId;
                      path = subPath;
                      inherit source;
                    };
                  }
                else
                  { };
            in
            builtins.foldl' (acc: entry: acc // (processSubEntry entry.name entry.type)) { } (
              mapAttrsToList (n: t: {
                name = n;
                type = t;
              }) subEntries
            )
          else
            { };
      in
      builtins.foldl' (acc: entry: acc // (processEntry entry.name entry.type)) { } (
        mapAttrsToList (name: type: { inherit name type; }) entries
      )
    else
      { };

  # Scan distributions directory for bundled components
  # Returns: { skills = { skillId = { id, path, source }; ... }; commands = path or null; rules = { ruleId = { id, path, source }; ... }; agents = { agentId = { id, path, source }; ... }; }
  scanDistribution =
    distributionPath:
    let
      skillsPath = distributionPath + "/skills";
      commandsPath = distributionPath + "/commands";
      configPath = distributionPath + "/config";
      rulesPath = distributionPath + "/rules";
      agentsPath = distributionPath + "/agents";

      # Scan skills subdirectories
      scannedSkills =
        if pathExists skillsPath then
          let
            skillDirs = readDir skillsPath;
            # Handle both direct skill dirs and symlinked source dirs
            processSkillEntry =
              name: type:
              let
                entryPath = skillsPath + "/${name}";
              in
              if type == "directory" || type == "symlink" then
                # Check if it's a skill directory directly
                if pathExists (entryPath + "/SKILL.md") then
                  {
                    ${name} = {
                      id = name;
                      path = entryPath;
                      source = "distribution";
                    };
                  }
                # Support nested skill layout: <skill-id>/skills/SKILL.md
                else if pathExists (entryPath + "/skills/SKILL.md") then
                  {
                    ${name} = {
                      id = name;
                      path = entryPath + "/skills";
                      source = "distribution";
                    };
                  }
                else
                  # Or scan it as a source directory
                  scanSource "distribution" { path = entryPath; }
              else
                { };
          in
          builtins.foldl' (acc: entry: acc // (processSkillEntry entry.name entry.type)) { } (
            mapAttrsToList (name: type: { inherit name type; }) skillDirs
          )
        else
          { };
      scannedRules = scanMdEntries rulesPath "distribution" "";
      scannedAgents = scanMdEntries agentsPath "distribution" "";
    in
    {
      skills = scannedSkills;
      commands = if pathExists commandsPath then commandsPath else null;
      config = if pathExists configPath then configPath else null;
      rules = scannedRules;
      agents = scannedAgents;
    };

in
rec {
  inherit
    scanDistribution
    scanMdEntries
    ;

  # Discover all available skills from sources + distributions
  # Returns: { skillId = { id, path, source }; ... }
  discoverCatalog =
    {
      sources,
      distributionsPath ? null,
    }:
    let
      # Scan distributions first (if provided)
      distributionResult =
        if distributionsPath != null && pathExists distributionsPath then
          scanDistribution distributionsPath
        else
          {
            skills = { };
            commands = null;
            config = null;
            rules = { };
            agents = { };
          };

      # Scan each flake input source (last-wins on duplicate skill IDs)
      externalSkills = builtins.foldl' (
        acc: srcName:
        let
          src = sources.${srcName};
          scanned = scanSourceAutoDetect srcName src;
        in
        acc // scanned
      ) { } (attrNames sources);

      # Priority: distribution (internal) > external (flake inputs)
      # Nix // operator is right-biased, so RIGHT side wins on conflicts.
      # agents/src skills override flake input skills on duplicate IDs.
    in
    externalSkills // distributionResult.skills;

  # Discover assets exposed by external sources (for example top-level agents/commands).
  discoverExternalAssets =
    {
      sources,
      assetType,
      enabledSources ? attrNames sources,
    }:
    let
      assetPathAttr = "${assetType}Path";
    in
    builtins.foldl' (
      acc: srcName:
      let
        src = sources.${srcName};
      in
      if
        !elem srcName enabledSources || !builtins.hasAttr assetPathAttr src || src.${assetPathAttr} == null
      then
        acc
      else
        # External commands/agents must keep upstream IDs because filenames and
        # in-file metadata are consumed as-is by the target tools.
        acc // (scanMdEntries src.${assetPathAttr} srcName "")
    ) { } (attrNames sources);

  # Filter catalog by enable list
  # Returns: { skillId = { id, path, source }; ... } (only enabled ones)
  selectSkills =
    { catalog, enable }:
    let
      missing = builtins.filter (id: !(hasAttr id catalog)) enable;
    in
    # Force evaluation of missing check
    seq (
      if missing != [ ] then
        throw "Skills not found in catalog: ${concatStringsSep ", " missing}"
      else
        null
    ) (filterAttrs (id: _: elem id enable) catalog);

  resolveSelectedSkills =
    { catalog, enable }:
    let
      distributionSkillIds = attrNames (filterAttrs (_: skill: skill.source == "distribution") catalog);
      enableList = if enable == null then attrNames catalog else unique (enable ++ distributionSkillIds);
      selectedSkills =
        if enable == null then
          catalog
        else
          selectSkills {
            inherit catalog;
            enable = enableList;
          };
    in
    {
      inherit distributionSkillIds enableList selectedSkills;
      selectedSkillSources = unique (map (skill: skill.source) (builtins.attrValues selectedSkills));
    };

  # Create a Nix store derivation bundling all selected skills
  mkBundle =
    {
      skills,
      name ? "agent-skills-bundle",
    }:
    let
      skillList = mapAttrsToList (id: skill: {
        inherit id;
        inherit (skill) path source;
      }) skills;
      copyCommands = concatStringsSep "\n" (
        map (s: ''
          mkdir -p "$out/${s.id}"
          broken_links_file="$(mktemp)"

          # Some upstream skill repos ship broken symlinks; skip only those entries
          # so null-selection bundles stay buildable while preserving valid links.
          while IFS= read -r broken_link; do
            printf '%s\n' "''${broken_link#"${s.path}/"}" >> "$broken_links_file"
          done < <(${pkgs.findutils}/bin/find -L "${s.path}" -type l)

          ${pkgs.rsync}/bin/rsync -aL --exclude-from="$broken_links_file" "${s.path}/" "$out/${s.id}/"
          rm -f "$broken_links_file"
        '') skillList
      );
      bundleInfo = toJSON {
        skills = map (s: { inherit (s) id source; }) skillList;
        count = length skillList;
      };
      bundleInfoFile = pkgs.writeText "bundle-info.json" bundleInfo;
    in
    pkgs.runCommand name { } ''
      set -euo pipefail
      mkdir -p "$out"
      ${copyCommands}
      cp ${bundleInfoFile} "$out/.bundle-info"
      chmod -R u+r "$out"
    '';

  # Create a sync script (fallback for non-HM usage)
  mkSyncScript =
    { bundle, targets }:
    pkgs.writeShellApplication {
      name = "skills-install";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.jq
        pkgs.rsync
      ];
      text = ''
        echo "Installing agent skills..."
        ${concatStringsSep "\n" (
          map (t: ''
            dest="$HOME/${t.dest}"
            mkdir -p "$dest"
            rsync -aL --delete --exclude='/.system' "${bundle}/" "$dest/"
            chmod -R u+w "$dest"
            echo "  -> ${t.tool}: $dest"
          '') targets
        )}
        echo "Done. $(jq -r '.count' "${bundle}/.bundle-info") skills installed to ${toString (length targets)} targets."
      '';
    };

  # Create a script that lists catalog & selected skills as JSON
  mkListScript =
    { catalog, selectedSkills }:
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

  # Create a script that outputs install report (Markdown table)
  mkReportScript =
    { skills, sourceMeta }:
    let
      skillList = mapAttrsToList (id: skill: {
        inherit id;
        inherit (skill) path source;
      }) skills;
      typeOrder = {
        internal = 0;
        external = 1;
      };
      reportList = map (
        s:
        let
          meta =
            if hasAttr s.source sourceMeta then
              sourceMeta.${s.source}
            else
              throw "Missing source metadata for source '${s.source}'";
          rootStr = toString meta.root;
          branch = meta.branch or "main";
          relPath = stripDotPrefix (removePrefix "${rootStr}/" (toString s.path));
        in
        {
          inherit (s) id;
          type = if s.source == "local" || s.source == "distribution" then "internal" else "external";
          url = "${meta.repoUrl}/tree/${branch}/${relPath}";
        }
      ) skillList;
      sorted = sort (
        a: b:
        if typeOrder.${a.type} == typeOrder.${b.type} then
          a.id < b.id
        else
          typeOrder.${a.type} < typeOrder.${b.type}
      ) reportList;
      header = "| Skill | Type | URL |\n| --- | --- | --- |\n";
      rows = concatStringsSep "\n" (map (r: "| ${r.id} | ${r.type} | ${r.url} |") sorted);
      output = header + rows + "\n";
      reportFile = pkgs.writeText "skills-install-report.md" output;
    in
    pkgs.writeShellScriptBin "skills-report" ''
      cat ${reportFile}
    '';
  # Create a validation script that checks bundle integrity
  mkValidateScript =
    {
      catalog,
      selectedSkills,
      bundle,
    }:
    let
      catalogIds = attrNames catalog;
      selectedIds = attrNames selectedSkills;
    in
    pkgs.writeShellScriptBin "skills-validate" ''
      echo "Validating skill catalog..."
      echo "  Total skills in catalog: ${toString (length catalogIds)}"
      echo "  Selected skills: ${toString (length selectedIds)}"
      echo "  Unselected skills: $(( ${toString (length catalogIds)} - ${toString (length selectedIds)} ))"

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

      # Bundle size information
      bundle_size=$(du -sh "${bundle}" 2>/dev/null | cut -f1)
      echo ""
      echo "Bundle size: $bundle_size"

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
  mkChecks =
    {
      bundle,
      selectedSkills,
      ...
    }:
    pkgs.runCommand "agent-skills-check" { } ''
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
