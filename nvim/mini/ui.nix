{ ... }:
{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules = {
        statusline = {};
        tabline = {};
        starter = {};
        notify = {};
        icons = {
          use_file_extension = {
            __raw = ''
              function(ext, _)
                local ext3_blocklist = { scm = true, txt = true, yml = true }
                local ext4_blocklist = { json = true, yaml = true }
                return not (ext3_blocklist[ext:sub(-3)] or ext4_blocklist[ext:sub(-4)])
              end
            '';
          };
        };
        indentscope = {};
        hipatterns = {
          highlighters = {
            fixme = { __raw = "MiniExtra.gen_highlighter.words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme')"; };
            hack = { __raw = "MiniExtra.gen_highlighter.words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack')"; };
            todo = { __raw = "MiniExtra.gen_highlighter.words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo')"; };
            note = { __raw = "MiniExtra.gen_highlighter.words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote')"; };
            hex_color = { __raw = "require('mini.hipatterns').gen_highlighter.hex_color()"; };
          };
        };
        trailspace = {};
        map = {
          symbols = {
            encode = { __raw = "require('mini.map').gen_encode_symbols.dot('4x2')"; };
          };
          integrations = {
            __raw = ''
              {
                require('mini.map').gen_integration.builtin_search(),
                require('mini.map').gen_integration.diff(),
                require('mini.map').gen_integration.diagnostic(),
              }
            '';
          };
        };
      };
    };
    extraConfigLua = ''
      MiniIcons.mock_nvim_web_devicons()
      MiniIcons.tweak_lsp_kind()
      for _, key in ipairs({ 'n', 'N', '*', '#' }) do
        local rhs = key .. 'zv'
          .. '<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>'
        vim.keymap.set('n', key, rhs)
      end
    '';
  };
}
