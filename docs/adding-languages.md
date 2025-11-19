# Guide to Adding a New Language

This guide walks you through adding support for a new programming language to this Neovim configuration. We'll use a hypothetical language called "MyLang" as an example.

## Prerequisites

- Familiarity with Nix syntax (see [CONTRIBUTING.md](../CONTRIBUTING.md) for style guide)
- Understanding of the language's ecosystem (LSP server, formatter, debugger)
- Basic knowledge of Lua and Neovim configuration

## Step-by-Step Guide

### Step 1: Research the Language Tooling

Before starting, gather information about your language's development tools:

**Essential**:
- [ ] Language Server Protocol (LSP) server name and package
- [ ] File extensions (e.g., `.mylang`)
- [ ] Package manager availability in nixpkgs

**Optional but Recommended**:
- [ ] Code formatter (e.g., `myformat`)
- [ ] Debugger/Debug Adapter (e.g., `mydbg`)
- [ ] Linter (e.g., `mylint`)
- [ ] Test framework

**Resources**:
- Search [nixpkgs](https://search.nixos.org/packages) for package availability
- Check [lspconfig](https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/) for LSP server names
- Check [nvim-dap](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation) for DAP support

### Step 2: Create the Language Module

Create a new file `nix/languages/mylang.nix`:

```nix
# Zig language configuration
{ pkgs }:

{
  # LSP server and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    my-language-server
    # Add any required build tools
    my-build-tool
  ];

  # Debug adapter (leave empty [] if not available)
  debug = with pkgs; [
    my-debugger
    # or: debug = [];
  ];

  # Code formatter
  formatter = with pkgs; [
    my-formatter
  ];

  # Linter name (optional)
  linter = "my-linter";

  # Package naming
  packageName = "mylangvim";
  appName = "mylangvim";

  # ASCII art logo (6 lines recommended, consistent with other logos)
  logo = ''
    ███╗   ███╗██╗   ██╗██╗      █████╗ ███╗   ██╗ ██████╗
    ████╗ ████║╚██╗ ██╔╝██║     ██╔══██╗████╗  ██║██╔════╝
    ██╔████╔██║ ╚████╔╝ ██║     ███████║██╔██╗ ██║██║  ███╗
    ██║╚██╔╝██║  ╚██╔╝  ██║     ██╔══██║██║╚██╗██║██║   ██║
    ██║ ╚═╝ ██║   ██║   ███████╗██║  ██║██║ ╚████║╚██████╔╝
    ╚═╝     ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝
  '';

  # LSP server name (as used in lspconfig)
  lspName = "my_language_server";
}
```

**Tips**:
- Check existing language modules in `nix/languages/` for patterns
- Ensure all packages exist in nixpkgs (use `nix search nixpkgs my-formatter`)
- For debuggers, prioritize standard ones: LLDB, GDB, or language-specific adapters

### Step 3: Update flake.nix

Add your language to the language definitions in `flake.nix`:

#### In `categoryDefinitions`:

```nix
mylang = (import ./nix/languages/mylang.nix { inherit pkgs; }).lspsAndRuntimeDeps;
```

#### In `debugPkgs`:

```nix
mylang = (import ./nix/languages/mylang.nix { inherit pkgs; }).debug;
```

#### In `extraCats`:

```nix
mylang = [
  [ "debug" "mylang" ]
];
```

#### Create the package definition (use `mkLanguagePackage`):

```nix
mylangvim = nixpkgs.legacyPackages.${system}.callPackage ./nixCatsBuilder.nix {
  system = system;
  categories = {
    general = true;
    LSPs = true;
    mylang = true;
    debug = (!(builtins.elem system disabledSystems));
    format = true;
    lint = true;
  };
  categoryDefinitions = categoryDefinitions;
};
```

### Step 4: Configure LSP

Edit `lua/myLuaConf/LSPs/init.lua` and add your language server configuration:

```lua
if nixCats('mylang') then
  servers.my_language_server = {
    settings = {
      -- Language-specific settings
      myLangOption = true,
      linter = {
        enabled = true,
      },
    },
    filetypes = { 'mylang', 'ext2', 'ext3' },  -- Add relevant extensions
  }
end
```

**Configuration Tips**:
- Check the language server's documentation for available settings
- Common settings: `diagnostics`, `hints`, `formatting`, `codeActions`
- Test with `:LspInfo` after applying

**Example**: Rust configuration

```lua
if nixCats('rust') then
  servers.rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        checkOnSave = true,
        check = {
          command = 'clippy',
          allFeatures = true,
        },
        procMacro = {
          enable = true,
        },
      },
    },
    filetypes = { 'rust' },
  }
end
```

### Step 5: Configure Debugging (Optional)

If a debugger is available, edit `lua/myLuaConf/debug/init.lua`:

```lua
{
  "nvim-dap",
  for_cat = { cat = 'debug.mylang', default = false },
  after = function(plugin)
    local dap = require 'dap'

    -- Configure adapter
    dap.adapters.mylang = {
      type = 'executable',
      command = 'my-debug-adapter',
      args = { '--server', '127.0.0.1:5000' },
    }

    -- Configure launch configurations
    dap.configurations.mylang = {
      {
        name = "Launch",
        type = "mylang",
        request = "launch",
        program = function()
          return vim.fn.input('Program: ', vim.fn.getcwd() .. '/', 'file')
        end,
      },
      {
        name = "Attach",
        type = "mylang",
        request = "attach",
        port = 5000,
      },
    }
  end,
}
```

**Debug Adapter Types**:
- `executable`: Command-line debugger
- `server`: Debug adapter running as a server
- `pipe`: Communication via named pipes

### Step 6: Configure Formatting

Edit `lua/myLuaConf/format/init.lua` and add to `formatters_by_ft`:

```lua
mylang = { "my-formatter" },
```

If your formatter needs special configuration, add to the `formatters` table:

```lua
my_formatter = {
  command = "my-formatter",
  args = { "--option", "value", "--stdin" },
  stdin = true,
},
```

**Common Patterns**:

```lua
-- Simple formatter
rust = { "rustfmt" },

-- Formatter with options
go = {
  "gofmt",
  extra_args = { "-w" },
},

-- Multiple formatters (priority order)
javascript = { "prettier", "eslint_d" },
```

### Step 7: Configure Linting (Optional)

Edit `lua/myLuaConf/lint/init.lua` and add:

```lua
mylang = { 'my-linter' },
```

If you need custom linter configuration:

```lua
linters.my_linter = {
  cmd = 'my-linter',
  stdin = false,
  args = { '--config', '.my-linter-rc' },
  stream = 'stdout',
  ignore_exitcode = false,
  parser = require('lint.parser').from_errorformat('%f:%l:%c: %m'),
}

mylang = { 'my-linter' },
```

### Step 8: Test Your Configuration

#### Build Test

```bash
nix build .#mylangvim
```

Verify no errors occur during build. The build creates:
- A `result/bin/nvim` symlink
- All language tools available at runtime

#### Functional Test

```bash
nix run .#mylangvim
```

Inside Neovim, verify:

```vim
" Check language server
:LspInfo

" Create a test file
:e test.mylang

" Verify completion and diagnostics appear
i  (start typing and verify autocomplete)

" Check formatting
:Format

" Test debugging (if configured)
<leader>b    (set breakpoint)
F5           (start debugging)
```

#### Regression Test

Test that other packages still work:

```bash
nix run .#jsvim     # Test JavaScript
nix run .#rustvim   # Test Rust
nix build           # Full build test
```

### Step 9: Update Documentation

Update these files to document your language:

#### 1. Update `docs/language-packages.md`

Add a section for your language (use Rust section as template):

```markdown
### MyLang (mylangvim)

**Best for**: Description of when to use this language

**Language Server**: `my_language_server`

**Features**:
- ✅ Code completion and IntelliSense
- ✅ Diagnostics and error reporting
- ✅ Code formatting with my-formatter
- ✅ Debugging with my-debugger
- ✅ Testing integration

**Supported Filetypes**: `.mylang`, `.ml`

**Debug Configurations**:
- Launch program
- Attach to process

**Quick Start**:

\`\`\`bash
nix run .#mylangvim
\`\`\`

**Key Commands**:
- `gd`: Go to definition
- `gr`: Go to references
- `<leader>ca`: Code action
- `<leader>rn`: Rename symbol
- `<leader>FF`: Format buffer
```

#### 2. Update `README.md`

Add your package to the feature table:

```markdown
| mylangvim | MyLang | ✅ | ✅ | ✅ | ✅ |
```

#### 3. Create a Getting Started section

Add to `docs/language-packages.md`:

```markdown
### Prerequisites

List any required tools:
- MyLang compiler/runtime version X.Y+
- (Optional) Debug adapter installation

### Installation

```bash
# Package is included in nixCats and all language packages
# Just run:
nix run .#mylangvim
```

### Example Project

[Link to example project repository]
```

### Step 10: Add Treesitter Support (Optional)

If Treesitter grammar for your language is available:

Edit `lua/myLuaConf/plugins/treesitter.lua` and add to `ensure_installed`:

```lua
'mylang',  -- Add to list
```

### Step 11: Submit Your Changes

#### Commit your changes

```bash
# Stage files
git add nix/languages/mylang.nix
git add flake.nix
git add lua/myLuaConf/LSPs/init.lua
git add docs/language-packages.md
git add README.md

# Create detailed commit message
git commit -m "Add MyLang support"
```

#### Create a pull request

Include:
- Language being added: MyLang
- Features supported: LSP, Debug, Format, Lint
- Testing performed: Built, ran, verified LSP
- Any limitations or notes

---

## Example: Adding Swift

Here's a real-world example of adding Swift support:

### Step 1: Research

- LSP: `sourcekit-lsp` (built-in with Swift)
- Formatter: `swiftformat`
- Debugger: `lldb`
- Extensions: `.swift`

### Step 2: Create `nix/languages/swift.nix`

```nix
{ pkgs }:

{
  lspsAndRuntimeDeps = with pkgs; [
    swift
    sourcekit-lsp
    swiftformat
  ];

  debug = with pkgs; [ lldb ];

  formatter = with pkgs; [ swiftformat ];

  linter = "";

  packageName = "swiftvim";
  appName = "swiftvim";

  logo = ''
    ███████╗██╗    ██╗██╗███████╗████████╗
    ██╔════╝██║    ██║██║██╔════╝╚══██╔══╝
    ███████╗██║ █╗ ██║██║███████╗   ██║
    ╚════██║██║███╗██║██║╚════██║   ██║
    ███████║╚███╔███╔╝██║███████║   ██║
    ╚══════╝ ╚══╝╚══╝ ╚═╝╚══════╝   ╚═╝
  '';

  lspName = "sourcekit";
}
```

### Step 3-11: Follow the steps above

---

## Troubleshooting

### Issue: Package not found in nixpkgs

**Solution**:
1. Check if package exists: `nix search nixpkgs my-formatter`
2. Check spelling and case sensitivity
3. Check if it's in unstable channel
4. Consider packaging it yourself (advanced)

### Issue: LSP doesn't start

**Solution**:
1. Check `:LspInfo` for error messages
2. Verify LSP server name matches lspconfig
3. Check `log/lsp.log`: `:edit $NVIM_LOG_DIR/lsp.log`
4. Test LSP manually: `my-language-server --help`

### Issue: Formatting fails silently

**Solution**:
1. Test formatter manually: `echo "code" | my-formatter --stdin`
2. Verify formatter is in PATH: `which my-formatter`
3. Check `:set filetype?` matches formatter configuration
4. Check conform.nvim config in `lua/myLuaConf/format/init.lua`

### Issue: Debugger won't start

**Solution**:
1. Verify debugger is installed: `which my-debugger`
2. Check DAP adapter configuration matches debugger command
3. Ensure debug configuration is correct for your language
4. Check `:messages` for DAP error output

---

## References

- [LSP Configurations](https://github.com/neovim/nvim-lspconfig/blob/master/lua/lspconfig/server_configurations/)
- [DAP Debug Adapters](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation)
- [Treesitter Grammars](https://github.com/nvim-treesitter/nvim-treesitter#supported-languages)
- [conform.nvim Formatters](https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters)
- [nvim-lint Linters](https://github.com/mfussenegger/nvim-lint?tab=readme-ov-file#available-linters)

---

## Getting Help

If you get stuck:

1. Check existing language configurations in `lua/myLuaConf/`
2. Search [GitHub Issues](https://github.com/yourusername/nvim/issues)
3. Ask in [GitHub Discussions](https://github.com/yourusername/nvim/discussions)
4. Consult language-specific documentation
5. See [CONTRIBUTING.md](../CONTRIBUTING.md) for more resources

---

Happy adding! We look forward to your contribution! 🚀
