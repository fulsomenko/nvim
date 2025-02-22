{
  plugins.telescope = {
    enable = true;
    keymaps = {
      "<C-p>" = {
        action = "git_files";
        options.desc = "Telescope Git Files";
      };
      "<leader>:" = {
        action = "command_history";
        options.desc = "Command History";
      };
      "<leader><space>" = {
        action = "find_files";
        options.desc = "Find project files";
      };
      "<leader>b" = {
        action = "buffers";
        options.desc = "+buffer";
      };
      "<leader>fg" = {
        action = "live_grep";
        options.desc = "Find text";
      };
      "<leader>fe" = {
        action = "resume";
        options.desc = "Resume";
      };
      "<leader>ff" = {
        action = "oldfiles";
        options.desc = "Recent";
      };
      "<leader>gc" = {
        action = "git_commits";
        options.desc = "Commits";
      };
      "<leader>gs" = {
        action = "git_status";
        options.desc = "Status";
      };
    };
    settings = {
      defaults = {
        file_ignore_patterns = [ ".git" "^node_modules/" ".node_modules/"];
      };
    };
    extensions.fzf-native = {
      enable = true;
    };
  };
}

