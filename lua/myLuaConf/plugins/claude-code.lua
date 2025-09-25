-- claude-code.nvim plugin configuration
return {
  {
    "claude-code.nvim",
    for_cat = 'ai',
    cmd = { "ClaudeCode" },
    keys = {
      {"<leader>cc", "<cmd>ClaudeCode<CR>", mode = {"n"}, noremap = true, desc = "Open Claude Code"},
    },
    after = function(plugin)
      require('claude-code').setup({
        -- Add any configuration options here
        -- Check the plugin's documentation for available options
      })
    end,
  },
}