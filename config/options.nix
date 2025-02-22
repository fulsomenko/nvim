{
  config = {
    opts = {
      updatetime = 100;

      number = true;
      relativenumber = true;
      colorcolumn = "80";

      autoindent = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      smartindent = true;

      swapfile = false;
      undofile = true;

      clipboard = "unnamed,unnamedplus";

      # Set fold settings
      # These options were reccommended by nvim-ufo
      # See: https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
      foldcolumn = "0";
      foldlevel = 99;
      foldlevelstart = 99;
      foldenable = true;
    };

    viAlias = true;

  };
}
