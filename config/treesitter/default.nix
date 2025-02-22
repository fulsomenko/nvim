let
  files = builtins.readDir ./.;

  nixFiles = builtins.filter
    (name: name != "default.nix" && builtins.match ".*\\.nix" name != null)
    (builtins.attrNames files);

  imports = map (name: ./. + "/${name}") nixFiles;
in {
  imports = imports;
}

