{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    ai = {
      custom_textobjects = {
        B = { __raw = "MiniExtra.gen_ai_spec.buffer()"; };
        F = { __raw = "require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' })"; };
      };
      search_method = "cover";
    };
    align = {};
    comment = {};
    move = {};
    operators = {};
    pairs = {
      modes = { command = true; };
    };
    splitjoin = {};
    surround = {};
  };

  programs.nixvim.extraConfigLua = ''
    vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
    vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
  '';
}
