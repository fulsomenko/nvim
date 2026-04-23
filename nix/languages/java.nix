## Java language module for jvim.
{ pkgs }:

{
  lspsAndRuntimeDeps = with pkgs; [
    jdt-language-server
    google-java-format
    vimPlugins.nvim-jdtls
  ];

  debug = with pkgs; [ ];

  formatters = {
    java = [ "google-java-format" ];
  };

  linters = {};

  treesitter = [ "java" ];

  packageName = "jvim";
  appName     = "jvim";
  lspName     = "jdtls";

  logo = ''
    ██╗██╗   ██╗██╗███╗   ███╗
    ██║██║   ██║██║████╗ ████║
    ██║██║   ██║██║██╔████╔██║
██   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
╚█████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  ls-path = "${pkgs.jdt-language-server.outPath}/bin/jdtls";
}
