# Neovim Multi-Language Configuration with nixCats

A production-ready Neovim configuration built with [nixCats](https://github.com/BirdeeHub/nixCats-nvim), providing comprehensive IDE-like support for multiple programming languages with Language Server Protocol (LSP), debugging, formatting, and linting.

## Features

- **Multi-Language Support**: Dedicated packages for JavaScript/TypeScript, Java, C#, Zig, Rust, and R
- **Language Servers**: Full LSP configuration for code completion, diagnostics, and navigation
- **Advanced Debugging**: DAP (Debug Adapter Protocol) setup with language-specific configurations
- **Code Formatting**: Automatic formatting with language-specific formatters
- **Code Linting**: Real-time code quality checks
- **Plugin Management**: Lazy loading with [lze](https://github.com/BirdeeHub/lze-nvim) instead of lazy.nvim
- **Nix Integration**: Declarative dependency management with Nix flakes

## Quick Start

### Prerequisites

- [Nix](https://nixos.org) with flakes enabled
- Git

### Installation

Clone and enter the configuration:

```bash
git clone https://github.com/yourusername/nvim-config.git
cd nvim-config
nix develop  # or nix flake show to see available packages
```

### Available Packages

Each package provides a specialized Neovim configuration for a specific language ecosystem:

| Package | Language | LSPs | Debugger | Formatter / Linter | Use Case |
|---------|----------|------|----------|--------------------|----------|
| **jsvim** *(default)* | JavaScript / TypeScript | ts_ls, eslint, jsonls, cssls, html, tailwindcss, emmet, yamlls | vscode-js-debug | prettierd / eslint_d | Frontend / Node.js development |
| **rustvim** | Rust | rust-analyzer | CodeLLDB | rustfmt / clippy | Rust development |
| **zvim** | Zig | zls | LLDB | zig fmt | Zig systems programming |
| **jvim** | Java | jdtls | (JDWP attach) | google-java-format | JVM development |
| **sharpvim** | C# | omnisharp | netcoredbg | csharpier | .NET development |
| **rvim** | R | r_language_server | - | styler / lintr | R statistical analysis |

### Using Language-Specific Packages

```bash
# JavaScript/TypeScript development
nix run .#jsvim

# Rust development with debugging
nix run .#rustvim

# Zig development
nix run .#zvim

# R statistical programming
nix run .#rvim

# Java development
nix run .#jvim

# C# .NET development
nix run .#sharpvim
```

### Building Packages

```bash
# Build and install a package
nix build .#rustvim

# Show all available packages
nix flake show
```

## Configuration Structure

```
nvim/
├── flake.nix                  # Nix configuration with package definitions
├── init.lua                   # Neovim entry point
├── lua/myLuaConf/
│   ├── init.lua              # Main Lua configuration
│   ├── opts_and_keys.lua     # Vim options and key mappings
│   ├── LSPs/                 # Language server configurations
│   ├── debug/                # Debug adapter protocol setup
│   ├── format/               # Code formatting configuration
│   ├── lint/                 # Code linting setup
│   └── plugins/              # Individual plugin configurations
├── lua/nixCatsUtils/         # nixCats utilities
└── after/plugin/             # Post-plugin configurations
```

## Key Features by Package

### JavaScript / TypeScript (`jsvim`) — default package

- **LSPs**:
  - `ts_ls` (typescript-language-server) with inlay hints,
    `implementations` and `references` code lenses
  - `eslint` (vscode-eslint-language-server) with `codeActionOnSave`
  - `jsonls` + `yamlls` driven by `SchemaStore.nvim`
  - `cssls`, `html`, `tailwindcss`, `emmet_language_server`
- **Debugging**: vscode-js-debug, run as a server-mode adapter shared by
  every `pwa-*` config:
  - Launch current file with `node` or `tsx`
  - Launch via `npm` script (interactive picker reads `package.json`)
  - Debug Jest test (current file) via `node_modules/.bin/jest`
  - Debug Vitest test (current file)
  - Attach to Node by default port (9229), custom port, or PID picker
  - Attach to / launch Chrome
- **Formatting**: `prettierd` (with `prettier` fallback) for js, ts, jsx,
  tsx, json, jsonc, html, css, scss, less, yaml, markdown, graphql, vue,
  svelte. Run on save via `conform.nvim`, manual via `<leader>FF`.
- **Linting**: `eslint_d` via `nvim-lint` on `BufWritePost` /
  `BufReadPost` / `InsertLeave`.
- **Tests**: `neotest` with `neotest-jest` and `neotest-vitest`:
  `<leader>tn` (nearest), `<leader>tf` (file), `<leader>ts` (summary),
  `<leader>to` (output), `<leader>tw` (watch).
- **Imports** (`<leader>oi` / `ia` / `ir` / `if`): organize, add missing,
  remove unused, fix all — uses typed code-action kinds.
- **package.json** UX (`<leader>n*`): inline npm version info, update,
  delete, install via `package-info.nvim`.
- **JSX**: `nvim-ts-autotag` (auto-close tags) and
  `nvim-ts-context-commentstring` (correct comment tokens inside JSX).
- **Health check**: `:checkhealth jsvim` reports tooling availability and
  attached LSP clients.

### Rust (rustvim)

- **LSP**: rust-analyzer with clippy integration for advanced linting
- **Debugging**: CodeLLDB for LLVM-based debugging
- **Formatting**: rustfmt for Rust code standards
- **Tools**: Cargo integration, clippy linting, all-features support
- **Configurations**:
  - Debug and release binary launching
  - Test execution and debugging
  - Process attachment

### Zig (zvim)

- **LSP**: zls (Zig Language Server) with semantic tokens and inlay hints
- **Debugging**: LLDB for Zig program debugging
- **Formatting**: zig fmt integration
- **Configurations**: Program launch, test launch, process attachment

### R (rvim)

- **LSP**: R languageserver with rich documentation
- **Formatting**: styler for R code formatting
- **Linting**: lintr for code quality
- **Format Support**: .r, .rmd (R Markdown), .qmd (Quarto)
- **Features**: Multi-format support for statistical analysis and reporting

### Java (jvim) and C# (sharpvim)

See flake.nix for detailed language-specific configurations.

## Debug Configurations

### General Debug Usage

**Key Bindings:**
- `<F5>` - Start/Continue debugging
- `<F1>` - Step Into
- `<F2>` - Step Over
- `<F3>` - Step Out
- `<leader>b` - Toggle Breakpoint
- `<leader>B` - Set Conditional Breakpoint
- `<F7>` - Toggle DAP UI

### JavaScript/TypeScript Debugging

Available configurations:
1. Attach to Node.js (default port 9229)
2. Attach to Node.js (custom port)
3. Attach to running Node process (picker)
4. Launch Chrome/Browser with custom URL
5. Service-specific attach points

**Start debugging:**
```bash
# Terminal 1: Run your application with debug flag
node --inspect=9229 app.js

# Terminal 2: Open Neovim and press F5 to attach
nvim app.js
```

### Rust Debugging

Available configurations:
1. Launch Rust Program (Debug build)
2. Launch Rust Program (Release build)
3. Run Rust tests
4. Attach to running process

### Zig Debugging

Available configurations:
1. Launch Zig Program (from zig-out/bin/)
2. Launch Zig Test (from zig-cache/)
3. Attach to running process

## Formatting & Linting

### Automatic Formatting

Files are automatically formatted on save with:
- JavaScript/TypeScript: Prettier
- Rust: rustfmt
- Zig: zig fmt
- R: styler

Press `<leader>FF` to manually format the current file.

### Linting

Code quality checks run on buffer write / read / insert-leave:
- JavaScript / TypeScript: `eslint_d` (via `nvim-lint`)
- Rust: clippy (integrated via rust-analyzer's `check.command`)
- R: `lintr`

## Customization

### Modifying Options and Keymaps

Edit `lua/myLuaConf/opts_and_keys.lua` to customize:
- Vim options
- Key mappings
- Leader key bindings

### Adding Plugins

1. Add plugin to nixpkgs or create custom overlay
2. Reference in flake.nix under appropriate category
3. Configure in `lua/myLuaConf/plugins/`

### Creating a Custom Package

Every language package is built with the `mkLanguagePackage` helper in
`nix/lib.nix`. To add a new language `foo`:

1. Create `nix/languages/foo.nix` declaring `lspsAndRuntimeDeps`,
   `formatters`, `linters`, `lspName`, `packageName`, `appName`, `logo`.
2. Add it to the `languageModules` set in `nix/lib.nix`.
3. Add a one-liner output in `flake.nix`:

```nix
foovim = moxLib.mkLanguagePackage { language = "foo"; };
```

4. Optionally extend `lua/myLuaConf/LSPs/init.lua` with an
   `if nixCats('foo') then servers.foo_ls = { ... } end` block.

The lua side reads formatters/linters automatically from the merged
language tables passed via `nixCats.extra("languageConfig.*")`.

## Architecture

This configuration uses:

- **[nixCats](https://github.com/BirdeeHub/nixCats-nvim)**: Declarative Neovim configuration framework
- **[lze](https://github.com/BirdeeHub/lze-nvim)**: Lazy plugin loader with category support
- **Nix Flakes**: Reproducible dependency management
- **LSPConfig**: Neovim's standard LSP configuration
- **DAP**: Debug Adapter Protocol for debugging support
- **Conform.nvim**: Formatting management
- **nvim-lint**: Linting support

### Design Philosophy

- **Declarative**: All dependencies and configurations defined in Nix
- **Modular**: Language support can be enabled/disabled per package
- **Reproducible**: Nix ensures everyone gets the same environment
- **Zero Secrets**: No credentials or personal information in configuration

## Troubleshooting

### LSP Not Working

1. Verify the language package is enabled:
   ```bash
   nvim --version  # Check NVIM version
   ```

2. Check LSP status in Neovim:
   ```vim
   :LspInfo
   ```

3. Enable debug logging:
   ```vim
   :set loglevel=debug
   ```

### Debugging Not Starting

1. Ensure debug category is enabled for your language
2. Check debug adapter installation: `:checkhealth`
3. Verify you're using the correct debug configuration for your language

### Plugin Issues

1. Clear plugin cache:
   ```bash
   rm -rf ~/.cache/nvim
   ```

2. Rebuild the flake:
   ```bash
   nix flake update
   ```

## Contributing

Contributions are welcome! To add support for a new language:

1. Define the language in `flake.nix`:
   - Add LSP server to `lspsAndRuntimeDeps`
   - Add debug adapter if available
   - Add formatter package
   - Add debug category to `extraCats`

2. Configure LSP in `lua/myLuaConf/LSPs/init.lua`

3. Add debug configurations in `lua/myLuaConf/debug/init.lua`

4. Add formatter in `lua/myLuaConf/format/init.lua`

5. Create a new package definition following the existing patterns

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Performance Notes

- First launch may take time due to plugin compilation
- Subsequent launches are cached by Nix
- Use `:StartupTime` to profile startup performance

## License

MIT License - see [LICENSE](LICENSE) for details

## Related Projects

- [nixCats](https://github.com/BirdeeHub/nixCats-nvim) - Neovim configuration framework
- [lze](https://github.com/BirdeeHub/lze-nvim) - Lazy plugin loader
- [Neovim](https://neovim.io/) - Hyperextensible Vim-based text editor

## Support

For issues and feature requests, please open an issue on GitHub. For general Neovim questions, see the [Neovim documentation](https://neovim.io/doc/).

---

**Made with ❤️ using Nix and Neovim**
