---nvim-lint setup driven by nixCats per-language modules. Linters per
---filetype are merged from `nixCats.extra("languageConfig.linters")`,
---so adding a language only requires updating its nix module.

require('lze').load {
  {
    'nvim-lint',
    for_cat = 'lint',
    event   = { 'BufReadPost', 'BufNewFile' },
    after   = function(_plugin)
      local lint = require('lint')

      lint.linters_by_ft = nixCats.extra('languageConfig.linters') or {
        javascript     = { 'eslint_d' },
        javascriptreact = { 'eslint_d' },
        typescript     = { 'eslint_d' },
        typescriptreact = { 'eslint_d' },
      }

      ---Trigger linting on save, leaving insert mode and on file open.
      local grp = vim.api.nvim_create_augroup('nixCats-nvim-lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        group    = grp,
        callback = function() lint.try_lint() end,
      })
    end,
  },
}
