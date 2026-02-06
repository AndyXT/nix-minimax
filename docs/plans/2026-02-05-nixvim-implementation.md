# nixvim MiniMax Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Translate the full MiniMax Neovim config into a pure nixvim modular setup with 18 files.

**Architecture:** Home-manager module structure where `nvim/default.nix` is the entry point, importing `options.nix`, `keymaps.nix`, `mini/` (6 files), and `plugins/` (8 files). Each file is a NixOS module that sets `programs.nixvim` attributes. The module system merges all definitions.

**Tech Stack:** Nix, nixvim, home-manager, mini.nvim, nvim-treesitter, nvim-lspconfig, conform.nvim, friendly-snippets, dropbar.nvim, rustaceanvim, clangd_extensions.nvim, cscope_maps.nvim

**Reference:** MiniMax source at `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/`

---

### Task 1: Scaffold Directory Structure

**Files:**
- Create: `nvim/default.nix`
- Create: `nvim/mini/default.nix`
- Create: `nvim/plugins/default.nix`

**Step 1: Create directories**

```bash
mkdir -p ~/proj/nix-minimax/nvim/mini ~/proj/nix-minimax/nvim/plugins
```

**Step 2: Write `nvim/default.nix`**

```nix
{ pkgs, ... }:
{
  imports = [
    ./options.nix
    ./keymaps.nix
    ./mini
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    extraPackages = with pkgs; [
      ripgrep
      fd
      stylua
    ];

    # Colorscheme - miniwinter ships with mini.nvim
    extraConfigLua = ''
      vim.cmd('colorscheme miniwinter')
    '';
  };
}
```

**Step 3: Write `nvim/mini/default.nix`**

```nix
{
  imports = [
    ./ui.nix
    ./editing.nix
    ./navigation.nix
    ./git.nix
    ./completion.nix
    ./misc.nix
  ];
}
```

**Step 4: Write `nvim/plugins/default.nix`**

```nix
{
  imports = [
    ./treesitter.nix
    ./lsp.nix
    ./conform.nix
    ./snippets.nix
    ./dropbar.nix
    ./rustacean.nix
    ./clangd.nix
    ./cscope.nix
  ];
}
```

**Step 5: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/
git commit -m "feat: scaffold nvim directory structure"
```

---

### Task 2: Options

**Files:**
- Create: `nvim/options.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/10_options.lua`

**Step 1: Write `nvim/options.nix`**

```nix
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
    ];

    # Filetype and syntax (usually auto-enabled, but matching MiniMax)
    extraConfigLuaPre = ''
      vim.cmd('filetype plugin indent on')
      if vim.fn.exists('syntax_on') ~= 1 then vim.cmd('syntax enable') end
    '';
  };
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/options.nix
git commit -m "feat: add neovim options"
```

---

### Task 3: Keymaps

**Files:**
- Create: `nvim/keymaps.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/20_keymaps.lua`

**Step 1: Write `nvim/keymaps.nix`**

```nix
{ ... }:
{
  programs.nixvim = {
    keymaps = [
      # General mappings
      { mode = "n"; key = "[p"; action = "<Cmd>exe \"put! \" . v:register<CR>"; options.desc = "Paste Above"; }
      { mode = "n"; key = "]p"; action = "<Cmd>exe \"put \"  . v:register<CR>"; options.desc = "Paste Below"; }

      # b - Buffer
      { mode = "n"; key = "<leader>ba"; action = "<Cmd>b#<CR>"; options.desc = "Alternate"; }
      { mode = "n"; key = "<leader>bd"; action = "<Cmd>lua MiniBufremove.delete()<CR>"; options.desc = "Delete"; }
      { mode = "n"; key = "<leader>bD"; action = "<Cmd>lua MiniBufremove.delete(0, true)<CR>"; options.desc = "Delete!"; }
      {
        mode = "n"; key = "<leader>bs"; options.desc = "Scratch";
        action.__raw = ''
          function()
            vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, true))
          end
        '';
      }
      { mode = "n"; key = "<leader>bw"; action = "<Cmd>lua MiniBufremove.wipeout()<CR>"; options.desc = "Wipeout"; }
      { mode = "n"; key = "<leader>bW"; action = "<Cmd>lua MiniBufremove.wipeout(0, true)<CR>"; options.desc = "Wipeout!"; }

      # e - Explore/Edit
      { mode = "n"; key = "<leader>ed"; action = "<Cmd>lua MiniFiles.open()<CR>"; options.desc = "Directory"; }
      { mode = "n"; key = "<leader>ef"; action = "<Cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0))<CR>"; options.desc = "File directory"; }
      { mode = "n"; key = "<leader>ei"; action = "<Cmd>edit $MYVIMRC<CR>"; options.desc = "init.lua"; }
      { mode = "n"; key = "<leader>en"; action = "<Cmd>lua MiniNotify.show_history()<CR>"; options.desc = "Notifications"; }
      {
        mode = "n"; key = "<leader>eq"; options.desc = "Quickfix list";
        action.__raw = ''
          function()
            vim.cmd(vim.fn.getqflist({ winid = true }).winid ~= 0 and 'cclose' or 'copen')
          end
        '';
      }
      {
        mode = "n"; key = "<leader>eQ"; options.desc = "Location list";
        action.__raw = ''
          function()
            vim.cmd(vim.fn.getloclist(0, { winid = true }).winid ~= 0 and 'lclose' or 'lopen')
          end
        '';
      }

      # f - Find (mini.pick)
      { mode = "n"; key = "<leader>f/"; action = "<Cmd>Pick history scope=\"/\"<CR>"; options.desc = "\"/\" history"; }
      { mode = "n"; key = "<leader>f:"; action = "<Cmd>Pick history scope=\":\"<CR>"; options.desc = "\":\" history"; }
      { mode = "n"; key = "<leader>fa"; action = "<Cmd>Pick git_hunks scope=\"staged\"<CR>"; options.desc = "Added hunks (all)"; }
      { mode = "n"; key = "<leader>fA"; action = "<Cmd>Pick git_hunks path=\"%\" scope=\"staged\"<CR>"; options.desc = "Added hunks (buf)"; }
      { mode = "n"; key = "<leader>fb"; action = "<Cmd>Pick buffers<CR>"; options.desc = "Buffers"; }
      { mode = "n"; key = "<leader>fc"; action = "<Cmd>Pick git_commits<CR>"; options.desc = "Commits (all)"; }
      { mode = "n"; key = "<leader>fC"; action = "<Cmd>Pick git_commits path=\"%\"<CR>"; options.desc = "Commits (buf)"; }
      { mode = "n"; key = "<leader>fd"; action = "<Cmd>Pick diagnostic scope=\"all\"<CR>"; options.desc = "Diagnostic workspace"; }
      { mode = "n"; key = "<leader>fD"; action = "<Cmd>Pick diagnostic scope=\"current\"<CR>"; options.desc = "Diagnostic buffer"; }
      { mode = "n"; key = "<leader>ff"; action = "<Cmd>Pick files<CR>"; options.desc = "Files"; }
      { mode = "n"; key = "<leader>fg"; action = "<Cmd>Pick grep_live<CR>"; options.desc = "Grep live"; }
      { mode = "n"; key = "<leader>fG"; action = "<Cmd>Pick grep pattern=\"<cword>\"<CR>"; options.desc = "Grep current word"; }
      { mode = "n"; key = "<leader>fh"; action = "<Cmd>Pick help<CR>"; options.desc = "Help tags"; }
      { mode = "n"; key = "<leader>fH"; action = "<Cmd>Pick hl_groups<CR>"; options.desc = "Highlight groups"; }
      { mode = "n"; key = "<leader>fl"; action = "<Cmd>Pick buf_lines scope=\"all\"<CR>"; options.desc = "Lines (all)"; }
      { mode = "n"; key = "<leader>fL"; action = "<Cmd>Pick buf_lines scope=\"current\"<CR>"; options.desc = "Lines (buf)"; }
      { mode = "n"; key = "<leader>fm"; action = "<Cmd>Pick git_hunks<CR>"; options.desc = "Modified hunks (all)"; }
      { mode = "n"; key = "<leader>fM"; action = "<Cmd>Pick git_hunks path=\"%\"<CR>"; options.desc = "Modified hunks (buf)"; }
      { mode = "n"; key = "<leader>fr"; action = "<Cmd>Pick resume<CR>"; options.desc = "Resume"; }
      { mode = "n"; key = "<leader>fR"; action = "<Cmd>Pick lsp scope=\"references\"<CR>"; options.desc = "References (LSP)"; }
      { mode = "n"; key = "<leader>fs"; action = "<Cmd>Pick lsp scope=\"workspace_symbol_live\"<CR>"; options.desc = "Symbols workspace (live)"; }
      { mode = "n"; key = "<leader>fS"; action = "<Cmd>Pick lsp scope=\"document_symbol\"<CR>"; options.desc = "Symbols document"; }
      { mode = "n"; key = "<leader>fv"; action = "<Cmd>Pick visit_paths cwd=\"\"<CR>"; options.desc = "Visit paths (all)"; }
      { mode = "n"; key = "<leader>fV"; action = "<Cmd>Pick visit_paths<CR>"; options.desc = "Visit paths (cwd)"; }

      # g - Git
      { mode = "n"; key = "<leader>ga"; action = "<Cmd>Git diff --cached<CR>"; options.desc = "Added diff"; }
      { mode = "n"; key = "<leader>gA"; action = "<Cmd>Git diff --cached -- %<CR>"; options.desc = "Added diff buffer"; }
      { mode = "n"; key = "<leader>gc"; action = "<Cmd>Git commit<CR>"; options.desc = "Commit"; }
      { mode = "n"; key = "<leader>gC"; action = "<Cmd>Git commit --amend<CR>"; options.desc = "Commit amend"; }
      { mode = "n"; key = "<leader>gd"; action = "<Cmd>Git diff<CR>"; options.desc = "Diff"; }
      { mode = "n"; key = "<leader>gD"; action = "<Cmd>Git diff -- %<CR>"; options.desc = "Diff buffer"; }
      { mode = "n"; key = "<leader>gl"; action = "<Cmd>Git log --pretty=format:\\%h\\ \\%as\\ │\\ \\%s --topo-order<CR>"; options.desc = "Log"; }
      { mode = "n"; key = "<leader>gL"; action = "<Cmd>Git log --pretty=format:\\%h\\ \\%as\\ │\\ \\%s --topo-order --follow -- %<CR>"; options.desc = "Log buffer"; }
      { mode = "n"; key = "<leader>go"; action = "<Cmd>lua MiniDiff.toggle_overlay()<CR>"; options.desc = "Toggle overlay"; }
      { mode = "n"; key = "<leader>gs"; action = "<Cmd>lua MiniGit.show_at_cursor()<CR>"; options.desc = "Show at cursor"; }
      { mode = "x"; key = "<leader>gs"; action = "<Cmd>lua MiniGit.show_at_cursor()<CR>"; options.desc = "Show at selection"; }

      # l - Language/LSP
      { mode = "n"; key = "<leader>la"; action = "<Cmd>lua vim.lsp.buf.code_action()<CR>"; options.desc = "Actions"; }
      { mode = "n"; key = "<leader>ld"; action = "<Cmd>lua vim.diagnostic.open_float()<CR>"; options.desc = "Diagnostic popup"; }
      { mode = "n"; key = "<leader>lf"; action = "<Cmd>lua require('conform').format()<CR>"; options.desc = "Format"; }
      { mode = "n"; key = "<leader>li"; action = "<Cmd>lua vim.lsp.buf.implementation()<CR>"; options.desc = "Implementation"; }
      { mode = "n"; key = "<leader>lh"; action = "<Cmd>lua vim.lsp.buf.hover()<CR>"; options.desc = "Hover"; }
      { mode = "n"; key = "<leader>lr"; action = "<Cmd>lua vim.lsp.buf.rename()<CR>"; options.desc = "Rename"; }
      { mode = "n"; key = "<leader>lR"; action = "<Cmd>lua vim.lsp.buf.references()<CR>"; options.desc = "References"; }
      { mode = "n"; key = "<leader>ls"; action = "<Cmd>lua vim.lsp.buf.definition()<CR>"; options.desc = "Source definition"; }
      { mode = "n"; key = "<leader>lt"; action = "<Cmd>lua vim.lsp.buf.type_definition()<CR>"; options.desc = "Type definition"; }
      { mode = "x"; key = "<leader>lf"; action = "<Cmd>lua require('conform').format()<CR>"; options.desc = "Format selection"; }

      # m - Map
      { mode = "n"; key = "<leader>mf"; action = "<Cmd>lua MiniMap.toggle_focus()<CR>"; options.desc = "Focus (toggle)"; }
      { mode = "n"; key = "<leader>mr"; action = "<Cmd>lua MiniMap.refresh()<CR>"; options.desc = "Refresh"; }
      { mode = "n"; key = "<leader>ms"; action = "<Cmd>lua MiniMap.toggle_side()<CR>"; options.desc = "Side (toggle)"; }
      { mode = "n"; key = "<leader>mt"; action = "<Cmd>lua MiniMap.toggle()<CR>"; options.desc = "Toggle"; }

      # o - Other
      { mode = "n"; key = "<leader>or"; action = "<Cmd>lua MiniMisc.resize_window()<CR>"; options.desc = "Resize to default width"; }
      { mode = "n"; key = "<leader>ot"; action = "<Cmd>lua MiniTrailspace.trim()<CR>"; options.desc = "Trim trailspace"; }
      { mode = "n"; key = "<leader>oz"; action = "<Cmd>lua MiniMisc.zoom()<CR>"; options.desc = "Zoom toggle"; }

      # s - Session
      { mode = "n"; key = "<leader>sd"; action = "<Cmd>lua MiniSessions.select('delete')<CR>"; options.desc = "Delete"; }
      { mode = "n"; key = "<leader>sn"; action = "<Cmd>lua MiniSessions.write(vim.fn.input('Session name: '))<CR>"; options.desc = "New"; }
      { mode = "n"; key = "<leader>sr"; action = "<Cmd>lua MiniSessions.select('read')<CR>"; options.desc = "Read"; }
      { mode = "n"; key = "<leader>sw"; action = "<Cmd>lua MiniSessions.write()<CR>"; options.desc = "Write current"; }

      # t - Terminal
      { mode = "n"; key = "<leader>tT"; action = "<Cmd>horizontal term<CR>"; options.desc = "Terminal (horizontal)"; }
      { mode = "n"; key = "<leader>tt"; action = "<Cmd>vertical term<CR>"; options.desc = "Terminal (vertical)"; }

      # v - Visits
      {
        mode = "n"; key = "<leader>vc"; options.desc = "Core visits (all)";
        action.__raw = ''
          function()
            local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
            MiniExtra.pickers.visit_paths(
              { cwd = "", filter = "core", sort = sort_latest },
              { source = { name = "Core visits (all)" } }
            )
          end
        '';
      }
      {
        mode = "n"; key = "<leader>vC"; options.desc = "Core visits (cwd)";
        action.__raw = ''
          function()
            local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
            MiniExtra.pickers.visit_paths(
              { cwd = nil, filter = "core", sort = sort_latest },
              { source = { name = "Core visits (cwd)" } }
            )
          end
        '';
      }
      { mode = "n"; key = "<leader>vv"; action = "<Cmd>lua MiniVisits.add_label('core')<CR>"; options.desc = "Add \"core\" label"; }
      { mode = "n"; key = "<leader>vV"; action = "<Cmd>lua MiniVisits.remove_label('core')<CR>"; options.desc = "Remove \"core\" label"; }
      { mode = "n"; key = "<leader>vl"; action = "<Cmd>lua MiniVisits.add_label()<CR>"; options.desc = "Add label"; }
      { mode = "n"; key = "<leader>vL"; action = "<Cmd>lua MiniVisits.remove_label()<CR>"; options.desc = "Remove label"; }
    ];
  };
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/keymaps.nix
git commit -m "feat: add keymaps"
```

---

### Task 4: Mini UI Modules

**Files:**
- Create: `nvim/mini/ui.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/30_mini.lua` (lines 30-590)

Modules: statusline, tabline, starter, notify, icons, map, indentscope, hipatterns, trailspace

**Step 1: Write `nvim/mini/ui.nix`**

```nix
{ ... }:
{
  programs.nixvim = {
    plugins.mini = {
      enable = true;
      modules = {
        # Statusline
        statusline = {};

        # Tabline
        tabline = {};

        # Start screen
        starter = {};

        # Notifications
        notify = {};

        # Icons
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

        # Indentscope
        indentscope = {};

        # Highlight patterns
        hipatterns = {
          highlighters = {
            fixme = { __raw = "MiniExtra.gen_highlighter.words({ 'FIXME', 'Fixme', 'fixme' }, 'MiniHipatternsFixme')"; };
            hack = { __raw = "MiniExtra.gen_highlighter.words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack')"; };
            todo = { __raw = "MiniExtra.gen_highlighter.words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo')"; };
            note = { __raw = "MiniExtra.gen_highlighter.words({ 'NOTE', 'Note', 'note' }, 'MiniHipatternsNote')"; };
            hex_color = { __raw = "require('mini.hipatterns').gen_highlighter.hex_color()"; };
          };
        };

        # Trailspace
        trailspace = {};

        # Map (text overview window)
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

    # Post-setup hooks for icons and map
    extraConfigLua = ''
      -- Icons post-setup
      MiniIcons.mock_nvim_web_devicons()
      MiniIcons.tweak_lsp_kind()

      -- Map: remap search navigation to refresh map
      for _, key in ipairs({ 'n', 'N', '*', '#' }) do
        local rhs = key .. 'zv'
          .. '<Cmd>lua MiniMap.refresh({}, { lines = false, scrollbar = false })<CR>'
        vim.keymap.set('n', key, rhs)
      end
    '';
  };
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/mini/ui.nix
git commit -m "feat: add mini UI modules"
```

---

### Task 5: Mini Editing Modules

**Files:**
- Create: `nvim/mini/editing.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/30_mini.lua`

Modules: ai, align, comment, move, operators, pairs, splitjoin, surround

**Step 1: Write `nvim/mini/editing.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    # Textobjects
    ai = {
      custom_textobjects = {
        B = { __raw = "MiniExtra.gen_ai_spec.buffer()"; };
        F = { __raw = "require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' })"; };
      };
      search_method = "cover";
    };

    # Align text
    align = {};

    # Comment lines
    comment = {};

    # Move selections
    move = {};

    # Text edit operators
    operators = {};

    # Autopairs
    pairs = {
      modes = { command = true; };
    };

    # Split/join arguments
    splitjoin = {};

    # Surround actions
    surround = {};
  };

  # Post-setup: operator swap-argument keymaps
  programs.nixvim.extraConfigLua = ''
    -- Swap adjacent arguments with ( and )
    vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
    vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
  '';
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/mini/editing.nix
git commit -m "feat: add mini editing modules"
```

---

### Task 6: Mini Navigation Modules

**Files:**
- Create: `nvim/mini/navigation.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/30_mini.lua`

Modules: files, pick, jump, jump2d, bracketed, visits

**Step 1: Write `nvim/mini/navigation.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    # File explorer
    files = {
      windows = { preview = true; };
    };

    # Fuzzy picker
    pick = {};

    # Jump to character
    jump = {};

    # Jump to visible spots
    jump2d = {};

    # Navigate with square brackets
    bracketed = {};

    # Track file visits
    visits = {};
  };

  # Post-setup: file explorer bookmarks
  programs.nixvim.extraConfigLua = ''
    -- Add bookmarks to every file explorer instance
    vim.api.nvim_create_autocmd('User', {
      pattern = 'MiniFilesExplorerOpen',
      callback = function()
        MiniFiles.set_bookmark('c', vim.fn.stdpath('config'), { desc = 'Config' })
        local minideps_plugins = vim.fn.stdpath('data') .. '/site/pack/deps/opt'
        MiniFiles.set_bookmark('p', minideps_plugins, { desc = 'Plugins' })
        MiniFiles.set_bookmark('w', vim.fn.getcwd, { desc = 'Working directory' })
      end,
      desc = 'Add bookmarks',
    })
  '';
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/mini/navigation.nix
git commit -m "feat: add mini navigation modules"
```

---

### Task 7: Mini Git Modules

**Files:**
- Create: `nvim/mini/git.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/30_mini.lua`

Modules: git, diff

**Step 1: Write `nvim/mini/git.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    git = {};
    diff = {};
  };
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/mini/git.nix
git commit -m "feat: add mini git modules"
```

---

### Task 8: Mini Completion Modules

**Files:**
- Create: `nvim/mini/completion.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/30_mini.lua` (lines 138-192, 535-556, 717-742)

Modules: completion, snippets, keymap

**Step 1: Write `nvim/mini/completion.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    # Completion
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

    # Snippets
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

    # Special key mappings
    keymap = {};
  };

  # Post-setup hooks
  programs.nixvim.extraConfigLua = ''
    -- Completion: set omnifunc on LSP attach
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(ev)
        vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp'
      end,
      desc = "Set 'omnifunc'",
    })

    -- Completion: advertise capabilities to LSP servers
    vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })

    -- Keymap: Tab/S-Tab for completion menu, CR for accept, BS for pairs
    MiniKeymap.map_multistep('i', '<Tab>', { 'pmenu_next' })
    MiniKeymap.map_multistep('i', '<S-Tab>', { 'pmenu_prev' })
    MiniKeymap.map_multistep('i', '<CR>', { 'pmenu_accept', 'minipairs_cr' })
    MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })
  '';

  # Snippet files
  programs.nixvim.extraFiles = {
    "snippets/global.json" = builtins.toJSON {
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
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/mini/completion.nix
git commit -m "feat: add mini completion modules"
```

---

### Task 9: Mini Misc Modules

**Files:**
- Create: `nvim/mini/misc.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/30_mini.lua`

Modules: basics, bufremove, clue, cmdline, extra, misc, sessions

**Step 1: Write `nvim/mini/misc.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    # Common presets
    basics = {
      options = { basic = false; };
      mappings = {
        windows = true;
        move_with_alt = true;
      };
    };

    # Buffer removal
    bufremove = {};

    # Next key clues
    clue = {
      clues = {
        __raw = ''
          {
            -- Leader group descriptions
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

    # Command line tweaks
    cmdline = {};

    # Extra functionality
    extra = {};

    # Miscellaneous utilities
    misc = {};

    # Session management
    sessions = {};
  };

  # Post-setup hooks for misc
  programs.nixvim.extraConfigLua = ''
    -- Auto root detection
    MiniMisc.setup_auto_root()
    -- Restore cursor position
    MiniMisc.setup_restore_cursor()
    -- Sync terminal background
    MiniMisc.setup_termbg_sync()
  '';
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/mini/misc.nix
git commit -m "feat: add mini misc modules"
```

---

### Task 10: Treesitter Plugin

**Files:**
- Create: `nvim/plugins/treesitter.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/40_plugins.lua` (lines 15-82)

**Step 1: Write `nvim/plugins/treesitter.nix`**

```nix
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
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/plugins/treesitter.nix
git commit -m "feat: add treesitter plugin"
```

---

### Task 11: LSP Plugin

**Files:**
- Create: `nvim/plugins/lsp.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/40_plugins.lua` (lines 84-109)
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/after/lsp/lua_ls.lua`

**Step 1: Write `nvim/plugins/lsp.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      lua_ls = {
        enable = true;
        settings = {
          Lua = {
            runtime.version = "LuaJIT";
            workspace = {
              ignoreSubmodules = true;
              library = {
                __raw = "{ vim.env.VIMRUNTIME }";
              };
            };
          };
        };
        onAttach.function = ''
          -- Reduce trigger characters for better mini.completion experience
          client.server_capabilities.completionProvider.triggerCharacters =
            { '.', ':', '#', '(' }
        '';
      };
    };
  };
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/plugins/lsp.nix
git commit -m "feat: add LSP plugin"
```

---

### Task 12: Conform Plugin

**Files:**
- Create: `nvim/plugins/conform.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/40_plugins.lua` (lines 111-135)

**Step 1: Write `nvim/plugins/conform.nix`**

```nix
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
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/plugins/conform.nix
git commit -m "feat: add conform plugin"
```

---

### Task 13: Snippets Plugin

**Files:**
- Create: `nvim/plugins/snippets.nix`
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/plugin/40_plugins.lua` (line 146)

**Step 1: Write `nvim/plugins/snippets.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.friendly-snippets.enable = true;
}
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/plugins/snippets.nix
git commit -m "feat: add friendly-snippets plugin"
```

---

### Task 14: Additional Plugins (dropbar, rustacean, clangd, cscope)

**Files:**
- Create: `nvim/plugins/dropbar.nix`
- Create: `nvim/plugins/rustacean.nix`
- Create: `nvim/plugins/clangd.nix`
- Create: `nvim/plugins/cscope.nix`

**Step 1: Write `nvim/plugins/dropbar.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.dropbar = {
    enable = true;
  };
}
```

**Step 2: Write `nvim/plugins/rustacean.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.rustaceanvim = {
    enable = true;
  };
}
```

**Step 3: Write `nvim/plugins/clangd.nix`**

```nix
{ ... }:
{
  programs.nixvim.plugins.clangd-extensions = {
    enable = true;
  };
}
```

**Step 4: Write `nvim/plugins/cscope.nix`**

```nix
{ pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.vimPlugins.cscope_maps-nvim ];
    extraConfigLua = ''
      require("cscope_maps").setup({})
    '';
  };
}
```

**Step 5: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/plugins/dropbar.nix nvim/plugins/rustacean.nix nvim/plugins/clangd.nix nvim/plugins/cscope.nix
git commit -m "feat: add additional plugins (dropbar, rustacean, clangd, cscope)"
```

---

### Task 15: Markdown Filetype Config

**Files:**
- Reference: `/Users/andrestreto/proj/MiniMax/configs/nvim-0.11/after/ftplugin/markdown.lua`

This MiniMax file sets markdown-specific options via ftplugin. In nixvim, we add it as a FileType autocmd in options.nix.

**Step 1: Add markdown autocmd to `nvim/options.nix`**

Append to the existing `autoCmd` list:

```nix
{
  event = [ "FileType" ];
  pattern = [ "markdown" ];
  group = "custom-config";
  callback.__raw = ''
    function()
      vim.cmd('setlocal spell wrap')
      vim.cmd('setlocal foldmethod=expr foldexpr=v:lua.vim.treesitter.foldexpr()')

      -- Disable built-in gO mapping in favor of mini.basics
      pcall(vim.keymap.del, 'n', 'gO', { buffer = 0 })

      -- Markdown-specific surround for links
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
```

**Step 2: Commit**

```bash
cd ~/proj/nix-minimax
git add nvim/options.nix
git commit -m "feat: add markdown filetype config"
```

---

### Task 16: Final Verification

**Step 1: Review all files exist**

```bash
cd ~/proj/nix-minimax
find nvim -name '*.nix' | sort
```

Expected output:
```
nvim/default.nix
nvim/keymaps.nix
nvim/mini/completion.nix
nvim/mini/default.nix
nvim/mini/editing.nix
nvim/mini/git.nix
nvim/mini/misc.nix
nvim/mini/navigation.nix
nvim/mini/ui.nix
nvim/options.nix
nvim/plugins/clangd.nix
nvim/plugins/conform.nix
nvim/plugins/cscope.nix
nvim/plugins/default.nix
nvim/plugins/dropbar.nix
nvim/plugins/lsp.nix
nvim/plugins/rustacean.nix
nvim/plugins/snippets.nix
nvim/plugins/treesitter.nix
```

**Step 2: Syntax check all Nix files (if nix is available)**

```bash
cd ~/proj/nix-minimax
for f in $(find nvim -name '*.nix'); do
  echo "Checking $f..."
  nix-instantiate --parse "$f" > /dev/null 2>&1 && echo "  OK" || echo "  FAIL"
done
```

**Step 3: Commit any fixes**

```bash
cd ~/proj/nix-minimax
git add -A
git commit -m "fix: resolve any nix syntax issues"
```

---

## Integration Notes

To use this config in your existing home-manager flake:

1. Add `nixvim` to your `flake.nix` inputs:
```nix
inputs.nixvim = {
  url = "github:nix-community/nixvim";
};
```

2. Add the nixvim home-manager module:
```nix
modules = [
  nixvim.homeManagerModules.nixvim
  ./path/to/nvim  # or copy nvim/ into your config
];
```

3. Or if keeping nix-minimax as a separate repo, add it as a flake input and import `nvim/default.nix`.
