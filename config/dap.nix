{pkgs, ...}:
let
  jsConfiguration = [
    # {
    #   name = "Launch file";
    #   type = "pwa-node";
    #   request = "launch";
    #   # program = "${file}";
    #   # cwd = "${workspaceFolder}";
    # }
  ];
  
  nvim-dap-vscode-js = pkgs.vimUtils.buildVimPlugin {
    name = "vim-dap-vscode-js";
    src = pkgs.fetchFromGitHub {
      owner = "mxsdev";
      repo = "nvim-dap-vscode-js";
      rev = "e7c05495934a658c8aa10afd995dacd796f76091";
      sha256 = "sha256-lZABpKpztX3NpuN4Y4+E8bvJZVV5ka7h8x9vL4r9Pjk=";
    };
  };
in
{
  extraPlugins = [
    nvim-dap-vscode-js
  ];

  keymaps = [
    {
      key = "<leader>bb";
      action = "<CMD>lua require('dap').toggle_breakpoint()<CR>";
      options.desc = "Toggle breakpoint";
    }
    {
      key = "<leader>dd";
      action = "<CMD>lua require('dap').run()<CR>";
      options.desc = "Start debugging";
    }
    {
      key = "<leader><leader>";
      action = "<CMD>lua require('dap').terminate()<CR>";
      options.desc = "Stop debugging";
    }
    {
      key = "<up>";
      action = "<CMD>lua require('dap').continue()<CR>";
      options.desc = "Debugging: continue";
    }
  ];

  extraConfigLua = ''
    local dap, dapui = require("dap"), require("dapui")
    local dap_vscode_js = require("dap-vscode-js")

    -- DEBUG LISTENERS
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    dap.set_log_level('DEBUG')

    -- DEBUG VS CODE
    dap_vscode_js.setup({
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' }
    })

    -- DEBUG CONFIG TYPESCRIPT
    dap.configurations.typescript = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "''${file}",
        cwd = "''${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require'dap.utils'.pick_process,
        cwd = "''${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Run Application",
        program = "dist/index.js",
        cwd = "''${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Run npm test",
        program = "node_modules/mocha/bin/_mocha",
        cwd = "''${workspaceFolder}",
      }
    }
  '';

  highlightOverride = {
    "DapBreakpoint" = {
      fg = "#E06C75";
    };
    "DapLogPoint" = {
      fg = "#61afef";
    };
    "DapStopped" = {
      fg = "#98c379";
    };
  };

  plugins.dap = {
    enable = true;

    signs = {
      "dapBreakpoint" = { text=""; texthl="DapBreakpoint"; linehl="DapBreakpoint"; numhl="DapBreakpoint"; };
      "dapBreakpointCondition" = { text=""; texthl="DapBreakpoint"; linehl="DapBreakpoint"; numhl="DapBreakpoint"; };
      "dapLogPoint" = { text=""; texthl="DapLogPoint"; linehl="DapLogPoint"; numhl="DapLogPoint"; };
      "dapStopped" = { text=""; texthl="DapStopped"; linehl="DapStopped"; numhl="DapStopped"; };
      "dapBreakpointRejected" = { text=""; texthl="DapBreakpoint"; linehl="DapBreakpoint"; numhl="DapBreakpoint"; };
    };

    adapters = {
      # servers = {
      # };
    };

    configurations = {
      # javascript = jsConfiguration;
      # typescript = jsConfiguration;
    };

    extensions = {
      dap-ui = {
        enable = true;

        layouts = [
          {
            elements = [
              {
                id = "scopes";
                size = 0.5;
              }
              "breakpoints"
              "watches"
              "stacks"
            ];
            size = 50; # 50 columns
            position = "left";
          }
          {
            elements = [
              "repl"
              "watches"
            ];
            size = 25; # 25%?
            position = "bottom";
          }
        ];
      };
      dap-virtual-text = {
        enable = true;
      };
      dap-go = {
        enable = true;
        delve.path = "${pkgs.delve}/bin/dlv";
      };
    };
  };
}

# { pkgs, ... }:
# 
# let
#   generateKeymap = import ./util/generateKeymap.nix;
#   #  dapJsServer = builtins.fetchTarball {
#   #    url = "https://github.com/microsoft/vscode-js-debug/releases/download/v1.86.1/js-debug-dap-v1.86.1.tar.gz";
#   #    name = "vscode-js-debug";
#   #    sha256 = "sha256:1h2yhdzlzp8ism3pxa9msnirym27z271yq2rywry0jpi6ggf7qrw";
#   #  };
# in
# {
#   plugins.dap = {
#     enable = true;
#     signs.dapBreakpoint.text = "🛑";
#     extensions = {
#       dap-ui = {
#         enable = true;
#         layouts = [
#           {
#             elements = [
#               {
#                 id = "scopes";
#                 size = 0.5;
#               }
#               {
#                 id = "stacks";
#                 size = 0.5;
#               }
#             ];
#             position = "left";
#             size = 25;
#           }
#           {
#             elements = [
#               {
#                 id = "repl";
#                 size = 0.5;
#               }
#               {
#                 id = "breakpoints";
#                 size = 0.5;
#               }
#             ];
#             position = "bottom";
#             size = 10;
#           }
#         ];
#       };
#       dap-virtual-text.enable = true;
#     };
#     configurations = {
#       typescript = {
#         name = "Launch file";
#         request = "launch";
#         type = "pwa-node";
#         #  sourceMaps = true;
#         #  runtimeArgs = ["--experimental-modules"];
#       };
#     };
#   };
# 
#   keymaps = [
#     (generateKeymap "n" "<leader>D" ":lua require('dapui').toggle()<CR>")
#     (generateKeymap "n" "<leader>db" ":DapToggleBreakpoint<CR>")
#     (generateKeymap "n" "<F3>" ":DapContinue<CR>")
#     (generateKeymap "n" "<F4>" ":DapStepOver<CR>")
#     (generateKeymap "n" "<F10>" ":lua require'dap'.step_back()<CR>")
#     (generateKeymap "n" "<F11>" ":DapStepInto<CR>")
#     (generateKeymap "n" "<F12>" ":DapStepOut<CR>")
#     (generateKeymap "n" "<leader>dt" ":DapTerminate<CR>")
#     (generateKeymap "n" "<leader>dh" ":lua require'dap.ui.widgets'.hover()<CR>")
#   ];
# }
#        ["resolveSourceMapLocations"] = "${"$"}{workspaceFolder}/dist/**/*.js", "!**/node_modules/**"}",

#        name = 'Launch',
#        type = 'pwa-node',
#        request = 'launch',
#        program = '${file}',
#        rootPath = '${workspaceFolder}',
#        cwd = '${workspaceFolder}',
#        sourceMaps = true,
#        skipFiles = { '<node_internals>/**' },
#        protocol = 'inspector',
#        console = 'integratedTerminal',


  #  extraConfigLua = ''
  #    vim.g.dap_virtual_text = true
  #    vim.g.dap_virtual_text_show_scopes = true
  #
  #    local dap = require('dap')
  #
  #    dap.configurations = {
  #      typescript = {
  #        {
  #          ["cwd"] = "${"$"}{workspaceFolder}",
  #          ["name"] = "Launch file",
  #          ["program"] = "${"$"}{file}",
  #          ["request"] = "launch",
  #          ["type"] = "pwa-node",
  #          ["sourceMaps"] = true,
  #          ["runtimeArgs"] = "["--experimental-modules"]"
  #        }
  #      },
  #    };
  #
  #    dap.adapters = {
  #      ["pwa-node"] = {
  #        host = 'localhost',
  #        port = '${"$"}{port}',
  #        type = 'server',
  #        executable = {
  #          command = "node",
  #          -- 💀 Make sure to update this path to point to your installation
  #          args = {"${dapJsServer}/src/dapDebugServer.js", "${"$"}{port}"},
  #        }
  #      },
  #      ["chrome"] = {
  #        type = 'executable',
  #        command = "node",
  #        args = {"${dapJsServer}/src/dapDebugServer.js", "${"$"}{port}"},
  #      },
  #      ["netcoredbg"] = {
  #        type = 'executable',
  #        command = '${pkgs.netcoredbg}/bin/netcoredbg',
  #        args = {'--interpreter=vscode'}
  #      },
  #      ["go"] = {
  #        type = 'server',
  #        port = '${"$"}{port}',
  #        executable = {
  #          command = '${pkgs.delve}/bin/dlv',
  #          args = {'dap', '-l', '127.0.0.1:${"$"}{port}'}
  #        }
  #      }
  #    }
  #
  #    dap.configurations = {
  #      ["javascript"] = {
  #        {
  #          ["cwd"] = "${"$"}{workspaceFolder}",
  #          ["name"] = "Launch file",
  #          ["program"] = "${"$"}{file}",
  #          ["request"] = "launch",
  #          ["type"] = "pwa-node"
  #        }
  #      },
  #      ["javascriptreact"] = {
  #        {
  #          type = "chrome",
  #          request = "attach",
  #          program = "${"$"}{file}",
  #          cwd = vim.fn.getcwd(),
  #          sourceMaps = true,
  #          protocol = "inspector",
  #          port = 9222,
  #          webRoot = "${"$"}{workspaceFolder}"
  #        }
  #      },
  #      ["typescriptreact"] = {
  #        {
  #          type = "chrome",
  #          request = "attach",
  #          program = "${"$"}{file}",
  #          cwd = vim.fn.getcwd(),
  #          sourceMaps = true,
  #          protocol = "inspector",
  #          port = 9222,
  #          webRoot = "${"$"}{workspaceFolder}"
  #        }
  #      },
  #      ["cs"] = {
  #        {
  #          type = "netcoredbg",
  #          name = "launch - netcoredbg",
  #          request = "launch",
  #          program = function()
  #              -- Get the current folder name
  #            local current_folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  #
  #            -- Construct the path to the project file
  #            local project_file_path = vim.fn.getcwd() .. '/' .. current_folder .. '.csproj'
  #
  #            if vim.fn.filereadable(project_file_path) == 0 then
  #              local dll_path = vim.fn.input('Path to dll', vim.fn.getcwd())
  #              return dll_path
  #            end
  #
  #
  #            -- Read the contents of the project file
  #            local project_file_content = vim.fn.readfile(project_file_path)
  #
  #            -- Extract the target framework from the project file content
  #            local target_framework = ""
  #            for _, line in ipairs(project_file_content) do
  #              local match = line:match("<TargetFramework>(.+)</TargetFramework>")
  #              if match then
  #                target_framework = match
  #                break
  #              end
  #            end
  #
  #            -- Construct the DLL path using the target framework
  #            local dll_path = vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/' .. target_framework .. '/' .. current_folder .. '.dll', 'file')
  #            
  #            return dll_path
  #          end,
  #        }
  #      },
  #      ["go"] = {
  #        {
  #          type = "go",
  #          name = "Debug",
  #          request = "launch",
  #          program = "${"$"}{file}"
  #        },
  #        {
  #          type = "go",
  #          name = "Debug test", -- configuration for debugging test files
  #          request = "launch",
  #          mode = "test",
  #          program = "${"$"}{file}"
  #        },
  #        -- works with go.mod packages and sub packages 
  #        {
  #          type = "go",
  #          name = "Debug test (go.mod)",
  #          request = "launch",
  #          mode = "test",
  #          program = "./${"$"}{relativeFileDirname}"
  #        }
  #      }
  #    }
  #  '';
