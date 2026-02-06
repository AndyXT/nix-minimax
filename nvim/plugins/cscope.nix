{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.cscope_maps-nvim ];
    extraConfigLua = ''
      require("cscope_maps").setup({})
    '';
  };
}
