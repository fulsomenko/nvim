# R language configuration for rvim
{ pkgs }:

{
  # LSP server and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    R
    rPackages.languageserver
    rPackages.styler
    rPackages.lintr
  ];

  # Debug adapter
  debug = with pkgs; [ ];

  # Code formatter
  formatter = with pkgs; [
    # R formatter (styler is configured via R command in Lua config)
  ];

  # Linter
  linter = "lintr";

  # Package naming
  packageName = "rvim";
  appName = "rvim";

  # ASCII art logo
  logo = ''
██████╗ ██╗   ██╗██╗███╗   ███╗
██╔══██╗██║   ██║██║████╗ ████║
██████╔╝██║   ██║██║██╔████╔██║
██╔══██╗╚██╗ ██╔╝██║██║╚██╔╝██║
██║  ██║ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  # LSP server name (as used in lspconfig)
  lspName = "r_language_server";
}
