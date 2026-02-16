# External skill source mappings (flake inputs -> source paths)
# Dynamically generates catalog paths from agent-skills-sources.nix
{ inputs, agentSkills ? import ./agent-skills.nix }:
let
  sources = agentSkills.inputs;

  # Build catalog paths for a single source
  # sourceName: e.g., "openai-skills"
  # sourceConfig: e.g., { url, flake, baseDir, catalogs }
  buildCatalogs = sourceName: sourceConfig:
    let
      base = "${inputs.${sourceName}}/${sourceConfig.baseDir}";
    in
    builtins.mapAttrs
      (catalogName: subPath: {
        path = if subPath == "." then base else "${base}/${subPath}";
      })
      sourceConfig.catalogs;

  # Merge all catalog definitions from all sources
  allCatalogs = builtins.foldl'
    (acc: sourceName: acc // (buildCatalogs sourceName sources.${sourceName}))
    {}
    (builtins.attrNames sources);
in
allCatalogs
