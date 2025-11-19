# JavaScript/TypeScript language configuration for jsvim
{ pkgs }:

{
  # LSP server and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    typescript-language-server
  ];

  # Debug adapter
  debug = with pkgs; [
    vscode-js-debug
  ];

  # Code formatter
  formatter = with pkgs; [
    prettierd
  ];

  # Linter
  linter = "eslint";

  # Package naming
  packageName = "jsvim";
  appName = "jsvim";

  # ASCII art logo
  logo = ''
    ██╗ ███████╗ ██╗   ██╗██╗███╗   ███╗
    ██║ ╚═══ ██║ ██║   ██║██║████╗ ████║
    ██║ ███████║ ██║   ██║██║██╔████╔██║
██   ██║ ██╔════╝ ╚██╗ ██╔╝██║██║╚██╔╝██║
╚█████╔╝ ███████╗  ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚════╝  ╚══════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  # LSP server name (as used in lspconfig)
  lspName = "ts_ls";

  # Additional paths for jsvim
  js-debug-path = "${pkgs.vscode-js-debug.outPath}/lib/node_modules/js-debug/dist/src/dapDebugServer.js";
}
