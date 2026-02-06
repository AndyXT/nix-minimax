{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    basics = {
      options = { basic = false; };
      mappings = {
        windows = true;
        move_with_alt = true;
      };
    };

    bufremove = {};

    clue = {
      clues = {
        __raw = ''
          {
            { mode = 'n', keys = '<Leader>b', desc = '+Buffer' },
            { mode = 'n', keys = '<Leader>e', desc = '+Explore/Edit' },
            { mode = 'n', keys = '<Leader>f', desc = '+Find' },
            { mode = 'n', keys = '<Leader>g', desc = '+Git' },
            { mode = 'n', keys = '<Leader>l', desc = '+Language' },
            { mode = 'n', keys = '<Leader>m', desc = '+Map' },
            { mode = 'n', keys = '<Leader>o', desc = '+Other' },
            { mode = 'n', keys = '<Leader>s', desc = '+Session' },
            { mode = 'n', keys = '<Leader>t', desc = '+Terminal' },
            { mode = 'n', keys = '<Leader>v', desc = '+Visits' },
            { mode = 'x', keys = '<Leader>g', desc = '+Git' },
            { mode = 'x', keys = '<Leader>l', desc = '+Language' },
            require('mini.clue').gen_clues.builtin_completion(),
            require('mini.clue').gen_clues.g(),
            require('mini.clue').gen_clues.marks(),
            require('mini.clue').gen_clues.registers(),
            require('mini.clue').gen_clues.square_brackets(),
            require('mini.clue').gen_clues.windows({ submode_resize = true }),
            require('mini.clue').gen_clues.z(),
          }
        '';
      };
      triggers = {
        __raw = ''
          {
            { mode = { 'n', 'x' }, keys = '<Leader>' },
            { mode = 'n',          keys = '\\' },
            { mode = { 'n', 'x' }, keys = '[' },
            { mode = { 'n', 'x' }, keys = ']' },
            { mode = 'i',          keys = '<C-x>' },
            { mode = { 'n', 'x' }, keys = 'g' },
            { mode = { 'n', 'x' }, keys = "'" },
            { mode = { 'n', 'x' }, keys = '`' },
            { mode = { 'n', 'x' }, keys = '"' },
            { mode = { 'i', 'c' }, keys = '<C-r>' },
            { mode = 'n',          keys = '<C-w>' },
            { mode = { 'n', 'x' }, keys = 's' },
            { mode = { 'n', 'x' }, keys = 'z' },
          }
        '';
      };
    };

    cmdline = {};
    extra = {};
    misc = {};
    sessions = {};
  };

  programs.nixvim.extraConfigLua = ''
    MiniMisc.setup_auto_root()
    MiniMisc.setup_restore_cursor()
    MiniMisc.setup_termbg_sync()
  '';
}
