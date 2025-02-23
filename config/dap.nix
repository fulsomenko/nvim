{ pkgs, ... }:

let
  generateKeymap = import ./util/generateKeymap.nix;
  dapJsServer = builtins.fetchTarball {
    url = "https://github.com/microsoft/vscode-js-debug/releases/download/v1.86.1/js-debug-dap-v1.86.1.tar.gz";
    name = "vscode-js-debug";
    sha256 = "sha256:1h2yhdzlzp8ism3pxa9msnirym27z271yq2rywry0jpi6ggf7qrw";
  };
in
{
  plugins.dap = {
    enable = true;
    signs.dapBreakpoint.text = "🛑";
    extensions.dap-ui = {
      enable = true;
      layouts = [
        {
          elements = [
            {
              id = "scopes";
              size = 0.5;
            }
            {
              id = "stacks";
              size = 0.5;
            }
          ];
          position = "left";
          size = 25;
        }
        {
          elements = [
            {
              id = "repl";
              size = 0.5;
            }
            {
              id = "breakpoints";
              size = 0.5;
            }
          ];
          position = "bottom";
          size = 10;
        }
      ];
    };
  };
  keymaps = [
    (generateKeymap "n" "<leader>D" ":lua require('dapui').toggle()<CR>")
    (generateKeymap "n" "<leader>db" ":DapToggleBreakpoint<CR>")
    (generateKeymap "n" "<F3>" ":DapContinue<CR>")
    (generateKeymap "n" "<F4>" ":DapStepOver<CR>")
    (generateKeymap "n" "<F10>" ":lua require'dap'.step_back()<CR>")
    (generateKeymap "n" "<F11>" ":DapStepInto<CR>")
    (generateKeymap "n" "<F12>" ":DapStepOut<CR>")
    (generateKeymap "n" "<leader>dt" ":DapTerminate<CR>")
    (generateKeymap "n" "<leader>dh" ":lua require'dap.ui.widgets'.hover()<CR>")
  ];

  extraConfigLua = ''
  vim.g.dap_virtual_text = true
  vim.g.dap_virtual_text_show_scopes = true

  local dap = require('dap')

  dap.adapters = {
    ["pwa-node"] = {
      host = 'localhost',
      port = '${"$"}{port}',
      type = 'server',
      executable = {
        command = "node",
        -- 💀 Make sure to update this path to point to your installation
        args = {"${dapJsServer}/src/dapDebugServer.js", "${"$"}{port}"},
      }
    },
    ["chrome"] = {
      type = 'executable',
      command = "node",
      args = {"${dapJsServer}/src/dapDebugServer.js", "${"$"}{port}"},
    },
    ["netcoredbg"] = {
      type = 'executable',
      command = '${pkgs.netcoredbg}/bin/netcoredbg',
      args = {'--interpreter=vscode'}
    },
    ["go"] = {
      type = 'server',
      port = '${"$"}{port}',
      executable = {
        command = '${pkgs.delve}/bin/dlv',
        args = {'dap', '-l', '127.0.0.1:${"$"}{port}'}
      }
    }
  }

  dap.configurations = {
    ["javascript"] = {
      {
        ["cwd"] = "${"$"}{workspaceFolder}",
        ["name"] = "Launch file",
        ["program"] = "${"$"}{file}",
        ["request"] = "launch",
        ["type"] = "pwa-node"
      }
    },
    ["javascriptreact"] = {
      {
        type = "chrome",
        request = "attach",
        program = "${"$"}{file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${"$"}{workspaceFolder}"
      }
    },
    ["typescriptreact"] = {
      {
        type = "chrome",
        request = "attach",
        program = "${"$"}{file}",
        cwd = vim.fn.getcwd(),
        sourceMaps = true,
        protocol = "inspector",
        port = 9222,
        webRoot = "${"$"}{workspaceFolder}"
      }
    },
    ["cs"] = {
      {
        type = "netcoredbg",
        name = "launch - netcoredbg",
        request = "launch",
        program = function()
            -- Get the current folder name
          local current_folder = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

          -- Construct the path to the project file
          local project_file_path = vim.fn.getcwd() .. '/' .. current_folder .. '.csproj'

          if vim.fn.filereadable(project_file_path) == 0 then
            local dll_path = vim.fn.input('Path to dll', vim.fn.getcwd())
            return dll_path
          end


          -- Read the contents of the project file
          local project_file_content = vim.fn.readfile(project_file_path)

          -- Extract the target framework from the project file content
          local target_framework = ""
          for _, line in ipairs(project_file_content) do
            local match = line:match("<TargetFramework>(.+)</TargetFramework>")
            if match then
              target_framework = match
              break
            end
          end

          -- Construct the DLL path using the target framework
          local dll_path = vim.fn.input('Path to dll', vim.fn.getcwd() .. '/bin/Debug/' .. target_framework .. '/' .. current_folder .. '.dll', 'file')
          
          return dll_path
        end,
      }
    },
    ["go"] = {
      {
        type = "go",
        name = "Debug",
        request = "launch",
        program = "${"$"}{file}"
      },
      {
        type = "go",
        name = "Debug test", -- configuration for debugging test files
        request = "launch",
        mode = "test",
        program = "${"$"}{file}"
      },
      -- works with go.mod packages and sub packages 
      {
        type = "go",
        name = "Debug test (go.mod)",
        request = "launch",
        mode = "test",
        program = "./${"$"}{relativeFileDirname}"
      }
    }
  }
  '';
}
