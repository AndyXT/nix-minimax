{ ... }:
{
  programs.nixvim = {
    globals.mapleader = " ";

    opts = {
      # General
      mouse = "a";
      mousescroll = "ver:25,hor:6";
      switchbuf = "usetab";
      undofile = true;
      shada = "'100,<50,s10,:1000,/100,@100,h";

      # UI
      breakindent = true;
      breakindentopt = "list:-1";
      colorcolumn = "+1";
      cursorline = true;
      cursorlineopt = "screenline,number";
      linebreak = true;
      list = true;
      number = true;
      pumheight = 10;
      ruler = false;
      shortmess = "CFOSWaco";
      showmode = false;
      signcolumn = "yes";
      splitbelow = true;
      splitkeep = "screen";
      splitright = true;
      winborder = "single";
      wrap = false;
      fillchars = "eob: ,fold:╌";
      listchars = "extends:…,nbsp:␣,precedes:…,tab:> ";

      # Folds
      foldlevel = 10;
      foldmethod = "indent";
      foldnestmax = 10;
      foldtext = "";

      # Editing
      autoindent = true;
      expandtab = true;
      formatoptions = "rqnl1j";
      ignorecase = true;
      incsearch = true;
      infercase = true;
      shiftwidth = 2;
      smartcase = true;
      smartindent = true;
      spelloptions = "camel";
      tabstop = 2;
      virtualedit = "block";
      iskeyword = "@,48-57,_,192-255,-";
      formatlistpat = "^\\s*[0-9\\-\\+\\*]\\+[\\.\\)]*\\s\\+";

      # Built-in completion
      complete = ".,w,b,kspell";
      completeopt = "menuone,noselect,fuzzy,nosort";
    };

    # Diagnostics
    diagnostics = {
      signs = {
        __raw = "{ priority = 9999, severity = { min = 'WARN', max = 'ERROR' } }";
      };
      underline = {
        __raw = "{ severity = { min = 'HINT', max = 'ERROR' } }";
      };
      virtual_lines = false;
      virtual_text = {
        __raw = "{ current_line = true, severity = { min = 'ERROR', max = 'ERROR' } }";
      };
      update_in_insert = false;
    };

    # Autocommands
    autoGroups.custom-config.clear = true;

    autoCmd = [
      {
        event = [ "FileType" ];
        pattern = [ "*" ];
        group = "custom-config";
        command = "setlocal formatoptions-=c formatoptions-=o";
        desc = "Proper 'formatoptions'";
      }
      # Task 15: Markdown filetype config
      {
        event = [ "FileType" ];
        pattern = [ "markdown" ];
        group = "custom-config";
        callback.__raw = ''
          function()
            vim.cmd('setlocal spell wrap')
            vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')
            pcall(vim.keymap.del, 'n', 'gO', { buffer = 0 })
            vim.b.minisurround_config = {
              custom_surroundings = {
                L = {
                  input = { '%[().-()%]%(.-%)' },
                  output = function()
                    local link = require('mini.surround').user_input('Link: ')
                    return { left = '[', right = '](' .. link .. ')' }
                  end,
                },
              },
            }
          end
        '';
        desc = "Markdown filetype settings";
      }
    ];

    # Filetype and syntax
    extraConfigLuaPre = ''
      vim.cmd('filetype plugin indent on')
      if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end
    '';
  };
}
