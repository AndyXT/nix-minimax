{ ... }:
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    plugins.treesitter-textobjects = {
      enable = true;
    };
  };
}
