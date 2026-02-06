{ pkgs, ... }:
{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./mini
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      stylua
    ];

    # Bootstrap mini.extra before the alphabetically-ordered module setup
    # so that MiniExtra is available for ai/hipatterns config
    extraConfigLuaPre = ''
      require('mini.extra').setup({})
    '';

    # Colorscheme - miniwinter ships with mini.nvim
    extraConfigLua = ''
      vim.cmd('colorscheme miniwinter')
    '';
  };
}
