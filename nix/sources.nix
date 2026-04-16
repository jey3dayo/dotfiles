# External skill source mappings (flake inputs -> source paths)
# Dynamically generates catalog paths from agent-skills-sources.nix
{
  inputs,
  agentSkills ? import ./agent-skills.nix,
}:
let
  sources = agentSkills.inputs;

  # Build catalog paths for a single source
  # sourceName: e.g., "openai-skills"
  # sourceConfig: e.g., { url, flake, baseDir, catalogs }
  # Returns {} with trace warning if the flake input is missing (graceful degradation)
  buildCatalogs =
    sourceName: sourceConfig:
    if builtins.hasAttr sourceName inputs then
      let
        root = inputs.${sourceName};
        base = "${inputs.${sourceName}}/${sourceConfig.baseDir}";
        mkSourcePath = relativePath: if relativePath == "." then root else "${root}/${relativePath}";
      in
      builtins.mapAttrs (
        _catalogName: subPath:
        {
          path = if subPath == "." then base else "${base}/${subPath}";
        }
        // (if sourceConfig ? idPrefix then { inherit (sourceConfig) idPrefix; } else { })
        // (
          if sourceConfig ? assets && sourceConfig.assets ? agents then
            { agentsPath = mkSourcePath sourceConfig.assets.agents; }
          else
            { }
        )
        // (
          if sourceConfig ? assets && sourceConfig.assets ? commands then
            { commandsPath = mkSourcePath sourceConfig.assets.commands; }
          else
            { }
        )
        // (
          if sourceConfig ? homeLinks then
            { homeLinks = builtins.mapAttrs (_name: mkSourcePath) sourceConfig.homeLinks; }
          else
            { }
        )
      ) sourceConfig.catalogs
    else
      builtins.trace "WARNING: flake input '${sourceName}' not found, skipping source" { };

  # Merge all catalog definitions from all sources
  allCatalogs = builtins.foldl' (
    acc: sourceName: acc // (buildCatalogs sourceName sources.${sourceName})
  ) { } (builtins.attrNames sources);
in
allCatalogs
