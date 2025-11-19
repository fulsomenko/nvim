# Java language configuration for jvim
{ pkgs }:

{
  # LSP server and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    jdt-language-server
    vimPlugins.nvim-jdtls
  ];

  # Debug adapter
  debug = with pkgs; [ ];

  # Code formatter
  formatter = with pkgs; [
    google-java-format
  ];

  # Linter
  linter = "checkstyle";

  # Package naming
  packageName = "jvim";
  appName = "jvim";

  # ASCII art logo
  logo = ''
    ██╗██╗   ██╗██╗███╗   ███╗
    ██║██║   ██║██║████╗ ████║
    ██║██║   ██║██║██╔████╔██║
██   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
╚█████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  # LSP server name (as used in lspconfig)
  lspName = "jdtls";

  # Additional paths for jvim
  ls-path = "${pkgs.jdt-language-server.outPath}/bin/jdtls";
}
