## JavaScript / TypeScript language module for jsvim.
{ pkgs }:

{
  ## Tools available on PATH inside the wrapped Neovim.
  ## Includes: LSPs, formatters, linters, and the runtime (node) the LSPs
  ## themselves shell out to.
  lspsAndRuntimeDeps = with pkgs; [
    nodejs_22
    typescript
    typescript-language-server
    ## eslint / jsonls / cssls / html LSPs all live here:
    vscode-langservers-extracted
    tailwindcss-language-server
    emmet-language-server
    yaml-language-server
    eslint_d
    prettierd
  ];

  ## Debug adapters.
  debug = with pkgs; [
    vscode-js-debug
  ];

  ## conform.nvim formatters_by_ft contributions.
  formatters = {
    javascript     = [ "prettierd" "prettier" ];
    javascriptreact = [ "prettierd" "prettier" ];
    typescript     = [ "prettierd" "prettier" ];
    typescriptreact = [ "prettierd" "prettier" ];
    json           = [ "prettierd" "prettier" ];
    jsonc          = [ "prettierd" "prettier" ];
    html           = [ "prettierd" "prettier" ];
    css            = [ "prettierd" "prettier" ];
    scss           = [ "prettierd" "prettier" ];
    less           = [ "prettierd" "prettier" ];
    yaml           = [ "prettierd" "prettier" ];
    markdown       = [ "prettierd" "prettier" ];
    graphql        = [ "prettierd" "prettier" ];
    vue            = [ "prettierd" "prettier" ];
    svelte         = [ "prettierd" "prettier" ];
  };

  ## nvim-lint linters_by_ft contributions.
  linters = {
    javascript     = [ "eslint_d" ];
    javascriptreact = [ "eslint_d" ];
    typescript     = [ "eslint_d" ];
    typescriptreact = [ "eslint_d" ];
  };

  ## Treesitter parsers (informational; we use withAllGrammars).
  treesitter = [ "javascript" "typescript" "tsx" "jsdoc" "json" "json5" "html" "css" "yaml" "graphql" ];

  packageName = "jsvim";
  appName     = "jsvim";
  lspName     = "ts_ls";

  logo = ''
    ██╗ ███████╗ ██╗   ██╗██╗███╗   ███╗
    ██║ ╚═══ ██║ ██║   ██║██║████╗ ████║
    ██║ ███████║ ██║   ██║██║██╔████╔██║
██   ██║ ██╔════╝ ╚██╗ ██╔╝██║██║╚██╔╝██║
╚█████╔╝ ███████╗  ╚████╔╝ ██║██║ ╚═╝ ██║
 ╚════╝  ╚══════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
  '';

  ## Path to the vscode-js-debug DAP server entry point.
  js-debug-path = "${pkgs.vscode-js-debug.outPath}/lib/node_modules/js-debug/dist/src/dapDebugServer.js";
}
