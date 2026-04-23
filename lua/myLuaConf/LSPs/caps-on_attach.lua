local M = {}

---Custom hover floating window with sane sizing and a `q` / `<Esc>` close.
local function custom_hover()
  local client = vim.lsp.get_clients({ bufnr = 0 })[1]
  if not client then return end

  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  vim.lsp.buf_request(0, 'textDocument/hover', params, function(err, result, _ctx, _config)
    if err or not result then return end
    local lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    lines = vim.lsp.util.trim_empty_lines(lines)
    if vim.tbl_isempty(lines) then return end

    local hover_bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(hover_bufnr, 0, -1, false, lines)
    vim.bo[hover_bufnr].filetype   = 'markdown'
    vim.bo[hover_bufnr].modifiable = false
    vim.bo[hover_bufnr].buflisted  = false

    local width  = math.min(100, vim.o.columns - 4)
    local height = math.min(30, math.max(5, #lines + 2))

    local win_id = vim.api.nvim_open_win(hover_bufnr, true, {
      relative = 'cursor',
      width    = width,
      height   = height,
      row      = 1,
      col      = 1,
      style    = 'minimal',
      border   = 'rounded',
    })

    vim.wo[win_id].wrap        = true
    vim.wo[win_id].scrollbind  = false

    local function close_hover()
      if vim.api.nvim_win_is_valid(win_id) then
        vim.api.nvim_win_close(win_id, true)
      end
      if vim.api.nvim_buf_is_valid(hover_bufnr) then
        vim.api.nvim_buf_delete(hover_bufnr, { force = true })
      end
    end

    local opts = { buffer = hover_bufnr, noremap = true, silent = true }
    vim.keymap.set('n', 'q',     close_hover, opts)
    vim.keymap.set('n', '<Esc>', close_hover, opts)
    vim.keymap.set('n', '<C-d>', '<C-d>',     opts)
    vim.keymap.set('n', '<C-u>', '<C-u>',     opts)
  end)
end

function M.on_attach(client, bufnr)
  local nmap = function(keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename,      '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd',  vim.lsp.buf.definition,  '[G]oto [D]efinition')

  if nixCats('general.telescope') then
    nmap('gr',         function() require('telescope.builtin').lsp_references() end,                 '[G]oto [R]eferences')
    nmap('gI',         function() require('telescope.builtin').lsp_implementations() end,            '[G]oto [I]mplementation')
    nmap('<leader>ds', function() require('telescope.builtin').lsp_document_symbols() end,           '[D]ocument [S]ymbols')
    nmap('<leader>ws', function() require('telescope.builtin').lsp_dynamic_workspace_symbols() end,  '[W]orkspace [S]ymbols')
  end

  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('K',         custom_hover,                'Hover Documentation')
  nmap('<C-k>',     vim.lsp.buf.signature_help,  'Signature Documentation')

  nmap('gD',         vim.lsp.buf.declaration,                 '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder,        '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder,     '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
                                                              '[W]orkspace [L]ist Folders')

  ---Per-buffer :Format command.
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })

  ---Inlay hints: enable per-buffer if the client supports them.
  if client and client.server_capabilities and client.server_capabilities.inlayHintProvider then
    pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
    nmap('<leader>th', function()
      local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
      vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
    end, '[T]oggle inlay [H]ints')
  end
end

function M.get_capabilities(_server_name)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  if nixCats('general.cmp') then
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())
  end
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  return capabilities
end

return M
