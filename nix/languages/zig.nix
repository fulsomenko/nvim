# Zig language configuration for zvim
{ pkgs }:

{
  # LSP server and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    zls
  ];

  # Debug adapter
  debug = with pkgs; [
    lldb
  ];

  # Code formatter
  formatter = with pkgs; [
    # Zig's formatter is built-in (zig fmt)
  ];

  # Linter
  linter = "";

  # Package naming
  packageName = "zvim";
  appName = "zvim";

  # ASCII art logo
  logo = ''
███████╗██╗   ██╗██╗███╗   ███╗
╚══███╔╝██║   ██║██║████╗ ████║
  ███╔╝ ██║   ██║██║██╔████╔██║
 ███╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║
███████╗ ╚████╔╝ ██║██║ ╚═╝ ██║
╚══════╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  # LSP server name (as used in lspconfig)
  lspName = "zls";

  # Additional paths for zvim
  ls-path = "${pkgs.zls.outPath}/bin/zls";
}
