## Rust language module for rustvim.
{ pkgs }:

{
  lspsAndRuntimeDeps = with pkgs; [
    rust-analyzer
    cargo
    clippy
    rustfmt
  ];

  debug = with pkgs; [
    vscode-extensions.vadimcn.vscode-lldb
  ];

  formatters = {
    rust = [ "rustfmt" ];
  };

  ## clippy diagnostics come via rust-analyzer's `check.command = "clippy"`,
  ## so we don't run a separate nvim-lint linter for rust.
  linters = {};

  treesitter = [ "rust" ];

  packageName = "rustvim";
  appName     = "rustvim";
  lspName     = "rust_analyzer";

  logo = ''
██████╗ ██╗   ██╗███████╗████████╗██╗   ██╗██╗███╗   ███╗
██╔══██╗██║   ██║██╔════╝╚══██╔══╝██║   ██║██║████╗ ████║
██████╔╝██║   ██║███████╗   ██║   ██║   ██║██║██╔████╔██║
██╔══██╗██║   ██║╚════██║   ██║   ╚██╗ ██╔╝██║██║╚██╔╝██║
██║  ██║╚██████╔╝███████║   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  ls-path       = "${pkgs.rust-analyzer.outPath}/bin/rust-analyzer";
  codelldb-path = "${pkgs.vscode-extensions.vadimcn.vscode-lldb.outPath}/share/vscode/extensions/vadimcn.vscode-lldb-*/adapter/codelldb";
}
