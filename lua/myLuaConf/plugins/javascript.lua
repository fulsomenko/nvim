---JavaScript / TypeScript-specific plugin specs. All gated on the `js`
---category so they only load for the jsvim package.

return {
  ----------------------------------------------------------------- jsx tags --
  {
    'nvim-ts-autotag',
    for_cat = 'js',
    event = { 'BufReadPre', 'BufNewFile' },
    after = function(_)
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close          = true,
          enable_rename         = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },

  ----------------------------------------------------------------- jsx comments
  {
    'nvim-ts-context-commentstring',
    for_cat = 'js',
    event = { 'BufReadPre', 'BufNewFile' },
    after = function(_)
      ---Used by Comment.nvim via the pre_hook below.
      require('ts_context_commentstring').setup({
        enable_autocmd = false,
      })
      vim.g.skip_ts_context_commentstring_module = true
      ---Re-wire Comment.nvim if it's already loaded.
      local ok, comment = pcall(require, 'Comment')
      if ok then
        comment.setup({
          pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
        })
      end
    end,
  },

  ----------------------------------------------------------------- package.json
  {
    'package-info.nvim',
    for_cat = 'js',
    ft = { 'json' },
    after = function(_)
      require('package-info').setup({
        colors = {
          up_to_date = '#3C4048',
          outdated   = '#d19a66',
        },
        icons     = { enable = true, style = { up_to_date = '|  ', outdated = '|  ' } },
        autostart = true,
        hide_up_to_date = false,
        hide_unstable_versions = false,
        package_manager = 'npm',
      })
      vim.keymap.set('n', '<leader>ns', require('package-info').show,           { desc = 'package.json: show versions' })
      vim.keymap.set('n', '<leader>nh', require('package-info').hide,           { desc = 'package.json: hide versions' })
      vim.keymap.set('n', '<leader>nu', require('package-info').update,         { desc = 'package.json: update package' })
      vim.keymap.set('n', '<leader>nd', require('package-info').delete,         { desc = 'package.json: delete package' })
      vim.keymap.set('n', '<leader>ni', require('package-info').install,        { desc = 'package.json: install new package' })
      vim.keymap.set('n', '<leader>nc', require('package-info').change_version, { desc = 'package.json: change version' })
    end,
  },

  ----------------------------------------------------------------- neotest ---
  {
    'neotest',
    for_cat = 'js',
    cmd  = { 'Neotest' },
    keys = {
      { '<leader>tn', desc = 'Test: nearest' },
      { '<leader>tf', desc = 'Test: file' },
      { '<leader>ts', desc = 'Test: summary toggle' },
      { '<leader>to', desc = 'Test: output' },
      { '<leader>tw', desc = 'Test: watch file' },
    },
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd('neotest-jest')
      vim.cmd.packadd('neotest-vitest')
    end,
    after = function(_)
      local neotest = require('neotest')
      neotest.setup({
        adapters = {
          require('neotest-jest')({
            jestCommand   = 'npx jest --',
            jestConfigFile = function()
              local file = vim.fn.expand('%:p')
              if string.find(file, '/packages/') then
                return string.match(file, '(.-/[^/]+/)src') .. 'jest.config.ts'
              end
              return vim.fn.getcwd() .. '/jest.config.ts'
            end,
            env = { CI = true },
            cwd = function() return vim.fn.getcwd() end,
          }),
          require('neotest-vitest'),
        },
      })

      vim.keymap.set('n', '<leader>tn', function() neotest.run.run() end,                  { desc = 'Test: nearest' })
      vim.keymap.set('n', '<leader>tf', function() neotest.run.run(vim.fn.expand('%')) end, { desc = 'Test: file' })
      vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end,           { desc = 'Test: summary toggle' })
      vim.keymap.set('n', '<leader>to', function() neotest.output.open({ enter = true }) end, { desc = 'Test: output' })
      vim.keymap.set('n', '<leader>tw', function() neotest.watch.toggle(vim.fn.expand('%')) end, { desc = 'Test: watch file' })
    end,
  },

  ----------------------------------------------------------------- SchemaStore
  ---Loaded eagerly so jsonls/yamlls can read it during their setup.
  {
    'SchemaStore.nvim',
    for_cat = 'js',
    event = 'DeferredUIEnter',
  },
}
