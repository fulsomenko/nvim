{ pkgs, ... }:
{

  globals.mapleader = " ";

#  colorschemes.dracula.enable = true;

  plugins = {
    lualine.enable = true;
  };

  extraPlugins = with pkgs.vimPlugins; [
    copilot-vim
    vim-prisma
    transparent-nvim
    yuck-vim
  ];

  keymaps = [
    {
      action = ":bn<cr>";
      key = "<leader>n";
    }
    {
      action = ":bp<cr>";
      key = "<leader>p";
    }
    {
      action = ":bd<cr>";
      key = "<leader>d";
    }
  ];

#  extraConfigVim = ''
#    let @p = 'newvedi'* from kbebysiw'li./
#    let @o = 'Av%di;'
#    let @i = '@p@o'
#  '';
}

