## R language module for rvim.
{ pkgs }:

{
  lspsAndRuntimeDeps = with pkgs; [
    R
    rPackages.languageserver
    rPackages.styler
    rPackages.lintr
  ];

  debug = with pkgs; [ ];

  ## styler is invoked through R via a shim formatter defined in
  ## lua/myLuaConf/format/init.lua's `formatters = { styler = ... }`.
  formatters = {
    r   = [ "styler" ];
    rmd = [ "styler" ];
    qmd = [ "styler" ];
  };

  linters = {
    r   = [ "lintr" ];
    rmd = [ "lintr" ];
  };

  treesitter = [ "r" ];

  packageName = "rvim";
  appName     = "rvim";
  lspName     = "r_language_server";

  logo = ''
██████╗ ██╗   ██╗██╗███╗   ███╗
██╔══██╗██║   ██║██║████╗ ████║
██████╔╝██║   ██║██║██╔████╔██║
██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║
██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';
}
