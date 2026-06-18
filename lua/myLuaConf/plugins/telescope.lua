-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- The easiest way to use telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of help_tags options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`

-- Custom live_grep function to search the project root.
-- Anchored to the cwd (not the active buffer) so the scope stays stable when you
-- jump into another file, an LSP-definition target, a help buffer, etc.
-- Uses vim.fs.root (no shell-out) so paths with shell metacharacters such as
-- Next.js route groups `app/(marketing)/...` can't break root detection. The
-- `.git` marker also matches the `.git` file used by worktrees.
local function live_grep_git_root()
  local cwd = vim.fn.getcwd()
  local root = vim.fs.root(cwd, { ".git" }) or cwd
  require('telescope.builtin').live_grep({
    search_dirs = { root },
  })
end

return {
  {
    "telescope.nvim",
    for_cat = 'general.telescope',
    cmd = { "Telescope", "LiveGrepGitRoot" },
    -- NOTE: our on attach function defines keybinds that call telescope.
    -- so, the on_require handler will load telescope when we use those.
    on_require = { "telescope", },
    -- event = "",
    -- ft = "",
    keys = {
      { "<leader>sM", '<cmd>Telescope notify<CR>', mode = {"n"}, desc = '[S]earch [M]essage', },
      { "<leader>sp",live_grep_git_root, mode = {"n"}, desc = '[S]earch git [P]roject root', },
      { "<leader>/", function()
        -- Slightly advanced example of overriding default behavior and theme
        -- You can pass additional configuration to telescope to change theme, layout, etc.
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, mode = {"n"}, desc = '[/] Fuzzily search in current buffer', },
      { "<leader>s/", function()
        require('telescope.builtin').live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, mode = {"n"}, desc = '[S]earch [/] in Open Files' },
      { "<leader><leader>s", function() return require('telescope.builtin').buffers() end, mode = {"n"}, desc = '[ ] Find existing buffers', },
      { "<leader>s.", function() return require('telescope.builtin').oldfiles() end, mode = {"n"}, desc = '[S]earch Recent Files ("." for repeat)', },
      { "<leader>sr", function() return require('telescope.builtin').resume() end, mode = {"n"}, desc = '[S]earch [R]esume', },
      { "<leader>sd", function() return require('telescope.builtin').diagnostics() end, mode = {"n"}, desc = '[S]earch [D]iagnostics', },
      { "<leader>sg", function() return require('telescope.builtin').live_grep() end, mode = {"n"}, desc = '[S]earch by [G]rep', },
      { "<leader>sw", function() return require('telescope.builtin').grep_string() end, mode = {"n"}, desc = '[S]earch current [W]ord', },
      { "<leader>ss", function() return require('telescope.builtin').builtin() end, mode = {"n"}, desc = '[S]earch [S]elect Telescope', },
      { "<leader>sf", function() return require('telescope.builtin').find_files() end, mode = {"n"}, desc = '[S]earch [F]iles', },
      { "<leader>sk", function() return require('telescope.builtin').keymaps() end, mode = {"n"}, desc = '[S]earch [K]eymaps', },
      { "<leader>sh", function() return require('telescope.builtin').help_tags() end, mode = {"n"}, desc = '[S]earch [H]elp', },
    },
    -- colorscheme = "",
    load = function (name)
        vim.cmd.packadd(name)
        vim.cmd.packadd("telescope-fzf-native.nvim")
        vim.cmd.packadd("telescope-ui-select.nvim")
    end,
    after = function (plugin)
      local actions = require('telescope.actions')

      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          mappings = {
            i = {
              ['<c-enter>'] = 'to_fuzzy_refine',
              ['<C-j>'] = actions.move_selection_next,
              ['<C-k>'] = actions.move_selection_previous,
            },
            n = {
              ['j'] = actions.move_selection_next,
              ['k'] = actions.move_selection_previous,
            },
          },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      vim.api.nvim_create_user_command('LiveGrepGitRoot', live_grep_git_root, {})
    end,
  },
}
