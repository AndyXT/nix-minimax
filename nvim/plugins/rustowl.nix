# RustOwl - visualize ownership and lifetimes in Rust
#
# Requires the rustowl-flake overlay applied to nixpkgs.
# The overlay composes rust-overlay (for the special nightly toolchain
# rustowl needs) with the rustowl package definitions, so you get both
# in one overlay.
#
# In your consuming flake:
#
#   inputs.rustowl-flake.url = "github:nix-community/rustowl-flake";
#
#   # Where you configure nixpkgs:
#   overlays = [ inputs.rustowl-flake.overlays.default ];
#
# Available setup({}) options:
#   auto_attach      = true          -- auto-attach to rust buffers
#   auto_enable      = false         -- auto-enable highlighting on attach
#   idle_time        = 500           -- ms before triggering analysis
#   highlight_style  = "undercurl"   -- "undercurl" or "underline"
#   colors.lifetime  = "#00cc00"
#   colors.imm_borrow = "#0000cc"
#   colors.mut_borrow = "#cc00cc"
#   colors.move      = "#cccc00"
#   colors.call      = "#cccc00"
#   colors.outlive   = "#cc0000"
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.rustowl-nvim ];
    extraPackages = [ pkgs.rustowl ];
    extraConfigLua = ''
      require("rustowl").setup({})
    '';
  };
}
