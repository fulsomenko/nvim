local M = {}

-- Function to organize/fix imports
function M.fix_imports()
  local clients = vim.lsp.get_clients({ bufnr = 0 })

  for _, client in pairs(clients) do
    if client.name == "ts_ls" or client.name == "tsserver" then
      -- TypeScript/JavaScript
      local params = {
        command = "_typescript.organizeImports",
        arguments = { vim.api.nvim_buf_get_name(0) },
      }
      -- Use the new client:exec_cmd method if available, fallback to execute_command
      if client.exec_cmd then
        client:exec_cmd(params)
      else
        vim.lsp.buf.execute_command(params)
      end
      return
    elseif client.name == "gopls" then
      -- Go
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and action.kind:match("source.organizeImports")
        end,
        apply = true,
      })
      return
    elseif client.name == "jdtls" then
      -- Java
      vim.lsp.buf.code_action({
        filter = function(action)
          return action.kind and action.kind:match("source.organizeImports")
        end,
        apply = true,
      })
      return
    end
  end

  -- Fallback to generic code action approach
  local params = vim.lsp.util.make_range_params()
  params.context = {
    only = { "source.organizeImports" },
    diagnostics = {},
  }

  local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
  if not result or vim.tbl_isempty(result) then
    print("No organize imports action available")
    return
  end

  for _, res in pairs(result) do
    if res.result then
      for _, action in pairs(res.result) do
        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
        elseif action.command then
          -- Use the newer client method if available
          local active_clients = vim.lsp.get_clients({ bufnr = 0 })
          if active_clients[1] and active_clients[1].exec_cmd then
            active_clients[1]:exec_cmd(action.command)
          else
            vim.lsp.buf.execute_command(action.command)
          end
        end
      end
    end
  end
end

-- Function to add missing imports (where supported)
function M.add_missing_imports()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.kind and (
        action.kind:match("source.addMissingImports") or
        action.kind:match("quickfix")
      )
    end,
    apply = true,
  })
end

-- Function to remove unused imports
function M.remove_unused_imports()
  vim.lsp.buf.code_action({
    filter = function(action)
      return action.kind and action.kind:match("source.removeUnused")
    end,
    apply = true,
  })
end

-- Function to fix all import issues
function M.fix_all_imports()
  M.add_missing_imports()
  vim.defer_fn(function()
    M.remove_unused_imports()
    vim.defer_fn(function()
      M.fix_imports()
    end, 100)
  end, 100)
end

function M.setup_keybindings(bufnr)
  local opts = { buffer = bufnr, silent = true }

  vim.keymap.set('n', '<leader>oi', M.fix_imports,
    vim.tbl_extend('force', opts, { desc = 'Organize/Fix Imports' }))

  vim.keymap.set('n', '<leader>ia', M.add_missing_imports,
    vim.tbl_extend('force', opts, { desc = 'Add Missing Imports' }))

  vim.keymap.set('n', '<leader>ir', M.remove_unused_imports,
    vim.tbl_extend('force', opts, { desc = 'Remove Unused Imports' }))

  vim.keymap.set('n', '<leader>if', M.fix_all_imports,
    vim.tbl_extend('force', opts, { desc = 'Fix All Import Issues' }))
end

return M

