## Multi-language Neovim configuration with nixCats.
##
## Outputs (per system):
##   .#jsvim    JavaScript / TypeScript (default)
##   .#rustvim  Rust
##   .#zvim     Zig
##   .#jvim     Java
##   .#sharpvim C#
##   .#rvim     R
##   .#regularCats  Impure dev variant (loads config from $XDG_CONFIG)
##   .#nixCats      Original example package, kept for reference
##
## All language packages share one configDirName ("mox-nvim"), one lua tree,
## and a single per-language module under nix/languages/.
##
## Originally based on the nixCats template by BirdeeHub. MIT licensed.

{
  description = "A Lua-natic's neovim flake, with extra cats! nixCats!";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixCats = {
      url = "github:BirdeeHub/nixCats-nvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    inherit (inputs.nixCats) utils;
    luaPath = "${./.}";
    forEachSystem = utils.eachSystem nixpkgs.lib.platforms.all;
    extra_pkg_config = { };

    moxLib = import ./nix/lib.nix { inherit nixpkgs; };

    dependencyOverlays = [
      (utils.standardPluginOverlay inputs)
    ];

    ## ---------------------------------------------------------------- ##
    ## categoryDefinitions
    ## ---------------------------------------------------------------- ##
    ##
    ## All category contents are derived from the per-language modules
    ## (nix/languages/*.nix) so that each language has exactly one source
    ## of truth.
    categoryDefinitions = { pkgs, settings, categories, extra, name, mkNvimPlugin, ... }@packageDef:
    let
      langs = moxLib.languageModules pkgs;
    in {
      lspsAndRuntimeDeps = {
        general = with pkgs; [
          universal-ctags
          ripgrep
          fd
        ];
        lint = with pkgs; [ ];
        format = with pkgs; [
          prettierd
        ];
        ## Per-language tools (LSPs, formatters, linters, runtimes).
        js     = langs.javascript.lspsAndRuntimeDeps;
        java   = langs.java.lspsAndRuntimeDeps;
        csharp = langs.csharp.lspsAndRuntimeDeps;
        zig    = langs.zig.lspsAndRuntimeDeps;
        rust   = langs.rust.lspsAndRuntimeDeps;
        r      = langs.r.lspsAndRuntimeDeps;
        ## Debug adapters per language.
        debug = with pkgs; {
          go     = [ delve ];
          js     = langs.javascript.debug;
          java   = langs.java.debug;
          csharp = langs.csharp.debug;
          zig    = langs.zig.debug;
          rust   = langs.rust.debug;
          r      = langs.r.debug;
        };
        neonixdev = {
          inherit (pkgs) nix-doc lua-language-server nixd;
        };
      };

      startupPlugins = {
        debug = with pkgs.vimPlugins; [
          nvim-nio
        ];
        general = with pkgs.vimPlugins; {
          always = [
            lze
            vim-repeat
            plenary-nvim
            ollama-nvim
            nvim-notify
            transparent-nvim
            nerdtree
          ];
          extra = [
            oil-nvim
            nvim-web-devicons
          ];
        };
        themer = with pkgs.vimPlugins;
          (builtins.getAttr (categories.colorscheme or "onedark") {
            "onedark"          = onedark-nvim;
            "catppuccin"       = catppuccin-nvim;
            "catppuccin-mocha" = catppuccin-nvim;
            "tokyonight"       = tokyonight-nvim;
            "tokyonight-day"   = tokyonight-nvim;
          });
      };

      optionalPlugins = {
        debug = with pkgs.vimPlugins; {
          default = [
            nvim-dap
            nvim-dap-ui
            nvim-dap-virtual-text
          ];
          go     = [ nvim-dap-go ];
          js     = [];
          csharp = [];
          java   = [];
          zig    = [];
          rust   = [];
          r      = [];
        };
        lint   = with pkgs.vimPlugins; [ nvim-lint ];
        format = with pkgs.vimPlugins; [ conform-nvim ];
        markdown = with pkgs.vimPlugins; [ markdown-preview-nvim ];
        neonixdev = with pkgs.vimPlugins; [ lazydev-nvim ];
        ai = with pkgs.vimPlugins; [ claude-code-nvim ];

        ## JS-specific plugins. Activated only when the `js` category is on.
        js = with pkgs.vimPlugins; [
          nvim-ts-autotag
          nvim-ts-context-commentstring
          package-info-nvim
          SchemaStore-nvim
          neotest
          neotest-jest
          neotest-vitest
        ];

        general = {
          cmp = with pkgs.vimPlugins; [
            nvim-cmp
            luasnip
            friendly-snippets
            cmp_luasnip
            cmp-buffer
            cmp-path
            cmp-nvim-lua
            cmp-nvim-lsp
            cmp-cmdline
            cmp-nvim-lsp-signature-help
            cmp-cmdline-history
            lspkind-nvim
          ];
          treesitter = with pkgs.vimPlugins; [
            nvim-treesitter-textobjects
            nvim-treesitter.withAllGrammars
          ];
          telescope = with pkgs.vimPlugins; [
            telescope-fzf-native-nvim
            telescope-ui-select-nvim
            telescope-nvim
          ];
          snacks = with pkgs.vimPlugins; [ snacks-nvim ];
          always = with pkgs.vimPlugins; [
            nvim-lspconfig
            lualine-nvim
            gitsigns-nvim
            trouble-nvim
            vim-sleuth
            vim-fugitive
            vim-rhubarb
            nvim-surround
            nvim-spectre
            nvim-autopairs
            flash-nvim
          ];
          extra = with pkgs.vimPlugins; [
            fidget-nvim
            which-key-nvim
            comment-nvim
            undotree
            indent-blankline-nvim
            vim-startuptime
          ];
        };
      };

      sharedLibraries = {
        general = with pkgs; [ ];
      };

      environmentVariables = {
        test = {
          default  = { CATTESTVARDEFAULT = "It worked!"; };
          subtest1 = { CATTESTVAR        = "It worked!"; };
          subtest2 = { CATTESTVAR3       = "It didn't work!"; };
        };
      };

      extraWrapperArgs = {
        test = [ '' --set CATTESTVAR2 "It worked again!"'' ];
      };

      python3.libraries  = { test = (_:[]); };
      extraLuaPackages   = { general = [ (_:[]) ]; };

      extraCats = {
        test = [ [ "test" "default" ] ];
        debug = [ [ "debug" "default" ] ];
        csharp = [ [ "debug" "csharp" ] ];
        go     = [ [ "debug" "go" ] ];
        js     = [ [ "debug" "js" ] ];
        java   = [ [ "debug" "java" ] ];
        zig    = [ [ "debug" "zig" ] ];
        rust   = [ [ "debug" "rust" ] ];
        r      = [ [ "debug" "r" ] ];
        ## NOTE: AI is now opt-in per package; no longer forced on by `general`.
      };
    };

    ## ---------------------------------------------------------------- ##
    ## packageDefinitions
    ## ---------------------------------------------------------------- ##
    packageDefinitions = {
      jsvim    = moxLib.mkLanguagePackage {
        language        = "javascript";
        aliases         = [ "vim" "nvim" ];
        extraCategories = { ai = true; };
      };

      jvim     = moxLib.mkLanguagePackage { language = "java";   };
      sharpvim = moxLib.mkLanguagePackage { language = "csharp"; };
      zvim     = moxLib.mkLanguagePackage { language = "zig";    };
      rustvim  = moxLib.mkLanguagePackage { language = "rust";   };
      rvim     = moxLib.mkLanguagePackage { language = "r";      };

      ## ----- example packages preserved from the nixCats template ----- ##

      nixCats = { pkgs, ... }: {
        settings = {
          aliases       = [ "vimcat" ];
          wrapRc        = true;
          configDirName = "nixCats-nvim";
        };
        categories = {
          markdown    = true;
          general     = true;
          lint        = true;
          format      = true;
          neonixdev   = true;
          ai          = true;
          test        = { subtest1 = true; };
          lspDebugMode = false;
          themer      = true;
          colorscheme = "onedark";
        };
        extra = {
          nixdExtras     = { nixpkgs = nixpkgs; };
          languageConfig = moxLib.mkLanguageConfig pkgs;
        };
      };

      regularCats = { pkgs, ... }: {
        settings = {
          wrapRc        = false;
          configDirName = "nixCats-nvim";
          aliases       = [ "testCat" ];
        };
        categories = {
          markdown    = true;
          general     = true;
          neonixdev   = true;
          lint        = true;
          format      = true;
          test        = true;
          lspDebugMode = false;
          themer      = true;
          colorscheme = "catppuccin";
        };
        extra = {
          nixdExtras     = { nixpkgs = nixpkgs; };
          languageConfig = moxLib.mkLanguageConfig pkgs;
        };
      };
    };

    defaultPackageName = "jsvim";

  in
  forEachSystem (system: let
    nixCatsBuilder = utils.baseBuilder luaPath {
      inherit nixpkgs system dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions;
    defaultPackage = nixCatsBuilder defaultPackageName;
    pkgs = import nixpkgs { inherit system; };
  in {
    packages = utils.mkAllWithDefault defaultPackage;

    devShells = {
      default = pkgs.mkShell {
        name = defaultPackageName;
        packages = [ defaultPackage ];
        inputsFrom = [ ];
        shellHook = '' '';
      };
    };
  }) // (let
    nixosModule = utils.mkNixosModules {
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
    homeModule = utils.mkHomeModules {
      inherit defaultPackageName dependencyOverlays luaPath
        categoryDefinitions packageDefinitions extra_pkg_config nixpkgs;
    };
  in {
    overlays = utils.makeOverlays luaPath {
      inherit nixpkgs dependencyOverlays extra_pkg_config;
    } categoryDefinitions packageDefinitions defaultPackageName;

    nixosModules.default = nixosModule;
    homeModules.default  = homeModule;

    inherit utils nixosModule homeModule;
    inherit (utils) templates;
  });
}
