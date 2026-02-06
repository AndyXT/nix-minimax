{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
      grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
        bash
        c
        lua
        markdown
        markdown_inline
        nix
        python
        rust
        toml
        yaml
      ];
    };

    plugins.treesitter-textobjects = {
      enable = true;
    };
  };
}
