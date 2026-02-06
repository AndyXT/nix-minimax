{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    completion = {
      lsp_completion = {
        source_func = "omnifunc";
        auto_setup = false;
        process_items = {
          __raw = ''
            function(items, base)
              return MiniCompletion.default_process_items(items, base,
                { kind_priority = { Text = -1, Snippet = 99 } })
            end
          '';
        };
      };
    };

    snippets = {
      snippets = {
        __raw = ''
          {
            require('mini.snippets').gen_loader.from_file(
              vim.fn.stdpath('config') .. '/snippets/global.json'
            ),
            require('mini.snippets').gen_loader.from_lang({
              lang_patterns = {
                tex = { 'latex/**/*.json', '**/latex.json' },
                plaintex = { 'latex/**/*.json', '**/latex.json' },
                markdown_inline = { 'markdown.json' },
              },
            }),
          }
        '';
      };
    };

    keymap = {};
  };

  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
      end,
      desc = "Set 'omnifunc'",
    })
    vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
    MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
    MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
    MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
    MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
  '';

  programs.nixvim.extraFiles = {
    "snippets/global.json".text = builtins.toJSON {
      "Current datetime" = {
        prefix = "cdtm";
        body = "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE $CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND";
        description = "Insert current datetime (YYYY-mm-dd HH:MM:SS)";
      };
      "Current date" = {
        prefix = "cdate";
        body = "$CURRENT_YEAR-$CURRENT_MONTH-$CURRENT_DATE";
        description = "Insert current date (YYYY-mm-dd)";
      };
      "Current time" = {
        prefix = "ctime";
        body = "$CURRENT_HOUR:$CURRENT_MINUTE:$CURRENT_SECOND";
        description = "Insert current time (HH:MM:SS)";
      };
    };
  };
}
