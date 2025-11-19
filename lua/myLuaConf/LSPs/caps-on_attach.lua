local M = {}

-- Custom hover function with improved window sizing and scrolling
local function custom_hover()
  local client = vim.lsp.get_active_clients({ bufnr = 0 })[1]
  if not client then return end

  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  return vim.lsp.buf_request(
    0,
    'textDocument/hover',
    params,
    function(err, result, ctx, _)
      if err or not result then return end
      local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
      markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)
      if vim.tbl_isempty(markdown_lines) then return end

      -- Create a buffer for the hover content
      local hover_bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(hover_bufnr, 0, -1, false, markdown_lines)
      vim.api.nvim_buf_set_option(hover_bufnr, 'filetype', 'markdown')
      vim.api.nvim_buf_set_option(hover_bufnr, 'modifiable', false)
      vim.api.nvim_buf_set_option(hover_bufnr, 'buflisted', false)

      -- Calculate window dimensions
      local width = math.min(100, vim.o.columns - 4)
      local height = math.min(30, math.max(5, #markdown_lines + 2))

      -- Create floating window
      local win_id = vim.api.nvim_open_win(hover_bufnr, true, {
        relative = 'cursor',
        width = width,
        height = height,
        row = 1,
        col = 1,
        style = 'minimal',
        border = 'rounded',
      })

      vim.api.nvim_win_set_option(win_id, 'wrap', true)
      vim.api.nvim_win_set_option(win_id, 'scrollbind', false)

      -- Close function that properly cleans up the window and buffer
      local function close_hover()
        if vim.api.nvim_win_is_valid(win_id) then
          vim.api.nvim_win_close(win_id, true)
        end
        if vim.api.nvim_buf_is_valid(hover_bufnr) then
          vim.api.nvim_buf_delete(hover_bufnr, { force = true })
        end
      end

      -- Add keymaps for scrolling and closing
      local opts = { buffer = hover_bufnr, noremap = true, silent = true }
      vim.keymap.set('n', 'q', close_hover, opts)
      vim.keymap.set('n', '<Esc>', close_hover, opts)
      vim.keymap.set('n', '<C-d>', '<C-d>', opts)  -- Page down
      vim.keymap.set('n', '<C-u>', '<C-u>', opts)  -- Page up
    end
  )
end

function M.on_attach(_, bufnr)
  -- we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.

  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')

  -- NOTE: why are these functions that call the telescope builtin?
  -- because otherwise they would load telescope eagerly when this is defined.
  -- due to us using the on_require handler to make sure it is available.
  if nixCats('general.telescope') then
    nmap('gr', function() require('telescope.builtin').lsp_references() end, '[G]oto [R]eferences')
    nmap('gI', function() require('telescope.builtin').lsp_implementations() end, '[G]oto [I]mplementation')
    nmap('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end, '[D]ocument [S]ymbols')
    nmap('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end, '[W]orkspace [S]ymbols')
  end -- TODO: someone who knows the builtin versions of these to do instead help me out please.

  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')

  -- See `:help K` for why this keymap
  -- Using custom hover with improved window sizing
  nmap('K', custom_hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Jump to type definition (shows full type if it's in source)
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Jump to Type Definition')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

end

function M.get_capabilities(server_name)
  -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
  -- if you make a package without it, make sure to check if it exists with nixCats!
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if nixCats('general.cmp') then
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  end
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end
return M
