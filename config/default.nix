{ config, lib, pkgs, ... }:

let
  files = builtins.readDir ./.;

  excludedFiles = [
    ./default.nix
    ./fidget.nix
  ];

  nixFiles = builtins.filter
    (name: !builtins.any (n: n == name) 
      (builtins.map builtins.baseNameOf excludedFiles) && 
      builtins.match ".*\\.nix" name != null
    )
    (builtins.attrNames files);

  imports = map (name: ./. + "/${name}") nixFiles;
in {
  imports = [./snacks ./treesitter] ++ imports;

  options = {
    theme = lib.mkOption {
      default = lib.mkDefault "paradise";
      type = lib.types.enum [
        "aquarium"
        "decay"
        "edge-dark"
        "everblush"
        "everforest"
        "far"
        "frappe"
        "gruvbox"
        "jellybeans"
        "material"
        "material-darker"
        "mountain"
        "nebula"
        "ocean"
        "oxocarbon"
        "paradise"
        "tokyonight"
        "yoru"
      ];
    };
#    assistant = lib.mkOption {
#      default = "copilot";
#      type = lib.types.enum [
#        "copilot"
#        "none"
#      ];
#    };
  };
  config = {
    theme = "paradise";
    extraConfigLua = ''
      _G.theme = "${config.theme}"
    '';
  };
}
