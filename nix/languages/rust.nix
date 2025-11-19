# Rust language configuration for rustvim
{ pkgs }:

{
  # LSP server and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    rust-analyzer
    cargo
    clippy
    rustfmt
  ];

  # Debug adapter
  debug = with pkgs; [
    vscode-extensions.vadimcn.vscode-lldb
  ];

  # Code formatter
  formatter = with pkgs; [
    rustfmt
  ];

  # Linter
  linter = "clippy";

  # Package naming
  packageName = "rustvim";
  appName = "rustvim";

  # ASCII art logo
  logo = ''
██████╗ ██╗   ██╗███████╗████████╗██╗   ██╗██╗███╗   ███╗
██╔══██╗██║   ██║██╔════╝╚══██╔══╝██║   ██║██║████╗ ████║
██████╔╝██║   ██║███████╗   ██║   ██║   ██║██║██╔████╔██║
██╔══██╗██║   ██║╚════██║   ██║   ╚██╗ ██╔╝██║██║╚██╔╝██║
██║  ██║╚██████╔╝███████║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  # LSP server name (as used in lspconfig)
  lspName = "rust_analyzer";

  # Additional paths for rustvim
  ls-path = "${pkgs.rust-analyzer.outPath}/bin/rust-analyzer";
  codelldb-path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.outPath}/share/vscode/extensions/vadimcn.vscode-lldb-*/adapter/codelldb";
}
