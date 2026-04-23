---Conform.nvim setup. Formatters per filetype come from the per-language
---Nix modules, exposed to lua via `nixCats.extra("languageConfig.formatters")`.
---
---That tables already includes prettier(d) for json/html/css/yaml/etc., and
---is the single source of truth shared by every language package.

require('lze').load {
  {
    'conform.nvim',
    for_cat = 'format',
    keys = {
      { '<leader>FF', desc = '[F]ormat [F]ile' },
    },
    after = function(_plugin)
      local conform = require('conform')

      ---Pull the merged ft -> [tool] table from nix; fall back to a
      ---reasonable hard-coded set if the config was loaded without nix.
      local ft = nixCats.extra('languageConfig.formatters') or {
        javascript     = { 'prettierd', 'prettier' },
        javascriptreact = { 'prettierd', 'prettier' },
        typescript     = { 'prettierd', 'prettier' },
        typescriptreact = { 'prettierd', 'prettier' },
        json           = { 'prettierd', 'prettier' },
        jsonc          = { 'prettierd', 'prettier' },
        html           = { 'prettierd', 'prettier' },
        css            = { 'prettierd', 'prettier' },
        scss           = { 'prettierd', 'prettier' },
        yaml           = { 'prettierd', 'prettier' },
        markdown       = { 'prettierd', 'prettier' },
      }
      ---Per-ft "stop after first" semantics for prettier(d) chains.
      local formatters_by_ft = {}
      for k, list in pairs(ft) do
        if vim.tbl_contains(list, 'prettierd') or vim.tbl_contains(list, 'prettier') then
          formatters_by_ft[k] = vim.list_extend({}, list)
          formatters_by_ft[k].stop_after_first = true
        else
          formatters_by_ft[k] = list
        end
      end

      conform.setup({
        formatters_by_ft = formatters_by_ft,
        ---format_on_save handles BufWritePre internally; no extra autocmd needed.
        format_on_save = {
          timeout_ms  = 1000,
          lsp_format  = 'fallback',
        },
        formatters = {
          zigfmt = {
            command = 'zig',
            args    = { 'fmt', '--stdin' },
            stdin   = true,
          },
          styler = {
            command = 'R',
            args = {
              '--slave', '--no-restore', '--no-save',
              '-e',
              "con <- file('stdin'); styler::style_text(readLines(con)); close(con)",
            },
            stdin = true,
          },
        },
      })

      vim.keymap.set({ 'n', 'v' }, '<leader>FF', function()
        conform.format({ lsp_fallback = true, async = false, timeout_ms = 1000 })
      end, { desc = '[F]ormat [F]ile' })
    end,
  },
}
