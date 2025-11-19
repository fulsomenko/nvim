# Installation Guide

This guide provides step-by-step instructions for installing and using the Neovim multi-language configuration.

## Prerequisites

### System Requirements

- **Neovim**: Version 0.11.4 or later
- **Nix**: With flakes enabled (recommended)
- **Git**: For cloning the repository

### Optional Requirements

- **Node.js**: For JavaScript/TypeScript development (jsvim)
- **Rust**: For Rust development (rustvim)
- **Java JDK**: For Java development (jvim)
- **.NET SDK**: For C# development (sharpvim)
- **Zig**: For Zig development (zvim)
- **R**: For R development (rvim)

## Installation with Nix (Recommended)

The easiest way to get started is using Nix with flakes.

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/nvim.git
cd nvim
```

### Step 2: Enter the Development Environment

```bash
nix develop
```

This drops you into a shell with Neovim and all dependencies pre-configured.

### Step 3: Run Neovim

```bash
nvim
```

### Step 4: Run a Specific Language Package

To run a specific language package directly:

```bash
# JavaScript/TypeScript
nix run .#jsvim

# Rust
nix run .#rustvim

# Java
nix run .#jvim

# C#
nix run .#sharpvim

# Zig
nix run .#zvim

# R
nix run .#rvim

# General Neovim (all features)
nix run .#nvim
```

### Step 5: Build a Package

To build a specific package and keep it for later use:

```bash
nix build .#jsvim
```

This creates a `result` symlink with the built package. Run it with:

```bash
./result/bin/nvim
```

## Installation Without Nix

If you prefer not to use Nix, the configuration includes a fallback system using `paq-nvim` for plugin management and `mason.nvim` for language server installation.

### Step 1: Install Neovim

Install Neovim 0.11.4 or later:

```bash
# macOS with Homebrew
brew install neovim

# Ubuntu/Debian
sudo apt install neovim

# Build from source
git clone https://github.com/neovim/neovim
cd neovim && make CMAKE_BUILD_TYPE=Release && sudo make install
```

### Step 2: Clone the Configuration

```bash
git clone https://github.com/yourusername/nvim.git ~/.config/nvim
cd ~/.config/nvim
```

### Step 3: Install Language Servers (Optional)

The configuration uses `mason.nvim` to automatically install language servers. When you first open a file:

1. Open a file with a supported language
2. You'll see a notification about missing language servers
3. Type `:Mason` to open Mason UI and install servers manually, or
4. The config will attempt auto-installation

Alternatively, install language servers manually:

```bash
# TypeScript/JavaScript
npm install -g typescript-language-server typescript

# Rust (via rustup)
rustup component add rust-analyzer

# Java (via AdoptOpenJDK or GraalVM)
# Then install Language Server for Java via Extension in VS Code, or:
# Download from https://github.com/eclipse/eclipse.jdt.ls/releases

# C#
dotnet tool install -g OmniSharp

# Zig
# Download ZLS from https://github.com/zigtools/zls/releases

# R
# Start R and install languageserver package:
# install.packages("languageserver")
```

### Step 4: Run Neovim

```bash
nvim
```

## First Run

On your first run, the configuration will:

1. Download and install plugins (if using non-Nix)
2. Install language servers (if using non-Nix with Mason)
3. Generate highlight groups and initialize treesitter

This may take a minute or two on first launch. Subsequent launches will be much faster.

## Verification

### Check Installation

After installation, verify everything is working:

1. Open Neovim: `nvim`
2. Run `:checkhealth` to see configuration status
3. Check language servers: `:LspInfo`

Expected output from `:checkhealth`:
- ✓ nvim version OK
- ✓ Python provider OK (if using telescope)
- ✓ Node provider OK (if using LSP)
- ✓ Ruby provider OK (if enabled)

### Test Language Servers

Create a test file for your language:

```bash
# JavaScript/TypeScript
echo "const x: number = 5;" > test.ts
nvim test.ts

# Rust
echo "fn main() { println!(\"Hello!\"); }" > main.rs
nvim main.rs
```

In Neovim, type `:LspInfo` to verify the language server is running.

### Test Formatting

With a language file open, press `<leader>FF` to format the file.

### Test Debugging (if configured)

Press `F5` to start debugging. You should see the DAP debugger interface.

## Configuration Customization

### Create Custom Package

To create a custom package with only the language you need:

Edit `flake.nix` and add a new package definition:

```nix
mycustom = nixpkgs.legacyPackages.${system}.callPackage ./nixCatsBuilder.nix {
  system = system;
  categories = {
    general = true;
    LSPs = true;
    jsvim = true;
    debug = true;
    format = true;
  };
  categoryDefinitions = categoryDefinitions;
};
```

Then run:

```bash
nix run .#mycustom
```

### Disable Features

To reduce bloat, you can disable features in the configuration:

1. Edit `flake.nix` and remove categories from your package
2. Or, modify `lua/myLuaConf/` files directly to remove features

For example, to disable debugging:

```nix
categories = {
  debug = false;  # Set to false
  # ... other categories
};
```

## Troubleshooting

### Issue: Language Server Not Found

**Solution**:
- With Nix: Ensure you're in `nix develop` or running the correct `nix run .#package`
- Without Nix: Run `:Mason` and install the language server manually

### Issue: Plugins Not Loading

**Solution**:
- Check `:checkhealth` for errors
- Clear plugin cache: `rm -rf ~/.cache/nvim`
- Check `~/.local/share/nvim/site/` for plugin files (non-Nix)

### Issue: Formatting Not Working

**Solution**:
- Verify formatter is available: `:Mason` or `which <formatter>`
- Check `:LspInfo` to ensure LSP is running
- Verify configuration in `lua/myLuaConf/format/init.lua`

### Issue: Debugging Not Starting

**Solution**:
- Verify DAP adapter is installed: `:Mason`
- Check debug configuration for your language
- Ensure you're in the correct directory when debugging
- Check `:LspInfo` - some DAP features depend on LSP

### Issue: Treesitter Highlighting Broken

**Solution**:
- Update treesitter: `:TSUpdate`
- Clear cache: `rm -rf ~/.cache/nvim`
- Verify treesitter parser: `:TSInstall <language>`

## Next Steps

After installation:

1. **Read the README**: See `README.md` for feature overview
2. **Check Language Docs**: See `docs/language-packages.md` for language-specific info
3. **Learn Keybindings**: See keymap definitions in `lua/myLuaConf/opts_and_keys.lua`
4. **Customize Configuration**: Modify `lua/myLuaConf/` files to suit your needs
5. **Contributing**: See `CONTRIBUTING.md` if you want to contribute

## Getting Help

- **Documentation**: Check the `docs/` directory
- **Issues**: Search [GitHub Issues](https://github.com/yourusername/nvim/issues)
- **Discussions**: Ask questions in [GitHub Discussions](https://github.com/yourusername/nvim/discussions)
- **Neovim Help**: Use `:help <topic>` inside Neovim
- **LSP Help**: Check specific LSP documentation for your language

## Uninstallation

### With Nix

Simply remove the cloned directory:

```bash
rm -rf ~/path/to/nvim
```

### Without Nix

Remove the configuration:

```bash
rm -rf ~/.config/nvim
rm -rf ~/.cache/nvim  # Optional: clear cache
```

Your system Neovim will revert to default configuration.

## Keeping Updated

To get the latest updates:

```bash
cd ~/path/to/nvim
git pull origin main

# With Nix:
nix flake update
```

Then rebuild the package:

```bash
nix build .#<package>
# or
nix flake update && nix develop
```
