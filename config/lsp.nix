{
  plugins.lsp = {
      
    enable = true;
    servers = {
      bashls.enable = false;
      clangd.enable = true;
      cssls.enable = true;
      dockerls.enable = true;
      docker_compose_language_service.enable = true;
      gopls.enable = true;
      hls = {
        enable = true;
        installGhc = true;
      };
      java_language_server.enable = true;
      jsonls.enable = true;
      kotlin_language_server.enable = true;
      nil_ls.enable = true;
      marksman.enable = true;
      ruff.enable = true;
      tailwindcss.enable = true;
      ts_ls.enable = true;
      yamlls.enable = true;

      lua_ls = {
        enable = true;
        settings.telemetry.enable = false;
      };

      sqls = {
        enable = true;
      };
    };
#      rust_analyzer = {
#        enable = true;
#        installCargo = true;
#      };
    keymaps.lspBuf = {
      "gd" = "definition";
      "gR" = "references";
      gD = "declaration";
      "gi" = "implementation";
      "gt" = "type_definition";
      "K" = "hover";

      "<leader>ca" = "code_action";
      "<leader>cn" = "rename";
      "<leader>wl" = "list_workspace_folders";
      "<leader>wr" = "remove_workspace_folder";
      "<leader>wa" = "add_workspace_folder";
    };
  };
  plugins.rustaceanvim.enable = true;
}
