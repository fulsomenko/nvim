# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### BREAKING

- The default flake output is now `jsvim`, not `nvim`. Use
  `nix run .#jsvim` (or `nix build .#jsvim`). The on-disk binary is still
  named `nvim` (and `vim`) via package aliases, so day-to-day shell usage
  is unchanged.
- The legacy package definition formerly named `nvim` has been removed.
  The example `nixCats` and `regularCats` packages are still present.

### Added

- **JS/TS DX overhaul (`jsvim`)**:
  - ESLint LSP (vscode-eslint-language-server) with `codeActionOnSave`.
  - JSON / CSS / HTML / Tailwind / Emmet / YAML LSPs.
  - SchemaStore.nvim integration for `package.json`, `tsconfig.json`,
    GitHub Actions, etc.
  - Working `vscode-js-debug` DAP setup with launch configs for
    `node`, `tsx`, `npm` script picker, `jest`, `vitest` and the
    pre-existing attach configs.
  - `neotest` with `neotest-jest` and `neotest-vitest` adapters
    (`<leader>tn` / `<leader>tf` / `<leader>ts` / `<leader>to` / `<leader>tw`).
  - `package-info.nvim` for inline npm version info in `package.json`.
  - `nvim-ts-autotag` (auto-close JSX tags) and
    `nvim-ts-context-commentstring` (correct JSX comments).
  - `nvim-autopairs` (general).
- **LSP**:
  - Inlay hints auto-enabled on `LspAttach` for clients that support them,
    with `<leader>th` toggle.
  - `vim.diagnostic.config` configured (rounded float, severity sort,
    bullet virtual_text prefix).
  - Language-aware `root_markers` (no more `{ '.git' }`-only).
  - ts_ls inlay hints + code lens settings.
- **Imports**: `<leader>oi`/`ia`/`ir`/`if` now use the typed code-action
  kinds (`source.organizeImports.ts` etc.) instead of the raw
  `_typescript.organizeImports` command.
- **`:checkhealth jsvim`** reports node/npm/tsc/LSP/formatter/linter
  availability and the attached LSP clients on the current buffer.
- **CI**: `.github/workflows/check.yml` runs `nix flake check` and builds
  every language package on push/PR.

### Changed

- `flake.nix` collapsed: every language package is now built from a
  single `mkLanguagePackage` helper in `nix/lib.nix`, dedup'ing ~600 lines.
- Each `nix/languages/*.nix` is the single source of truth for its
  language: it now declares `formatters`, `linters`, `lspName`,
  runtime deps, and (for js) `js-debug-path`. The lua side reads the
  merged tables via `nixCats.extra("languageConfig.formatters")` /
  `...linters`, so adding a language no longer requires touching
  `lua/myLuaConf/format/init.lua` or `lua/myLuaConf/lint/init.lua`.
- `prettierd` is now wired up for `json`, `jsonc`, `html`, `css`, `scss`,
  `less`, `yaml`, `markdown`, `graphql`, `vue`, `svelte` (in addition to
  the existing js/ts/jsx/tsx).
- `eslint_d` is now wired up as the JS/TS linter via `nvim-lint`.
- `mason-lspconfig` non-Nix path migrated to v2 API
  (`automatic_enable = false` + per-server `vim.lsp.enable`).
- AI / Claude Code is now opt-in per package; only `jsvim`, `nixCats`
  and `regularCats` enable it. The previous global `general -> ai`
  link in `extraCats` has been removed.
- Claude Code toggle moved from `<C-,>` (not transmitted by most
  terminals) to `<leader>ct`.
- `vim.o.clipboard` is no longer set globally; per-key `<leader>y`/`p`
  bindings give explicit control without clobbering registers.

### Fixed

- `nvim-dap-js` no longer references the (non-existent in Nix) Mason
  `node-debug2-adapter`. All `pwa-*` adapters share one server-mode
  spawn of vscode-js-debug's `dapDebugServer.js`.
- ts_ls settings: removed the invalid `displayStringForProperties` /
  `preferDisplayStringForProperties` keys; replaced with valid
  `inlayHints` / `implementationsCodeLens` / `referencesCodeLens` /
  `preferences` settings.
- Format-on-save no longer runs twice (removed the redundant
  `BufWritePre *` autocmd that duplicated `format_on_save`).
- Replaced deprecated APIs: `vim.lsp.get_active_clients`,
  `vim.api.nvim_buf_set_option`, `vim.api.nvim_win_set_option`,
  `vim.api.nvim_buf_get_option`, `vim.lsp.buf.execute_command`,
  `vim.diagnostic.goto_prev`/`goto_next`, `vim.highlight.on_yank`.

### Added

- **Documentation**: Comprehensive guides for installation, language packages, and adding new languages
- **GitHub Templates**: Issue templates (bug reports, feature requests) and pull request template
- **Contributing Guide**: Detailed CONTRIBUTING.md with step-by-step language addition tutorial
- **Language Packages**: Support for Rust (rustvim), Zig (zvim), and R (rvim)
  - Rust: Full LSP, debugging with CodeLLDB, clippy linting, rustfmt formatting
  - Zig: LSP with zls, LLDB debugging, zig fmt formatting
  - R: LSP with language-server, styler formatting, lintr linting
- **Documentation Files**:
  - `docs/installation.md`: Complete installation guide for Nix and non-Nix setups
  - `docs/language-packages.md`: Detailed feature documentation for each language
  - `docs/adding-languages.md`: Step-by-step guide to add new programming languages
- **GitHub Repository Structure**: Professional templates and documentation for open-source collaboration

### Changed

- **README.md**: Complete rewrite with professional documentation structure
  - Added comprehensive feature overview
  - Added available packages table
  - Added quick start instructions
  - Structured debugging configurations documentation
  - Added architecture and troubleshooting sections
- **Debug Configuration**: Removed project-specific debug ports (define:9233, viewer:9231, editor:9236)
  - Configuration now generic and suitable for all projects
- **Plugin Configuration**: Dynamic logo loading from nixCats instead of hardcoded values
- **Gitignore**: Enhanced with comprehensive file patterns
  - Added Nix, Neovim, OS, editor, and build artifact patterns

### Fixed

- LSP TODO comment: Clarified Telescope symbol navigation usage in caps-on_attach.lua
- R-nvim and cmp-r plugin references: Removed unavailable packages from flake.nix
- Generic configuration: Removed project-specific database debug ports from DAP configuration

### Infrastructure

- **License**: Added MIT License for open-source distribution
- **Configuration Quality**: Enhanced for contributor readiness
  - Modular language structure (planned for next phase)
  - Clear contribution guidelines
  - Professional documentation

---

## [1.0.0] - 2025-11-20

### Added

- **Multi-Language Neovim Configuration** using nixCats framework
- **Language Packages**:
  - **jsvim**: JavaScript/TypeScript development with ts_ls, vscode-js-debug, Prettier/Deno formatting, ESLint
  - **jvim**: Java development with Eclipse JDT LSP, vscode-java-debug, Google Java Format
  - **sharpvim**: C# development with OmniSharp, netcoredbg, Roslyn formatting
- **Core Features**:
  - Declarative configuration with Nix flakes
  - Lazy loading with `lze` (instead of lazy.nvim)
  - Conditional feature loading via nixCats categories
  - LSP (Language Server Protocol) integration
  - DAP (Debug Adapter Protocol) debugging support
  - Code formatting with conform.nvim
  - Code linting with nvim-lint
  - Syntax highlighting with Treesitter
- **Debug Configurations**:
  - Node.js ESM and CommonJS debugging
  - Chrome/browser debugging
  - Jest test debugging
  - Java debugging
  - C# debugging
- **Plugins**:
  - Telescope: Fuzzy finder for search and navigation
  - Oil.nvim: File manager
  - Treesitter: Syntax highlighting and parsing
  - nvim-dap: Debug adapter protocol
  - conform.nvim: Code formatting
  - nvim-lint: Code linting
- **Non-Nix Fallback**:
  - paq-nvim for plugin downloads
  - Mason for LSP server management
  - Compatible with non-Nix Neovim installations
- **Configuration**:
  - Modular Lua configuration structure
  - On-attach LSP capabilities and keymaps
  - Custom hover window with improved sizing and scrolling
  - Keybindings for LSP, debugging, formatting, linting
- **Development Environment**:
  - Git repository with proper structure
  - Gitignore configuration
  - Ready for contribution

---

## Version Naming Convention

- **Major**: Breaking changes to architecture or flake structure
- **Minor**: New language packages or significant features
- **Patch**: Bug fixes, documentation updates, configuration improvements

---

## Planned Features

- [ ] **Flake Modularization**: Break flake.nix into `nix/languages/` modules
- [ ] **Additional Languages**: Python, Go, C/C++, Ruby, Lua
- [ ] **Enhanced Testing**: Automated build and runtime tests
- [ ] **Configuration Profiles**: Pre-built configurations for different workflows
- [ ] **Keybinding Documentation**: Interactive keybinding reference
- [ ] **Plugin Ecosystem**: Community-contributed language packages

---

## Migration Guides

### For Users with Custom Configurations

If you've customized this configuration, here are key changes to be aware of:

**Version 1.0 → Unreleased**:
- Debug ports are now project-specific (no longer hardcoded in config)
- Dynamic logo loading: logos are now loaded from nixCats instead of hardcoded
- New language packages available: Rust, Zig, R

No breaking changes to Lua API or keybindings.

---

## How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines, including:
- Setting up your development environment
- Step-by-step guide to add new language support
- Code style guidelines for Nix and Lua
- Testing requirements
- Pull request process

---

## Support

- **Issues**: Report bugs or request features on [GitHub Issues](https://github.com/yourusername/nvim/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/yourusername/nvim/discussions)
- **Documentation**: See `docs/` directory for guides and references

---

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## Acknowledgments

- [nixCats](https://github.com/BirdeeHub/nixCats-nvim): Declarative Neovim configuration framework
- [Neovim](https://neovim.io): The modern Vim fork
- [Nix](https://nixos.org): Declarative package management
- Language communities and tool authors
- Contributors and users who provide feedback and improvements
