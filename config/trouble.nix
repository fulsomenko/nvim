{
  plugins.trouble.enable = true;

  keymaps = [
    {
      key = "<leader>xx";
      action = "<cmd>Trouble diagnostics toggle<cr>";
    }
    {
      key = "<leader>xX";
      action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
    }
    {
      key = "<leader>cs";
      action = "<cmd>Trouble symbols toggle focus=false<cr>";
    }
    {
      key = "<leader>cl";
      action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
    }
    {
      key = "<leader>xL";
      action = "<cmd>Trouble loclist toggle<cr>";
    }
    {
      key = "<leader>xQ";
      action = "<cmd>Trouble qflist toggle<cr>";
    }
  ];
}

