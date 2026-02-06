{ ... }:
{
  programs.nixvim = {
    keymaps = [
      # General mappings ==========================================================

      # Paste linewise before/after current line
      # Usage: `yiw` to yank a word and `]p` to put it on the next line.
      { mode = "n"; key = "[p"; action = "<Cmd>exe \"put! \" . v:register<CR>"; options.desc = "Paste Above"; }
      { mode = "n"; key = "]p"; action = "<Cmd>exe \"put \"  . v:register<CR>"; options.desc = "Paste Below"; }

      # Leader mappings ============================================================
      #
      # This config uses a "two key Leader mappings" approach: first key describes
      # semantic group, second key executes an action.

      # b - Buffer -----------------------------------------------------------------
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

      # e - Explore/Edit -----------------------------------------------------------
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

      # f - Find (mini.pick) -------------------------------------------------------
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

      # g - Git --------------------------------------------------------------------
      { mode = "n"; key = "<leader>gg"; action = "<Cmd>lua Snacks.lazygit()<CR>"; options.desc = "Lazygit"; }
      { mode = "n"; key = "<leader>ga"; action = "<Cmd>Git diff --cached<CR>"; options.desc = "Added diff"; }
      { mode = "n"; key = "<leader>gA"; action = "<Cmd>Git diff --cached -- %<CR>"; options.desc = "Added diff buffer"; }
      { mode = "n"; key = "<leader>gc"; action = "<Cmd>Git commit<CR>"; options.desc = "Commit"; }
      { mode = "n"; key = "<leader>gC"; action = "<Cmd>Git commit --amend<CR>"; options.desc = "Commit amend"; }
      { mode = "n"; key = "<leader>gd"; action = "<Cmd>Git diff<CR>"; options.desc = "Diff"; }
      { mode = "n"; key = "<leader>gD"; action = "<Cmd>Git diff -- %<CR>"; options.desc = "Diff buffer"; }
      { mode = "n"; key = "<leader>gl"; action = "<Cmd>Git log --pretty=format:\\%h\\ \\%as\\ \u2502\\ \\%s --topo-order<CR>"; options.desc = "Log"; }
      { mode = "n"; key = "<leader>gL"; action = "<Cmd>Git log --pretty=format:\\%h\\ \\%as\\ \u2502\\ \\%s --topo-order --follow -- %<CR>"; options.desc = "Log buffer"; }
      { mode = "n"; key = "<leader>go"; action = "<Cmd>lua MiniDiff.toggle_overlay()<CR>"; options.desc = "Toggle overlay"; }
      { mode = "n"; key = "<leader>gs"; action = "<Cmd>lua MiniGit.show_at_cursor()<CR>"; options.desc = "Show at cursor"; }
      { mode = "x"; key = "<leader>gs"; action = "<Cmd>lua MiniGit.show_at_cursor()<CR>"; options.desc = "Show at selection"; }

      # l - Language/LSP -----------------------------------------------------------
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

      # m - Map --------------------------------------------------------------------
      { mode = "n"; key = "<leader>mf"; action = "<Cmd>lua MiniMap.toggle_focus()<CR>"; options.desc = "Focus (toggle)"; }
      { mode = "n"; key = "<leader>mr"; action = "<Cmd>lua MiniMap.refresh()<CR>"; options.desc = "Refresh"; }
      { mode = "n"; key = "<leader>ms"; action = "<Cmd>lua MiniMap.toggle_side()<CR>"; options.desc = "Side (toggle)"; }
      { mode = "n"; key = "<leader>mt"; action = "<Cmd>lua MiniMap.toggle()<CR>"; options.desc = "Toggle"; }

      # o - Other ------------------------------------------------------------------
      { mode = "n"; key = "<leader>or"; action = "<Cmd>lua MiniMisc.resize_window()<CR>"; options.desc = "Resize to default width"; }
      { mode = "n"; key = "<leader>ot"; action = "<Cmd>lua MiniTrailspace.trim()<CR>"; options.desc = "Trim trailspace"; }
      { mode = "n"; key = "<leader>oz"; action = "<Cmd>lua MiniMisc.zoom()<CR>"; options.desc = "Zoom toggle"; }

      # s - Session ----------------------------------------------------------------
      { mode = "n"; key = "<leader>sd"; action = "<Cmd>lua MiniSessions.select('delete')<CR>"; options.desc = "Delete"; }
      { mode = "n"; key = "<leader>sn"; action = "<Cmd>lua MiniSessions.write(vim.fn.input('Session name: '))<CR>"; options.desc = "New"; }
      { mode = "n"; key = "<leader>sr"; action = "<Cmd>lua MiniSessions.select('read')<CR>"; options.desc = "Read"; }
      { mode = "n"; key = "<leader>sw"; action = "<Cmd>lua MiniSessions.write()<CR>"; options.desc = "Write current"; }

      # t - Terminal ----------------------------------------------------------------
      { mode = "n"; key = "<leader>tT"; action = "<Cmd>horizontal term<CR>"; options.desc = "Terminal (horizontal)"; }
      { mode = "n"; key = "<leader>tt"; action = "<Cmd>vertical term<CR>"; options.desc = "Terminal (vertical)"; }

      # v - Visits -----------------------------------------------------------------
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
