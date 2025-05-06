return {
  "preservim/nerdtree",
  keys = {
    {
      "<leader>n",
      ":NERDTreeFocus<CR>",
      desc = "Focus NERDTree",
      mode = { "n", "v" },
    },
    {
      "<leader>t",
      ":NERDTreeToggle<CR>",
      desc = "Toggle NERDTree",
      mode = { "n", "v" },
    },
  },
  after = function()
    -- Optional: Set global variables or run commands after loading NERDTree
    vim.g.NERDTreeShowHidden = 1
    -- Example: Open NERDTree if no files are specified on startup
    vim.cmd([[
      autocmd VimEnter * if !argc() | NERDTree | endif
    ]])
  end,
}

