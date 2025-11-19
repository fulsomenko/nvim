# Helper functions and utilities for managing language packages
# This module provides functions for building language-specific packages
# and managing their configurations consistently.

{
  # mkLanguagePackage: Helper function to create a language-specific Neovim package
  #
  # This function standardizes the creation of language packages by providing
  # consistent defaults and reducing boilerplate in flake.nix.
  #
  # Arguments:
  #   language: string - The language category name (e.g., "rust", "javascript")
  #   appName: string - The application name (e.g., "rustvim", "jsvim")
  #   logo: string - ASCII art logo for the package (optional)
  #   extraCategories: set - Additional categories to enable (optional)
  #   colorscheme: string - Color scheme to use (default: "onedark")
  #
  # Returns:
  #   A package definition set compatible with nixCats packageDefinitions
  #
  # Example:
  #   rustvim = mkLanguagePackage {
  #     language = "rust";
  #     appName = "rustvim";
  #     logo = "(import ./nix/languages/rust.nix { inherit pkgs; }).logo";
  #   };
  mkLanguagePackage = {
    language,
    appName,
    logo ? "",
    extraCategories ? {},
    colorscheme ? "onedark",
  }: { pkgs, ... }@misc: {
    settings = {
      wrapRc = true;
      configDirName = "mox-nvim";
      aliases = [];
    };

    categories = {
      markdown = true;
      general = true;
      lint = true;
      format = true;
      neonixdev = true;
      test = {
        subtest1 = true;
      };
      lspDebugMode = false;
      themer = true;
      colorscheme = colorscheme;
      appName = appName;
      inherit logo;
    } // {
      "${language}" = true;
    } // extraCategories;

    extra = {
      nixdExtras = {
        nixpkgs = nixpkgs;
      };
    };
  };

  # loadLanguageModule: Helper function to import a language module
  #
  # This function consistently loads language module files from the
  # nix/languages/ directory with proper error handling.
  #
  # Arguments:
  #   languageName: string - The name of the language (e.g., "rust")
  #   pkgs: set - The nixpkgs set
  #
  # Returns:
  #   The language module containing lspsAndRuntimeDeps, debug, formatter, etc.
  #
  # Example:
  #   rust = (loadLanguageModule "rust" pkgs).lspsAndRuntimeDeps;
  loadLanguageModule = languageName: pkgs:
    import (./languages/${languageName}.nix) { inherit pkgs; };

  # languageModules: Convenience set for all available language modules
  #
  # Usage:
  #   languages = lib.languageModules pkgs;
  #   rust_lsp = languages.rust.lspsAndRuntimeDeps;
  languageModules = pkgs: {
    javascript = import ./languages/javascript.nix { inherit pkgs; };
    java = import ./languages/java.nix { inherit pkgs; };
    csharp = import ./languages/csharp.nix { inherit pkgs; };
    rust = import ./languages/rust.nix { inherit pkgs; };
    zig = import ./languages/zig.nix { inherit pkgs; };
    r = import ./languages/r.nix { inherit pkgs; };
  };

  # extractLanguageData: Helper to extract common fields from language modules
  #
  # This function extracts all the language module data and organizes
  # it into categoryDefinitions-compatible structures.
  #
  # Arguments:
  #   languages: set - The result of languageModules
  #
  # Returns:
  #   A set containing lspsAndRuntimeDeps, debug, formatters, and linters
  #   organized by language category
  extractLanguageData = languages: {
    lspsAndRuntimeDeps = builtins.mapAttrs
      (name: lang: lang.lspsAndRuntimeDeps)
      languages;

    debug = builtins.mapAttrs
      (name: lang: lang.debug)
      languages;

    formatters = builtins.mapAttrs
      (name: lang: lang.formatter)
      languages;

    linters = builtins.mapAttrs
      (name: lang: lang.linter)
      languages;
  };

  # availableLanguages: List all configured languages
  availableLanguages = [
    "javascript"
    "java"
    "csharp"
    "rust"
    "zig"
    "r"
  ];

  # getLanguageInfo: Get metadata about a language
  #
  # Arguments:
  #   language: string - The language name
  #   languageModules: set - The language modules set
  #
  # Returns:
  #   A set with packageName, appName, lspName, and logo
  getLanguageInfo = language: languageModules:
    let
      mod = languageModules."${language}";
    in
    if builtins.hasAttr language languageModules then
      {
        inherit (mod) packageName appName lspName logo;
      }
    else
      throw "Unknown language: ${language}";
}
