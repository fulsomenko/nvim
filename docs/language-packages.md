# Language Packages

This document provides detailed information about each language package and its features.

## Overview

This project provides pre-configured Neovim packages for different programming languages. Each package includes:

- **LSP (Language Server Protocol)**: Intelligent code completion, diagnostics, and navigation
- **Debugging**: Debug Adapter Protocol (DAP) integration for stepping through code
- **Formatting**: Automatic code formatting with language-specific formatters
- **Linting**: Code quality checks and style warnings
- **Syntax Highlighting**: Treesitter-based syntax highlighting
- **Additional Tools**: Language-specific plugins and utilities

## Available Packages

### JavaScript/TypeScript (jsvim)

**Best for**: Frontend and Node.js development

**Language Server**: `ts_ls` (TypeScript Language Server)

**Features**:
- ✅ Full IntelliSense with code completion
- ✅ Type checking and diagnostics
- ✅ Refactoring (rename, extract, etc.)
- ✅ Jump to definition, references, implementations
- ✅ Automatic debugging with vscode-js-debug
- ✅ Code formatting with Prettier or Deno
- ✅ ESLint integration for linting

**Supported Filetypes**: `.ts`, `.tsx`, `.js`, `.jsx`, `.json`, `.jsonc`

**Debug Configurations**:
- Launch Node.js program (CommonJS and ESM)
- Debug npm scripts
- Launch Chrome browser
- Attach to running Node process
- Debug Jest tests (ESM and CommonJS)

**Quick Start**:

```bash
nix run .#jsvim

# Then in Neovim:
nvim app.ts
:LspInfo              # Verify language server
<leader>FF            # Format file
F5                    # Start debugging
```

**Key Commands**:
- `gd`: Go to definition
- `gr`: Go to references (Telescope)
- `<leader>ca`: Code action
- `<leader>rn`: Rename symbol
- `K`: Hover documentation
- `<leader>FF`: Format buffer

**Example Configuration** (in `flake.nix`):

```nix
jsvim = nixpkgs.legacyPackages.${system}.callPackage ./nixCatsBuilder.nix {
  categories = {
    general = true;
    LSPs = true;
    jsvim = true;
    debug = true;
    format = true;
    lint = true;
  };
  categoryDefinitions = categoryDefinitions;
};
```

---

### Java (jvim)

**Best for**: Enterprise Java development and Android

**Language Server**: `java_language_server` (Eclipse JDT Language Server)

**Features**:
- ✅ Complete IntelliSense and code completion
- ✅ Type checking and diagnostics
- ✅ Maven/Gradle support
- ✅ Debugging with vscode-java-debug
- ✅ Test running and debugging
- ✅ Code formatting with Google Java Format
- ✅ Checkstyle integration for linting

**Supported Filetypes**: `.java`, `.class`

**Debug Configurations**:
- Launch Java application
- Attach to running JVM
- Debug JUnit tests

**Prerequisites**:
- Java JDK 11 or later (Eclipse Temurin or OpenJDK recommended)
- Maven 3.6+ or Gradle 6.5+ (for projects)

**Quick Start**:

```bash
nix run .#jvim

# Then in Neovim:
nvim Main.java
:LspInfo              # Verify language server
F5                    # Start debugging
```

**Key Commands**:
- `gd`: Go to definition
- `<leader>ca`: Code action (generate getters/setters, etc.)
- `<leader>rn`: Rename class or method
- `<leader>FF`: Format file
- `K`: Hover for Javadoc

**Known Limitations**:
- First startup may take time as JLS downloads dependencies
- Requires adequate heap memory (-Xmx parameter configurable)

---

### C# (sharpvim)

**Best for**: .NET development (Console, ASP.NET, Unity)

**Language Server**: `omnisharp` (OmniSharp language server)

**Features**:
- ✅ IntelliSense with code completion
- ✅ Type checking and diagnostics
- ✅ Project structure understanding
- ✅ Debugging with netcoredbg
- ✅ Code formatting with Roslyn
- ✅ Refactoring support (rename, extract, etc.)
- ✅ Test support for xUnit and NUnit

**Supported Filetypes**: `.cs`, `.csx`

**Debug Configurations**:
- Launch .NET console application
- Attach to running process
- Debug xUnit/NUnit tests

**Prerequisites**:
- .NET SDK 6.0 or later
- Mono 5.10+ (for some features)

**Quick Start**:

```bash
nix run .#sharpvim

# Then in Neovim:
nvim Program.cs
:LspInfo              # Verify language server
F5                    # Start debugging
```

**Key Commands**:
- `gd`: Go to definition
- `gr`: Go to references
- `<leader>ca`: Code action
- `<leader>rn`: Rename symbol
- `<leader>FF`: Format file

---

### Rust (rustvim)

**Best for**: Systems programming and performance-critical applications

**Language Server**: `rust-analyzer`

**Features**:
- ✅ IntelliSense with intelligent code completion
- ✅ Advanced type checking and diagnostics
- ✅ Clippy linting for code quality
- ✅ Debugging with CodeLLDB
- ✅ Code formatting with rustfmt
- ✅ Macro expansion support
- ✅ Test running and debugging

**Supported Filetypes**: `.rs`, `.toml`

**Debug Configurations**:
- Launch binary (debug and release builds)
- Debug tests
- Attach to running process
- Debug with LLDB

**Prerequisites**:
- Rust toolchain (via rustup)
- LLDB debugger (`brew install lldb` on macOS, `apt install lldb` on Linux)

**Quick Start**:

```bash
nix run .#rustvim

# Then in Neovim:
nvim src/main.rs
:LspInfo              # Verify language server
<leader>FF            # Format with rustfmt
F5                    # Start debugging
```

**Key Commands**:
- `gd`: Go to definition
- `gr`: Go to references
- `<leader>ca`: Code action (suggest imports, expand macros)
- `<leader>rn`: Rename symbol
- `K`: Hover for documentation
- `<leader>FF`: Format with rustfmt

**Linting**:
- **clippy**: Run `cargo clippy` for code quality checks
- Integrated via rust-analyzer

**Useful Cargo Commands**:
```bash
cargo build              # Build debug binary
cargo build --release   # Build optimized binary
cargo test              # Run tests
cargo clippy            # Run linter
```

---

### Zig (zvim)

**Best for**: Systems programming with simplicity and compile-time power

**Language Server**: `zls` (Zig Language Server)

**Features**:
- ✅ Code completion and IntelliSense
- ✅ Compile diagnostics and error reporting
- ✅ Code formatting with `zig fmt`
- ✅ Debugging with LLDB
- ✅ Build system integration
- ✅ Documentation hover

**Supported Filetypes**: `.zig`, `.zls`

**Debug Configurations**:
- Launch Zig program
- Debug tests
- Attach to running process

**Prerequisites**:
- Zig compiler (latest stable or nightly)
- LLDB debugger

**Quick Start**:

```bash
nix run .#zvim

# Then in Neovim:
nvim main.zig
:LspInfo              # Verify language server
<leader>FF            # Format with zig fmt
F5                    # Start debugging
```

**Key Commands**:
- `gd`: Go to definition
- `<leader>ca`: Code action
- `<leader>FF`: Format with zig fmt
- `K`: Hover for documentation

**Building**:
```bash
zig build              # Build using build.zig
zig test main.zig      # Run tests
```

---

### R (rvim)

**Best for**: Statistical computing and data analysis

**Language Server**: `r-language-server`

**Features**:
- ✅ Code completion and IntelliSense
- ✅ Diagnostic feedback
- ✅ Code formatting with styler
- ✅ Linting with lintr
- ✅ Package management integration
- ✅ Documentation lookup

**Supported Filetypes**: `.r`, `.R`, `.rmd`, `.qmd`

**Prerequisites**:
- R runtime (R 3.6+)
- R packages: `languageserver`, `styler`, `lintr`

**Installation** (in R console):

```r
install.packages("languageserver")
install.packages("styler")
install.packages("lintr")
```

**Quick Start**:

```bash
nix run .#rvim

# Then in Neovim:
nvim analysis.R
:LspInfo              # Verify language server
<leader>FF            # Format with styler
```

**Key Commands**:
- `gd`: Go to definition
- `gr`: Go to references
- `K`: Hover for documentation
- `<leader>FF`: Format with styler

**Linting**:
- **lintr**: Integrated code quality checks
- Appears as diagnostics in code

---

## General Package (nvim)

**Best for**: Multi-language development with all features enabled

The `nvim` package includes:
- All language support (JavaScript, Java, C#, Rust, Zig, R)
- All plugins and features
- Telescope fuzzy finder
- Oil file manager
- Treesitter for all supported languages
- DAP debugging for all languages
- Formatting and linting for all languages

**Quick Start**:

```bash
nix run .#nvim
```

---

## Feature Comparison

| Feature | jsvim | jvim | sharpvim | rustvim | zvim | rvim |
|---------|-------|------|----------|---------|------|------|
| LSP | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Debugging | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Formatting | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Linting | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Testing | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Refactoring | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

---

## Common Workflows

### Opening a Project

```bash
# Clone or navigate to your project
cd ~/myproject

# Run the appropriate language package
nix run .#jsvim        # For TypeScript project
nix run .#rustvim      # For Rust project

# Or from Neovim:
nvim .                 # Open current directory
```

### Coding with LSP

1. Open a file: `nvim file.ts`
2. Position cursor: `g` (normal mode)
3. **Go to Definition**: `gd`
4. **Go to References**: `gr` (Telescope)
5. **Code Action**: `<leader>ca` (hover over error)
6. **Rename**: `<leader>rn`
7. **Hover**: `K`

### Formatting Code

```vim
" Format entire buffer
:Format

" Or press
<leader>FF
```

### Debugging with DAP

```vim
" Set breakpoint
<leader>b

" Start debugging
F5

" Step over
F2

" Step into
F1

" Step out
F3

" Continue
<leader>c

" Terminate
<leader>q
```

### Running Tests

Depends on language:

```bash
# JavaScript
npm test              # Run Jest or your test runner

# Rust
cargo test            # Run Rust tests

# Zig
zig test main.zig     # Run Zig tests

# R (in R console)
testthat::test_dir("tests/")
```

---

## Troubleshooting by Language

### JavaScript/TypeScript Issues

**Problem**: "Cannot find module" errors
- **Solution**: Run `npm install` to install dependencies

**Problem**: Formatter not working
- **Solution**: Install Prettier: `npm install -D prettier`

---

### Rust Issues

**Problem**: "error: linker 'cc' not found"
- **Solution**: Install build tools (`build-essential` on Linux, Xcode on macOS)

**Problem**: LLDB not found
- **Solution**: Install LLDB: `brew install lldb` (macOS) or `apt install lldb` (Linux)

---

### R Issues

**Problem**: Language server not connecting
- **Solution**: In R console: `install.packages("languageserver")`

---

## Language Server Status

Check language server status and see documentation:

```vim
:LspInfo                 " Show active LSP servers
:LspStart <servername>   " Start a specific server
:LspStop <servername>    " Stop a specific server
```

---

## Further Reading

- [Neovim LSP Documentation](https://neovim.io/doc/user/lsp.html)
- [DAP Documentation](https://github.com/mfussenegger/nvim-dap)
- [Telescope Documentation](https://github.com/nvim-telescope/telescope.nvim)
- Language-specific docs are available by pressing `K` over symbols in code

## Contributing

Found an issue with a language package? See [CONTRIBUTING.md](../CONTRIBUTING.md) for how to report bugs and submit improvements.
