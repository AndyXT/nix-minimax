{ ... }:
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;
    settings = {
      default_format_opts = {
        lsp_format = "fallback";
      };
      # Uncomment and add formatters as needed:
      # formatters_by_ft = {
      #   lua = [ "stylua" ];
      #   rust = [ "rustfmt" ];
      #   nix = [ "nixpkgs_fmt" ];
      # };
    };
  };
}
