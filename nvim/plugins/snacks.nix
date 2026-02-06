{ ... }:
{
  programs.nixvim.plugins.snacks = {
    enable = true;
    settings = {
      lazygit = {
        enabled = true;
      };
    };
  };
}
