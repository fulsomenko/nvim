---These two MUST be set before any plugin is loaded.
vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '

if os.getenv('WAYLAND_DISPLAY') and vim.fn.exepath('wl-copy') ~= '' then
  vim.g.clipboard = {
    name  = 'wl-clipboard',
    copy  = { ['+'] = 'wl-copy',  ['*'] = 'wl-copy' },
    paste = { ['+'] = 'wl-paste', ['*'] = 'wl-paste' },
    cache_enabled = 1,
  }
end

----------------------------------------------------------------- options ----

vim.opt.list      = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.opt.hlsearch   = true
vim.opt.inccommand = 'split'
vim.opt.scrolloff  = 10
vim.wo.number      = true
vim.o.mouse        = ''

vim.opt.cpoptions:append('I')
vim.o.expandtab    = true
vim.o.smartindent  = true
vim.o.autoindent   = true
vim.o.tabstop      = 2
vim.o.shiftwidth   = 2
vim.o.breakindent  = true

vim.o.undofile     = true
vim.o.swapfile     = false

vim.o.ignorecase   = true
vim.o.smartcase    = true

vim.wo.signcolumn      = 'yes'
vim.wo.relativenumber  = true

vim.o.updatetime   = 250
vim.o.timeoutlen   = 300
vim.o.completeopt  = 'menu,preview,noselect'
vim.o.termguicolors = true

---NOTE: We intentionally do NOT set vim.o.clipboard. The per-key <leader>y/p
---bindings below give explicit control over the system clipboard without
---clobbering the unnamed register on every delete/change.

vim.g.netrw_liststyle = 0
vim.g.netrw_banner    = 0

----------------------------------------------------------------- autocmds ---

vim.api.nvim_create_autocmd('FileType', {
  desc = 'remove autocomment formatoptions',
  callback = function()
    vim.opt.formatoptions:remove({ 'c', 'r', 'o' })
  end,
})

local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group   = highlight_group,
  pattern = '*',
  callback = function()
    ---vim.hl is the 0.11+ entry point; vim.highlight is deprecated.
    local hl = vim.hl or vim.highlight
    hl.on_yank()
  end,
})

----------------------------------------------------------------- keymaps ----

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('v', 'J',     ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
vim.keymap.set('v', 'K',     ":m '<-2<CR>gv=gv", { desc = 'Move line up' })
vim.keymap.set('n', '<C-d>', '<C-d>zz',          { desc = 'Scroll down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz',          { desc = 'Scroll up' })
vim.keymap.set('n', 'n',     'nzzzv',            { desc = 'Next search result' })
vim.keymap.set('n', 'N',     'Nzzzv',            { desc = 'Previous search result' })

vim.keymap.set('n', '<leader><leader>[', '<cmd>bprev<CR>',    { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader><leader>]', '<cmd>bnext<CR>',    { desc = 'Next buffer' })
vim.keymap.set('n', '<leader><leader>l', '<cmd>b#<CR>',       { desc = 'Last buffer' })
vim.keymap.set('n', '<leader><leader>d', '<cmd>bdelete<CR>',  { desc = 'Delete buffer' })

vim.cmd([[command! W w]])
vim.cmd([[command! Wq wq]])
vim.cmd([[command! WQ wq]])
vim.cmd([[command! Q q]])

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

----------------------------------------------------------------- diagnostics

---vim.diagnostic.jump replaces goto_prev/goto_next in 0.11+.
local function diag_jump(count)
  return function() vim.diagnostic.jump({ count = count, float = true }) end
end
vim.keymap.set('n', '[d',         diag_jump(-1),                { desc = 'Previous diagnostic' })
vim.keymap.set('n', ']d',         diag_jump(1),                 { desc = 'Next diagnostic' })
vim.keymap.set('n', '<leader>e',  vim.diagnostic.open_float,    { desc = 'Open floating diagnostic' })
vim.keymap.set('n', '<leader>q',  vim.diagnostic.setloclist,    { desc = 'Diagnostics to loclist' })

vim.diagnostic.config({
  virtual_text     = { prefix = '●', spacing = 2 },
  severity_sort    = true,
  underline        = true,
  update_in_insert = false,
  float            = { border = 'rounded', source = true },
  signs            = true,
})

----------------------------------------------------------------- clipboard --

vim.keymap.set('n',         '<leader>y',  '"+y',  { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({'v','x'},   '<leader>y',  '"+y',  { noremap = true, silent = true, desc = 'Yank to clipboard' })
vim.keymap.set({'n','v','x'}, '<leader>yy', '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({'n','v','x'}, '<leader>Y',  '"+yy', { noremap = true, silent = true, desc = 'Yank line to clipboard' })
vim.keymap.set({'n','v','x'}, '<C-a>',      'gg0vG$', { noremap = true, silent = true, desc = 'Select all' })
vim.keymap.set({'n','v','x'}, '<leader>p',  '"+p',  { noremap = true, silent = true, desc = 'Paste from clipboard' })
vim.keymap.set('i', '<C-p>', '<C-r><C-p>+', { noremap = true, silent = true, desc = 'Paste from clipboard (insert)' })
vim.keymap.set('x', '<leader>P', '"_dP', { noremap = true, silent = true, desc = 'Paste over selection (no register clobber)' })

----------------------------------------------------------------- paths ------

vim.keymap.set('n', '<localleader>yp', function()
  vim.fn.setreg('+', vim.fn.expand('%:p:.'))
end, { desc = 'Copy file path (relative to cwd)' })

vim.keymap.set('n', '<localleader>yd', function()
  vim.fn.setreg('+', vim.fn.expand('%:h'))
end, { desc = 'Copy directory path' })

vim.keymap.set('n', '<localleader>yf', function()
  vim.fn.setreg('+', vim.fn.expand('%:t:r'))
end, { desc = 'Copy file name without extension' })

vim.keymap.set('n', '<localleader>ya', function()
  local paths = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= '' then table.insert(paths, name) end
    end
  end
  vim.fn.setreg('+', table.concat(paths, '\n'))
end, { desc = 'Copy all open buffer paths' })
