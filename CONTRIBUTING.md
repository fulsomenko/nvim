# Contributing to Neovim Multi-Language Configuration

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Report issues responsibly

## Getting Started

### Prerequisites

- [Nix](https://nixos.org) with flakes enabled
- Basic understanding of Nix syntax
- Basic understanding of Lua and Neovim
- Git

### Setup Development Environment

```bash
git clone https://github.com/yourusername/nvim-config.git
cd nvim-config
nix develop
```

## How to Add a New Language Package

Follow this step-by-step guide to add support for a new programming language.

### Step 1: Create Language Module

Create a new file `nix/languages/mylang.nix`:

```nix
{ pkgs }:

{
  # LSP server(s) and runtime dependencies
  lspsAndRuntimeDeps = with pkgs; [
    my-language-server
    # Add any required build tools
  ];

  # Debug adapter (if available)
  debug = with pkgs; [
    my-debugger
    # or leave empty: []
  ];

  # Code formatter
  formatter = with pkgs; [
    my-formatter
  ];

  # Linter (if available)
  linter = "my-linter";

  # Package definition
  packageName = "mylangvim";
  appName = "mylangvim";

  logo = ''
    Your ASCII art logo here
    (6 lines recommended, consistent style)
  '';

  # LSP server name (as used in lspconfig)
  lspName = "my_language_server";
}
```

### Step 2: Update flake.nix

Add your language to the imports section:

```nix
# In flake.nix, add to categoryDefinitions:
mylang = (import ./nix/languages/mylang.nix { inherit pkgs; }).lspsAndRuntimeDeps;

# In debug section:
mylang = (import ./nix/languages/mylang.nix { inherit pkgs; }).debug;

# In extraCats section:
mylang = [
  [ "debug" "mylang" ]
];

# Create package definition using mkLanguagePackage helper
mylangvim = mkLanguagePackage {
  language = "mylang";
  logo = (import ./nix/languages/mylang.nix { inherit pkgs; }).logo;
};
```

### Step 3: Configure LSP

Edit `lua/myLuaConf/LSPs/init.lua` and add:

```lua
if nixCats('mylang') then
  servers.my_language_server = {
    settings = {
      -- Your LSP settings here
    },
    filetypes = { 'mylang', 'ext2', 'ext3' },
  }
end
```

### Step 4: Configure Debugging (If Available)

Edit `lua/myLuaConf/debug/init.lua` and add:

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
    }

    -- Configure launch/attach configurations
    dap.configurations.mylang = {
      {
        name = "Launch",
        type = "mylang",
        request = "launch",
        program = function()
          return vim.fn.input('Program: ', vim.fn.getcwd() .. '/', 'file')
        end,
      },
    }
  end,
}
```

### Step 5: Configure Formatting

Edit `lua/myLuaConf/format/init.lua` and add to `formatters_by_ft`:

```lua
mylang = { "my-formatter" },
```

If your formatter needs special configuration, add to `formatters` table:

```lua
my_formatter = {
  command = "my-formatter",
  args = { "--option", "value", "--stdin" },
  stdin = true,
},
```

### Step 6: Configure Linting (Optional)

Edit `lua/myLuaConf/lint/init.lua` and add:

```lua
mylang = { 'my-linter' },
```

### Step 7: Test Your Configuration

```bash
# Build the new package
nix build .#mylangvim

# Test it
nix run .#mylangvim

# Verify LSP works
# In Neovim: :LspInfo

# Test debugging (if configured)
# In Neovim: Press F5 to start debug session
```

### Step 8: Update Documentation

- Update `docs/language-packages.md` to include your language
- Update README.md package table
- Update CHANGELOG.md with new feature

### Step 9: Submit Pull Request

1. Commit your changes with clear messages
2. Push to your fork
3. Create a pull request with description of:
   - Language being added
   - Which features are supported (LSP, debug, format, lint)
   - Any special notes for users

## Code Style Guidelines

### Nix Code

- Use 2-space indentation
- Keep lines under 100 characters when possible
- Use meaningful variable names
- Comment complex logic
- Use `with pkgs;` for brevity in package lists

Example:
```nix
{
  lspsAndRuntimeDeps = with pkgs; [
    my-language-server
    my-formatter
  ];
}
```

### Lua Code

- Use 2-space indentation
- Use `vim.keymap.set()` for keymaps (not `nmap`, `imap`, etc.)
- Use `require()` with parentheses: `require('module')`
- Comment unclear code
- Keep functions focused and single-purpose

Example:
```lua
if nixCats('mylang') then
  servers.my_language_server = {
    settings = {
      -- Description of setting
      setting_name = true,
    },
  }
end
```

### Commit Messages

- Use present tense: "Add feature" not "Added feature"
- Be specific: "Add Python LSP with debugging" not "Update config"
- Reference issues when relevant: "Fixes #123"
- Keep first line under 50 characters
- Add detailed description in body if needed

Example:
```
Add Python language package with debugging

- Configure pyright as LSP server
- Add debugpy for Python debugging
- Include black formatter and pylint
- Support both launch and attach debugging

Fixes #45
```

## Testing Guidelines

### Before Submitting a PR

1. **Build Test**: Ensure the package builds
   ```bash
   nix build .#mylangvim
   ```

2. **Functional Test**: Verify features work
   ```bash
   nix run .#mylangvim
   # Inside Neovim:
   # - Open a file with your language
   # - Verify :LspInfo shows the server
   # - Test formatting: <leader>FF
   # - Test debugging: F5 (if configured)
   # - Test keybindings work
   ```

3. **No Regressions**: Test other packages still work
   ```bash
   nix run .#jsvim    # Test JavaScript
   nix run .#rustvim  # Test Rust
   ```

4. **Formatting**: Ensure Lua code is well-formatted
   ```bash
   # Manual check for consistent style
   ```

### What to Test

- [ ] LSP server starts and connects
- [ ] Code completion works
- [ ] Diagnostics appear
- [ ] Formatting works (if configured)
- [ ] Linting works (if configured)
- [ ] Debugging starts (if configured)
- [ ] All keybindings work
- [ ] No errors in `:checkhealth`

## Documentation Standards

When documenting your contribution:

- **Be clear**: Assume reader is unfamiliar with the language
- **Include examples**: Show how to use the feature
- **Update table of contents**: If adding to docs
- **Link references**: Link to official tool documentation

Example documentation:

```markdown
## MyLanguage (mylangvim)

[MyLanguage](https://example.com/mylang) is a systems programming language.

### Features

- **LSP**: Full IntelliSense with my-language-server
- **Debugging**: LLDB-based debugging with launch/attach
- **Formatting**: Automatic formatting with my-formatter
- **Linting**: Code quality with my-linter

### Quick Start

```bash
nix run .#mylangvim
```

### Configuration

To create a custom package with only MyLanguage:

```nix
mycustom = { pkgs, ... }: {
  settings = {
    configDirName = "nvim";
    wrapRc = true;
  };
  categories = {
    mylang = true;
  };
};
```

### Debugging

Press F5 to start a debug session. Available configurations:
- Launch MyLanguage program
- Attach to running process
```

## Pull Request Process

1. **Fork and Branch**: Create a feature branch
   ```bash
   git checkout -b feature/add-mylanguage
   ```

2. **Make Changes**: Follow the guidelines above

3. **Commit**: Write clear commit messages
   ```bash
   git add .
   git commit -m "Add MyLanguage support with debugging"
   ```

4. **Sign Commits**: Use GPG signing
   ```bash
   git config commit.gpgsign true
   ```

5. **Test**: Run all tests before pushing
   ```bash
   nix build .#mylangvim
   nix run .#mylangvim
   ```

6. **Push**: Push to your fork
   ```bash
   git push origin feature/add-mylanguage
   ```

7. **Create PR**: Use the PR template and fill out all sections
   - Title: "Add MyLanguage support"
   - Description: Explain what/why/how
   - Testing: Describe what you tested
   - Screenshots: If UI changes

8. **Respond to Feedback**: Be open to suggestions and iterate

## Reporting Issues

See `.github/ISSUE_TEMPLATE/bug_report.md` for the bug report template.

When reporting bugs:
- Be specific about what doesn't work
- Include your environment (OS, Nix version, Neovim version)
- Provide steps to reproduce
- Include error messages and logs
- Suggest a fix if you have one

## Getting Help

- **Documentation**: Check `docs/` directory first
- **GitHub Issues**: Search existing issues
- **Discussions**: Ask questions in GitHub Discussions
- **Code Examples**: Look at existing language packages for patterns

## Recognition

Contributors will be recognized in:
- Release notes (CHANGELOG.md)
- README.md contributors section
- GitHub contributors page

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for making this project better! 🎉
