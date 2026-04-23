---DAP setup. The base nvim-dap config + dap-ui + virtual text live in
---the first spec; per-language configs (js, zig, rust, csharp, java) live
---in their own specs gated by `for_cat`.
---
---For JavaScript/TypeScript we drive vscode-js-debug directly: a single
---server-mode adapter (`pwa-node` / `pwa-chrome`) that nvim-dap launches
---via `node ${js-debug-path} ${port}`, where `js-debug-path` is provided
---by the JS language nix module.

require('lze').load {
  {
    'nvim-dap',
    for_cat = { cat = 'debug', default = false },
    keys = {
      { '<F5>',      desc = 'Debug: Start/Continue' },
      { '<F1>',      desc = 'Debug: Step Into' },
      { '<F2>',      desc = 'Debug: Step Over' },
      { '<F3>',      desc = 'Debug: Step Out' },
      { '<leader>b', desc = 'Debug: Toggle Breakpoint' },
      { '<leader>B', desc = 'Debug: Conditional Breakpoint' },
      { '<F7>',      desc = 'Debug: Toggle DAP UI' },
    },
    load = (require('nixCatsUtils').isNixCats and function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd('nvim-dap-ui')
      vim.cmd.packadd('nvim-dap-virtual-text')
    end) or function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd('nvim-dap-ui')
      vim.cmd.packadd('nvim-dap-virtual-text')
      vim.cmd.packadd('mason-nvim-dap.nvim')
    end,
    after = function(_plugin)
      local dap   = require('dap')
      local dapui = require('dapui')

      vim.keymap.set('n', '<F5>',      dap.continue,  { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>',      dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>',      dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>',      dap.step_out,  { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
      end, { desc = 'Debug: Set Breakpoint' })
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: Toggle DAP UI' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config']     = dapui.close

      dapui.setup({
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause      = '⏸', play      = '▶', step_into = '⏎',
            step_over  = '⏭', step_out  = '⏮', step_back = 'b',
            run_last   = '▶▶', terminate = '⏹', disconnect = '⏏',
          },
        },
      })

      require('nvim-dap-virtual-text').setup({
        enabled                     = true,
        enabled_commands            = true,
        highlight_changed_variables = true,
        highlight_new_as_changed    = false,
        show_stop_reason            = true,
        commented                   = false,
        only_first_definition       = true,
        all_references              = false,
        clear_on_continue           = false,
        display_callback = function(variable, _buf, _stackframe, _node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        virt_text_pos      = vim.fn.has('nvim-0.10') == 1 and 'inline' or 'eol',
        all_frames         = false,
        virt_lines         = false,
        virt_text_win_col  = nil,
      })
    end,
  },

  ----------------------------------------------------------------- go --------
  {
    'nvim-dap-go',
    for_cat   = { cat = 'debug.go', default = false },
    on_plugin = { 'nvim-dap' },
    after     = function(_plugin) require('dap-go').setup() end,
  },

  ----------------------------------------------------------------- js / ts ---
  {
    'nvim-dap',
    for_cat   = { cat = 'debug.js', default = false },
    after     = function(_plugin)
      local dap = require('dap')

      ---Path to vscode-js-debug's dapDebugServer.js entry, supplied by Nix.
      local js_debug = nixCats('js-debug-path')

      ---Single server-mode adapter used by all pwa-* configs. nvim-dap
      ---spawns `node <dapDebugServer.js> <port>` and connects via TCP.
      if js_debug then
        local function js_adapter(name)
          return {
            type     = 'server',
            host     = 'localhost',
            port     = '${port}',
            executable = {
              command = 'node',
              args    = { js_debug, '${port}' },
            },
          }
        end
        dap.adapters['pwa-node']   = js_adapter('pwa-node')
        dap.adapters['pwa-chrome'] = js_adapter('pwa-chrome')
        dap.adapters['pwa-msedge'] = js_adapter('pwa-msedge')
        ---node and chrome aliases for compatibility with various test runners.
        dap.adapters['node']       = dap.adapters['pwa-node']
        dap.adapters['chrome']     = dap.adapters['pwa-chrome']
      end

      ---Read npm scripts out of the nearest package.json for the script picker.
      local function pick_npm_script()
        local pkg = vim.fs.find('package.json', { upward = true, type = 'file' })[1]
        if not pkg then
          vim.notify('No package.json found in tree', vim.log.levels.WARN)
          return nil
        end
        local ok, content = pcall(vim.fn.readfile, pkg)
        if not ok then return nil end
        local data = vim.json.decode(table.concat(content, '\n'))
        local scripts = (data and data.scripts) or {}
        local names = vim.tbl_keys(scripts)
        if #names == 0 then return nil end
        table.sort(names)
        local choice = vim.fn.inputlist(vim.list_extend({ 'Pick npm script:' },
          vim.tbl_map(function(n) return n .. '  -- ' .. scripts[n] end, names)))
        return names[choice]
      end

      local js_filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }
      for _, ft in ipairs(js_filetypes) do
        dap.configurations[ft] = {
          ----- launch ----------------------------------------------------
          {
            name = 'Launch current file (node)',
            type = 'pwa-node',
            request = 'launch',
            program = '${file}',
            cwd     = '${workspaceFolder}',
            sourceMaps   = true,
            skipFiles    = { '<node_internals>/**', 'node_modules/**' },
            console      = 'integratedTerminal',
          },
          {
            name = 'Launch current file (tsx)',
            type = 'pwa-node',
            request = 'launch',
            runtimeExecutable = 'npx',
            runtimeArgs = { 'tsx' },
            program = '${file}',
            cwd     = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
            console    = 'integratedTerminal',
          },
          {
            name = 'Launch via npm script',
            type = 'pwa-node',
            request = 'launch',
            cwd     = '${workspaceFolder}',
            runtimeExecutable = 'npm',
            runtimeArgs = function()
              local s = pick_npm_script()
              return s and { 'run', s } or { 'run' }
            end,
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**' },
            console    = 'integratedTerminal',
          },

          ----- jest ------------------------------------------------------
          {
            name = 'Debug Jest (current file)',
            type = 'pwa-node',
            request = 'launch',
            cwd     = '${workspaceFolder}',
            runtimeExecutable = 'node',
            runtimeArgs = { './node_modules/.bin/jest', '--runInBand', '--no-coverage', '${file}' },
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
            console    = 'integratedTerminal',
          },

          ----- vitest ----------------------------------------------------
          {
            name = 'Debug Vitest (current file)',
            type = 'pwa-node',
            request = 'launch',
            cwd     = '${workspaceFolder}',
            runtimeExecutable = 'node',
            runtimeArgs = { './node_modules/vitest/vitest.mjs', '--inspect-brk', '--no-coverage', '--no-file-parallelism', 'run', '${file}' },
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
            console    = 'integratedTerminal',
          },

          ----- attach ----------------------------------------------------
          {
            name = 'Attach to Node (port 9229)',
            type = 'pwa-node',
            request = 'attach',
            address = 'localhost',
            port    = 9229,
            cwd     = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            name = 'Attach to Node (custom port)',
            type = 'pwa-node',
            request = 'attach',
            address = 'localhost',
            port    = function() return tonumber(vim.fn.input('Debug port: ', '9229')) end,
            cwd     = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            name = 'Attach to running Node process',
            type = 'pwa-node',
            request = 'attach',
            processId = function() return require('dap.utils').pick_process({ filter = 'node' }) end,
            cwd     = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
          },

          ----- chrome ----------------------------------------------------
          {
            name = 'Attach to Chrome (port 9222)',
            type = 'pwa-chrome',
            request = 'attach',
            port    = 9222,
            webRoot = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**' },
          },
          {
            name = 'Launch Chrome (URL)',
            type = 'pwa-chrome',
            request = 'launch',
            url     = function() return vim.fn.input('URL: ', 'http://localhost:3000') end,
            webRoot = '${workspaceFolder}',
            sourceMaps = true,
            skipFiles  = { '<node_internals>/**', 'node_modules/**', '**/webpack/**' },
          },
        }
      end
    end,
  },

  ----------------------------------------------------------------- zig -------
  {
    'nvim-dap',
    for_cat = { cat = 'debug.zig', default = false },
    after = function(_plugin)
      local dap = require('dap')
      dap.adapters.lldb = { type = 'executable', command = 'lldb-vscode', name = 'lldb' }
      dap.configurations.zig = {
        {
          name = 'Launch Zig Program',
          type = 'lldb', request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/zig-out/bin/', 'file')
          end,
          cwd = '${workspaceFolder}', stopOnEntry = false, args = {}, runInTerminal = false,
        },
        {
          name = 'Launch Zig Test',
          type = 'lldb', request = 'launch',
          program = function()
            return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/zig-cache/o/', 'file')
          end,
          cwd = '${workspaceFolder}', stopOnEntry = false, args = {},
        },
        {
          name = 'Attach to running Zig process',
          type = 'lldb', request = 'attach',
          pid = function() return require('dap.utils').pick_process({ filter = 'zig' }) end,
          cwd = '${workspaceFolder}',
        },
      }
    end,
  },

  ----------------------------------------------------------------- rust ------
  {
    'nvim-dap',
    for_cat = { cat = 'debug.rust', default = false },
    after = function(_plugin)
      local dap = require('dap')
      local codelldb_path = (require('nixCatsUtils').isNixCats and (nixCats('codelldb-path') or 'codelldb'))
        or (vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/codelldb')

      dap.adapters.codelldb = {
        type = 'server', port = '${port}',
        executable = { command = codelldb_path, args = { '--port', '${port}' } },
      }

      dap.configurations.rust = {
        {
          name = 'Launch Rust Program (Debug)',
          type = 'codelldb', request = 'launch',
          program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file') end,
          cwd = '${workspaceFolder}', stopOnEntry = false, args = {},
        },
        {
          name = 'Launch Rust Program (Release)',
          type = 'codelldb', request = 'launch',
          program = function() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/release/', 'file') end,
          cwd = '${workspaceFolder}', stopOnEntry = false, args = {},
        },
        {
          name = 'Run Rust tests',
          type = 'codelldb', request = 'launch',
          program = function() return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/target/debug/', 'file') end,
          cwd = '${workspaceFolder}', stopOnEntry = false, args = {},
        },
        {
          name = 'Attach to running Rust process',
          type = 'codelldb', request = 'attach',
          pid = function() return require('dap.utils').pick_process() end,
          cwd = '${workspaceFolder}',
        },
      }
    end,
  },

  ----------------------------------------------------------------- csharp ----
  {
    'nvim-dap',
    for_cat = { cat = 'debug.csharp', default = false },
    after = function(_plugin)
      local dap = require('dap')
      dap.adapters.coreclr = {
        type = 'executable', command = 'netcoredbg', args = { '--interpreter=vscode' },
      }
      dap.configurations.cs = {
        {
          name = 'Launch .NET Core App',
          type = 'coreclr', request = 'launch',
          program = function() return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/net6.0/', 'file') end,
          cwd = '${workspaceFolder}', stopOnEntry = false,
        },
        {
          name = 'Attach to .NET Process',
          type = 'coreclr', request = 'attach',
          processId = function() return require('dap.utils').pick_process() end,
        },
      }
    end,
  },

  ----------------------------------------------------------------- java ------
  {
    'nvim-dap',
    for_cat = { cat = 'debug.java', default = false },
    after = function(_plugin)
      local dap = require('dap')
      dap.adapters.java = {
        type = 'server', host = '127.0.0.1', port = 5005,
        enrich_config = function(config, on_config) on_config(config) end,
      }
      dap.configurations.java = {
        {
          name = 'Attach to Java Process',
          type = 'java', request = 'attach',
          hostName = '127.0.0.1', port = 5005, preLaunchTask = nil,
        },
      }
    end,
  },
}
