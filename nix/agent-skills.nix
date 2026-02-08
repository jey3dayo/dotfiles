# Agent skills sources + selection
let
  inputs = import ./agent-skills-sources.nix;
  selection = {
    enable =
      builtins.concatLists (builtins.map
        (source: source.selection.enable or [])
        (builtins.attrValues inputs));
  };
in
{
  inherit inputs selection;
}
