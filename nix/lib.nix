## Helper functions for building per-language Neovim packages.
##
## Each language module under ./languages/ exports a single attrset.
## Required fields (see ./languages/javascript.nix for the canonical example):
##   lspsAndRuntimeDeps :: [pkg]      Tools (LSPs, formatters, linters, node, ...)
##                                    that should be on PATH inside Neovim.
##   debug              :: [pkg]      Debug adapters (vscode-js-debug, lldb, ...).
##   formatters         :: { ft = [str]; ... }
##                                    conform.nvim-style ft -> formatter list.
##   linters            :: { ft = [str]; ... }
##                                    nvim-lint-style ft -> linter list.
##   lspName            :: string     The lspconfig server name (e.g. "ts_ls").
##   packageName        :: string     The flake output name (e.g. "jsvim").
##   appName            :: string     vim.g.appName-style identifier.
##   logo               :: string     ASCII logo string for dashboards.
##
## Optional fields:
##   ls-path            :: string     Absolute path to the language server bin.
##   codelldb-path      :: string     Path to the codelldb adapter (rust).
##   js-debug-path      :: string     Path to vscode-js-debug dapDebugServer.js.
##   treesitter         :: [str]      Treesitter parsers (informational).
##   extraCategories    :: { ... }    Additional categories to enable on the
##                                    package built from this module.
##   extraSettings      :: { ... }    Additional values for `settings`.
##   extra              :: { ... }    Additional values merged into nixCats `extra`.

{ nixpkgs }:

let
  lib = nixpkgs.lib;
in
rec {
  ## Import every language module once.
  languageModules = pkgs: {
    javascript = import ./languages/javascript.nix { inherit pkgs; };
    java       = import ./languages/java.nix       { inherit pkgs; };
    csharp     = import ./languages/csharp.nix     { inherit pkgs; };
    rust       = import ./languages/rust.nix       { inherit pkgs; };
    zig        = import ./languages/zig.nix        { inherit pkgs; };
    r          = import ./languages/r.nix          { inherit pkgs; };
  };

  availableLanguages = [ "javascript" "java" "csharp" "rust" "zig" "r" ];

  ## Merge the per-language `formatters` / `linters` tables into a single
  ## ft -> [tool] map, suitable for conform / nvim-lint.
  ##
  ## Later languages overwrite earlier ones if they declare the same ft.
  mergeFt = field: langs:
    lib.foldl' (acc: lang:
      acc // (lang.${field} or {})
    ) {} (lib.attrValues langs);

  ## Build a combined `extra.languageConfig` set that the lua side reads
  ## via `nixCats.extra("languageConfig.formatters")` etc.
  ##
  ## We pass the FULL set of language formatters/linters to every package;
  ## the lua side will only actually invoke tools that are on PATH (i.e.
  ## that come from a category the package enabled).
  mkLanguageConfig = pkgs: {
    formatters = mergeFt "formatters" (languageModules pkgs);
    linters    = mergeFt "linters"    (languageModules pkgs);
  };

  ## Build a single language package definition.
  ##
  ## Arguments:
  ##   language        - Key into `languageModules` (e.g. "javascript").
  ##   aliases         - Extra binary aliases the wrapper installs.
  ##   colorscheme     - "onedark" | "catppuccin" | "tokyonight" | ...
  ##   extraCategories - Additional categories to set true on this package.
  ##   extraSettings   - Additional `settings` entries (merged after defaults).
  mkLanguagePackage = {
    language,
    aliases ? [],
    colorscheme ? "onedark",
    extraCategories ? {},
    extraSettings ? {},
  }: { pkgs, ... }@misc:
  let
    lang = (languageModules pkgs).${language};
  in {
    settings = {
      wrapRc       = true;
      configDirName = "mox-nvim";
      inherit aliases;
    } // extraSettings;

    categories = {
      markdown    = true;
      general     = true;
      lint        = true;
      format      = true;
      neonixdev   = true;
      ai          = false;     ## opt-in per package
      lspDebugMode = false;
      themer      = true;
      colorscheme = colorscheme;

      appName = lang.appName;
      logo    = lang.logo;
      lspName = lang.lspName;

      test = { subtest1 = true; };
    }
    ## Enable the language category itself (e.g. js, rust, zig).
    // (let key = if language == "javascript" then "js" else language; in { ${key} = true; })
    ## Optional language-specific paths.
    // lib.optionalAttrs (lang ? ls-path)        { ls-path        = lang.ls-path; }
    // lib.optionalAttrs (lang ? codelldb-path)  { codelldb-path  = lang.codelldb-path; }
    // lib.optionalAttrs (lang ? js-debug-path)  { js-debug-path  = lang.js-debug-path; }
    // extraCategories;

    extra = {
      nixdExtras = { inherit nixpkgs; };
      languageConfig = mkLanguageConfig pkgs;
    };
  };
}
