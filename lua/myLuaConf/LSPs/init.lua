---LSP setup driven by the nixCats categories that this package was built
---with. Servers are defined in a single `servers` table, then either:
---  - on Nix:    enabled directly via vim.lsp.config + vim.lsp.enable
---  - off Nix:   installed by mason and enabled via mason-lspconfig v2 API
---
---Inlay hints, diagnostic UX and on_attach keybindings live in
---`caps-on_attach.lua`.

local servers = {}

---Common JS/TS root markers — covers monorepos (pnpm/yarn/nx/turborepo)
---and standalone projects.
local js_root_markers = {
  'package.json', 'tsconfig.json', 'jsconfig.json',
  'pnpm-workspace.yaml', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb',
  'nx.json', 'turbo.json',
  '.git',
}

---Try to load SchemaStore.nvim; it's only present when the `js` category
---is enabled. The require is wrapped because the plugin may not be packadd'd
---at the time this file is loaded.
local function schemastore_json_schemas()
  local ok, ss = pcall(require, 'schemastore')
  if not ok then return nil end
  return { schemas = ss.json.schemas(), validate = { enable = true } }
end

local function schemastore_yaml_schemas()
  local ok, ss = pcall(require, 'schemastore')
  if not ok then return nil end
  return ss.yaml.schemas()
end

----------------------------------------------------------------- neonixdev --

if nixCats('neonixdev') then
  servers.lua_ls = {
    settings = {
      Lua = {
        formatters    = { ignoreComments = true },
        signatureHelp = { enabled = true },
        diagnostics   = {
          globals = { 'nixCats' },
          disable = { 'missing-fields' },
        },
        telemetry = { enabled = false },
      },
    },
    filetypes = { 'lua' },
  }

  if require('nixCatsUtils').isNixCats then
    servers.nixd = {
      settings = {
        nixd = {
          nixpkgs = {
            expr = [[import (builtins.getFlake "]] .. nixCats.extra('nixdExtras.nixpkgs') .. [[") { }   ]],
          },
          formatting = { command = { 'nixfmt' } },
          diagnostic = { suppress = { 'sema-escaping-with' } },
        },
      },
    }
    if nixCats.extra('nixdExtras.flake-path') then
      local flakePath = nixCats.extra('nixdExtras.flake-path')
      if nixCats.extra('nixdExtras.systemCFGname') then
        servers.nixd.settings.nixd.options = servers.nixd.settings.nixd.options or {}
        servers.nixd.settings.nixd.options.nixos = {
          expr = [[(builtins.getFlake "]] .. flakePath .. [[").nixosConfigurations."]] ..
            nixCats.extra('nixdExtras.systemCFGname') .. [[".options]],
        }
      end
      if nixCats.extra('nixdExtras.homeCFGname') then
        servers.nixd.settings.nixd.options = servers.nixd.settings.nixd.options or {}
        servers.nixd.settings.nixd.options['home-manager'] = {
          expr = [[(builtins.getFlake "]] .. flakePath .. [[").homeConfigurations."]] ..
            nixCats.extra('nixdExtras.homeCFGname') .. [[".options]],
        }
      end
    end
  else
    servers.nil_ls = {}
  end
end

----------------------------------------------------------------- go ---------

if nixCats('go') then
  servers.gopls = {}
end

----------------------------------------------------------------- js / ts ----

if nixCats('js') then
  ---Inlay hints config, valid for typescript-language-server.
  local ts_inlay = {
    includeInlayParameterNameHints                        = 'all',
    includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    includeInlayFunctionParameterTypeHints                = true,
    includeInlayVariableTypeHints                         = true,
    includeInlayPropertyDeclarationTypeHints              = true,
    includeInlayFunctionLikeReturnTypeHints               = true,
    includeInlayEnumMemberValueHints                      = true,
  }

  servers.ts_ls = {
    root_markers = js_root_markers,
    settings = {
      typescript = {
        inlayHints              = ts_inlay,
        implementationsCodeLens = { enabled = true },
        referencesCodeLens      = { enabled = true, showOnAllFunctions = false },
        preferences             = { includeCompletionsForModuleExports = true },
      },
      javascript = {
        inlayHints              = ts_inlay,
        implementationsCodeLens = { enabled = true },
        referencesCodeLens      = { enabled = true, showOnAllFunctions = false },
      },
    },
  }

  ---ESLint LSP from vscode-langservers-extracted.
  servers.eslint = {
    root_markers = vim.list_extend({
      'eslint.config.js', 'eslint.config.mjs', 'eslint.config.cjs', 'eslint.config.ts',
      '.eslintrc', '.eslintrc.js', '.eslintrc.cjs', '.eslintrc.json', '.eslintrc.yaml', '.eslintrc.yml',
    }, js_root_markers),
    settings = {
      workingDirectories  = { mode = 'auto' },
      codeActionOnSave    = { enable = true, mode = 'all' },
      experimental        = { useFlatConfig = true },
      problems            = { shortenToSingleLine = false },
      run                 = 'onType',
    },
  }

  ---JSON / YAML / CSS / HTML / Tailwind / Emmet — all via the
  ---vscode-langservers-extracted family + the standalone ones.
  servers.jsonls = {
    settings = { json = schemastore_json_schemas() or { validate = { enable = true } } },
    init_options = { provideFormatter = true },
  }
  servers.yamlls = {
    settings = {
      yaml = {
        schemaStore = { enable = false, url = '' },
        schemas     = schemastore_yaml_schemas() or {},
      },
    },
  }
  servers.cssls   = { root_markers = js_root_markers }
  servers.html    = { root_markers = js_root_markers }
  servers.tailwindcss = { root_markers = vim.list_extend({
    'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts',
  }, js_root_markers) }
  servers.emmet_language_server = {
    filetypes = {
      'html', 'css', 'scss', 'less', 'sass',
      'javascriptreact', 'typescriptreact', 'svelte', 'vue',
    },
  }
end

----------------------------------------------------------------- java -------

if nixCats('java') then
  servers.jdtls = {}
end

----------------------------------------------------------------- csharp -----

if nixCats('csharp') then
  servers.omnisharp = {}
end

----------------------------------------------------------------- zig --------

if nixCats('zig') then
  servers.zls = {
    settings = {
      zls = {
        enable_semantic_tokens = true,
        enable_inlay_hints     = true,
        enable_snippets        = true,
        warn_style             = true,
        enable_autofix         = false,
      },
    },
    filetypes = { 'zig' },
  }
end

----------------------------------------------------------------- rust -------

if nixCats('rust') then
  servers.rust_analyzer = {
    settings = {
      ['rust-analyzer'] = {
        check     = { command = 'clippy' },
        cargo     = { allFeatures = true, loadOutDirsFromCheck = true },
        procMacro = { enable = true },
        diagnostics = { enable = true, experimental = { enable = true } },
        inlayHints = {
          bindingModeHints       = { enable = true },
          chainingHints          = { enable = true },
          closingBraceHints      = { enable = true, minLines = 25 },
          closureReturnTypeHints = { enable = 'always' },
          parameterHints         = { enable = true },
          typeHints              = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
        },
      },
    },
    filetypes = { 'rust' },
  }
end

----------------------------------------------------------------- r ---------

if nixCats('r') then
  servers.r_language_server = {
    settings = {
      r = {
        lsp = { debug = false, diagnostics = true, rich_documentation = true },
      },
    },
    filetypes = { 'r', 'rmd', 'qmd' },
  }
end

----------------------------------------------------------------- attach ----

if not require('nixCatsUtils').isNixCats and nixCats('lspDebugMode') then
  vim.lsp.set_log_level('debug')
end

vim.api.nvim_create_autocmd('LspAttach', {
  group    = vim.api.nvim_create_augroup('nixCats-lsp-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    require('myLuaConf.LSPs.caps-on_attach').on_attach(client, event.buf)
    require('myLuaConf.LSPs.import-utils').setup_keybindings(event.buf)
  end,
})

require('lze').load {
  {
    'nvim-lspconfig',
    for_cat = 'general.always',
    event   = 'FileType',
    load    = (require('nixCatsUtils').isNixCats and vim.cmd.packadd) or function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd('mason.nvim')
      vim.cmd.packadd('mason-lspconfig.nvim')
    end,
    after = function(_plugin)
      local on_attach_mod = require('myLuaConf.LSPs.caps-on_attach')

      ---Resolve `settings.json.schemas` lazily via SchemaStore.nvim if it
      ---wasn't available at definition time (e.g. lze hadn't packadd'd it).
      local function rehydrate_schemas()
        if servers.jsonls and (not servers.jsonls.settings.json.schemas) then
          local s = schemastore_json_schemas()
          if s then servers.jsonls.settings.json = s end
        end
        if servers.yamlls and (not next(servers.yamlls.settings.yaml.schemas or {})) then
          local s = schemastore_yaml_schemas()
          if s then servers.yamlls.settings.yaml.schemas = s end
        end
      end
      rehydrate_schemas()

      if require('nixCatsUtils').isNixCats then
        for server_name, cfg in pairs(servers) do
          cfg = cfg or {}
          vim.lsp.config(server_name, {
            cmd          = cfg.cmd,
            filetypes    = cfg.filetypes,
            init_options = cfg.init_options,
            root_markers = cfg.root_markers or { '.git' },
            settings     = cfg.settings,
            capabilities = on_attach_mod.get_capabilities(server_name),
          })
          vim.lsp.enable(server_name)
        end
      else
        ---mason-lspconfig v2 API: ensure_installed + vim.lsp.enable.
        require('mason').setup()
        require('mason-lspconfig').setup({
          ensure_installed = vim.tbl_keys(servers),
          automatic_enable = false,
        })
        for server_name, cfg in pairs(servers) do
          cfg = cfg or {}
          vim.lsp.config(server_name, {
            filetypes    = cfg.filetypes,
            init_options = cfg.init_options,
            root_markers = cfg.root_markers or { '.git' },
            settings     = cfg.settings,
            capabilities = on_attach_mod.get_capabilities(server_name),
          })
          vim.lsp.enable(server_name)
        end
      end
    end,
  },
}
