{ pkgs, ... }:
let
  cscope-maps-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "cscope_maps-nvim";
    version = "unstable";
    src = pkgs.fetchFromGitHub {
      owner = "dhananjaylatkar";
      repo = "cscope_maps.nvim";
      rev = "main";
      hash = "sha256-XE3p4BKGlIgxP9ln/oSlZBWkTLw5sEkdk8waR9Atulg=";
    };
    # telescope and fzf-lua pickers are optional
    nvimRequireCheck = "cscope_maps";
  };
in
{
  programs.nixvim = {
    extraPlugins = [ cscope-maps-nvim ];
    extraConfigLua = ''
      require("cscope_maps").setup({})
    '';
  };
}
