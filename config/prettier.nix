{ pkgs, ... }:
{
  extraPlugins = with pkgs.vimPlugins; [
    vim-prettier
  ];

  extraConfigVim = ''
    let g:prettier#config#config_precedence = 'prefer-file'
  '';
}

