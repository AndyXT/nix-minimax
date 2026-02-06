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

    # Colorscheme - miniwinter ships with mini.nvim
    extraConfigLua = ''
      vim.cmd('colorscheme miniwinter')
    '';
  };
}
