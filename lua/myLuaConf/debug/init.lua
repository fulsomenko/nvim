require('lze').load {
  {
    "nvim-dap",
    -- NOTE: I dont want to figure out mason tools installer for this, so I only enabled debug if nix loaded config
    for_cat = { cat = 'debug', default = false },
    -- cmd = { "" },
    -- event = "",
    -- ft = "",
    keys = {
      { "<F5>", desc = "Debug: Start/Continue" },
      { "<F1>", desc = "Debug: Step Into" },
      { "<F2>", desc = "Debug: Step Over" },
      { "<F3>", desc = "Debug: Step Out" },
      { "<leader>b", desc = "Debug: Toggle Breakpoint" },
      { "<leader>B", desc = "Debug: Set Breakpoint" },
      { "<F7>", desc = "Debug: See last session result." },
    },
    -- colorscheme = "",
    load = (require('nixCatsUtils').isNixCats and function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("nvim-dap-ui")
      vim.cmd.packadd("nvim-dap-virtual-text")
    end) or function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd("nvim-dap-ui")
      vim.cmd.packadd("nvim-dap-virtual-text")
      vim.cmd.packadd("mason-nvim-dap.nvim")
    end,
    after = function (plugin)
      local dap = require 'dap'
      local dapui = require 'dapui'

      -- Basic debugging keymaps, feel free to change to your liking!
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<leader>B', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'Debug: Set Breakpoint' })

      -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
      vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close

      -- Dap UI setup
      -- For more information, see |:help nvim-dap-ui|
      dapui.setup {
        -- Set icons to characters that are more likely to work in every terminal.
        --    Feel free to remove or use ones that you like more! :)
        --    Don't feel like these are good choices.
        icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
        controls = {
          icons = {
            pause = '⏸',
            play = '▶',
            step_into = '⏎',
            step_over = '⏭',
            step_out = '⏮',
            step_back = 'b',
            run_last = '▶▶',
            terminate = '⏹',
            disconnect = '⏏',
          },
        },
      }

      require("nvim-dap-virtual-text").setup {
        enabled = true,                       -- enable this plugin (the default)
        enabled_commands = true,              -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
        highlight_changed_variables = true,   -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
        highlight_new_as_changed = false,     -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
        show_stop_reason = true,              -- show stop reason when stopped for exceptions
        commented = false,                    -- prefix virtual text with comment string
        only_first_definition = true,         -- only show virtual text at first definition (if there are multiple)
        all_references = false,               -- show virtual text on all all references of the variable (not only definitions)
        clear_on_continue = false,            -- clear virtual text on "continue" (might cause flickering when stepping)
        --- A callback that determines how a variable is displayed or whether it should be omitted
        --- variable Variable https://microsoft.github.io/debug-adapter-protocol/specification#Types_Variable
        --- buf number
        --- stackframe dap.StackFrame https://microsoft.github.io/debug-adapter-protocol/specification#Types_StackFrame
        --- node userdata tree-sitter node identified as variable definition of reference (see `:h tsnode`)
        --- options nvim_dap_virtual_text_options Current options for nvim-dap-virtual-text
        --- string|nil A text how the virtual text should be displayed or nil, if this variable shouldn't be displayed
        display_callback = function(variable, buf, stackframe, node, options)
          if options.virt_text_pos == 'inline' then
            return ' = ' .. variable.value
          else
            return variable.name .. ' = ' .. variable.value
          end
        end,
        -- position of virtual text, see `:h nvim_buf_set_extmark()`, default tries to inline the virtual text. Use 'eol' to set to end of line
        virt_text_pos = vim.fn.has 'nvim-0.10' == 1 and 'inline' or 'eol',

        -- experimental features:
        all_frames = false,       -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
        virt_lines = false,       -- show virtual lines instead of virtual text (will flicker!)
        virt_text_win_col = nil   -- position the virtual text at a fixed window column (starting from the first text column) ,
        -- e.g. 80 to position at column 80, see `:h nvim_buf_set_extmark()`
      }

      -- NOTE: Install lang specific config
      -- either in here, or in a separate plugin spec as demonstrated for go below.

    end,
  },
  {
    "nvim-dap-go",
    for_cat = { cat = 'debug.go', default = false },
    on_plugin = { "nvim-dap", },
    after = function(plugin)
      require("dap-go").setup()
    end,
  },
  {
    "nvim-dap-js",
    for_cat = { cat = 'debug.js', default = false },
    on_plugin = { "nvim-dap", },
    after = function(plugin)
      local dap = require 'dap'
      local debug = nixCats("js-debug-path")
      -- Use node2 adapter which works directly with Node.js inspector
      dap.adapters["node"] = {
        type = "executable",
        command = "node",
        args = {
          vim.fn.stdpath("data") .. "/mason/bin/node-debug2-adapter"
        }
      }

      -- Fallback if mason adapter doesn't exist - direct inspector connection
      if vim.fn.executable(vim.fn.stdpath("data") .. "/mason/bin/node-debug2-adapter") == 0 then
        dap.adapters["node"] = function(callback, config)
          -- For attach requests, connect directly to the inspector port
          if config.request == "attach" then
            callback({
              type = "server",
              host = config.address or "localhost",
              port = config.port or 9229
            })
          else
            callback(nil, "Only attach mode supported")
          end
        end
      end

      -- Keep pwa-node as alias
      dap.adapters["pwa-node"] = dap.adapters["node"]

      dap.adapters["pwa-chrome"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = { debug, "${port}",  },
        }
      }

      -- Handle mason-nvim-dap setup for non-nix environments without letting it override our configs
      if not require('nixCatsUtils').isNixCats then
        require("mason-nvim-dap").setup({
          automatic_setup = false, -- Don't auto-setup configurations
          handlers = {}, -- No handlers to prevent automatic configuration
        })
      end

      -- Clear any existing configurations to avoid conflicts
      dap.configurations.typescript = {}
      dap.configurations.javascript = {}
      dap.configurations.typescriptreact = {}
      dap.configurations.javascriptreact = {}

      -- Comprehensive Node.js and browser debugging configurations
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[language] = {
          -- Standard Node.js attach (default port)
          {
            name = "Attach to Node.js (port 9229)",
            type = "pwa-node",
            request = "attach",
            address = "localhost",
            port = 9229,
            localRoot = vim.fn.getcwd(),
            remoteRoot = vim.fn.getcwd(),
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },

          -- Custom port attach
          {
            name = "Attach to Node.js (custom port)",
            type = "pwa-node",
            request = "attach",
            address = "localhost",
            port = function()
              return vim.fn.input("Debug port: ", "9229")
            end,
            localRoot = vim.fn.getcwd(),
            remoteRoot = vim.fn.getcwd(),
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },

          -- Process picker - attach to any running Node process
          {
            name = "Attach to running Node process",
            type = "pwa-node",
            request = "attach",
            processId = function()
              return require("dap.utils").pick_process({ filter = "node" })
            end,
            localRoot = vim.fn.getcwd(),
            remoteRoot = vim.fn.getcwd(),
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },

          -- Attach to Chrome/Browser
          {
            name = "Attach to Chrome",
            type = "pwa-chrome",
            request = "attach",
            port = 9222,
            webRoot = vim.fn.getcwd(),
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**" },
          },

          -- Launch Chrome with custom URL
          {
            name = "Launch Chrome with URL",
            type = "pwa-chrome",
            request = "launch",
            url = function()
              return vim.fn.input("URL: ", "http://localhost:3000")
            end,
            webRoot = vim.fn.getcwd(),
            sourceMaps = true,
            skipFiles = { "<node_internals>/**", "node_modules/**", "**/webpack/**" },
          },

        }
      end
    end,
  },
  {
    "nvim-dap",
    for_cat = { cat = 'debug.zig', default = false },
    after = function(plugin)
      local dap = require 'dap'

      -- LLDB adapter configuration for Zig
      dap.adapters.lldb = {
        type = 'executable',
        command = 'lldb-vscode',
        name = 'lldb'
      }

      -- Zig debug configurations
      dap.configurations.zig = {
        {
          name = "Launch Zig Program",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/zig-out/bin/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
        {
          name = "Launch Zig Test",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/zig-cache/o/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Attach to running Zig process",
          type = "lldb",
          request = "attach",
          pid = function()
            return require("dap.utils").pick_process({ filter = "zig" })
          end,
          cwd = '${workspaceFolder}',
        },
      }
    end,
  },
  {
    "nvim-dap",
    for_cat = { cat = 'debug.rust', default = false },
    after = function(plugin)
      local dap = require 'dap'

      -- CodeLLDB adapter configuration for Rust
      if require('nixCatsUtils').isNixCats then
        local codelldb_path = nixCats("codelldb-path") or "codelldb"
        dap.adapters.codelldb = {
          type = 'server',
          port = "${port}",
          executable = {
            command = codelldb_path,
            args = {"--port", "${port}"},
          }
        }
      else
        dap.adapters.codelldb = {
          type = 'server',
          port = "${port}",
          executable = {
            command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
            args = {"--port", "${port}"},
          }
        }
      end

      -- Rust debug configurations
      dap.configurations.rust = {
        {
          name = "Launch Rust Program (Debug)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Launch Rust Program (Release)",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/release/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Run Rust tests",
          type = "codelldb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
        {
          name = "Attach to running Rust process",
          type = "codelldb",
          request = "attach",
          pid = function()
            return require("dap.utils").pick_process()
          end,
          cwd = '${workspaceFolder}',
        },
      }
    end,
  },
  {
    "nvim-dap",
    for_cat = { cat = 'debug.csharp', default = false },
    after = function(plugin)
      local dap = require 'dap'

      -- Configure CoreCLR (C#/.NET) debugging with netcoredbg
      dap.adapters.coreclr = {
        type = 'executable',
        command = 'netcoredbg',
        args = { '--interpreter=vscode' }
      }

      dap.configurations.cs = {
        {
          name = "Launch .NET Core App",
          type = "coreclr",
          request = "launch",
          program = function()
            return vim.fn.input('Path to DLL: ', vim.fn.getcwd() .. '/bin/Debug/net6.0/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
        },
        {
          name = "Attach to .NET Process",
          type = "coreclr",
          request = "attach",
          processId = function()
            return require('dap.utils').pick_process()
          end,
        },
      }
    end,
  },
  {
    "nvim-dap",
    for_cat = { cat = 'debug.java', default = false },
    after = function(plugin)
      local dap = require 'dap'

      -- Configure JDWP (Java Debug Wire Protocol) debugging
      -- Start Java app with: java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005 YourApp.jar
      dap.adapters.java = {
        type = 'server',
        host = '127.0.0.1',
        port = 5005,
        enrich_config = function(config, on_config)
          -- Additional configuration can be added here
          on_config(config)
        end,
      }

      dap.configurations.java = {
        {
          name = "Attach to Java Process",
          type = "java",
          request = "attach",
          hostName = '127.0.0.1',
          port = 5005,
          preLaunchTask = nil,
        },
      }
    end,
  },
}
