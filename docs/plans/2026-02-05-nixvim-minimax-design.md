# MiniMax nixvim Translation Design

## Goal

Translate the full MiniMax Neovim configuration into a pure nixvim setup, integrated into an existing flake-based home-manager config. All ~30 mini.nvim modules, 4 external plugins, and 4 additional user plugins are included.

## Approach

**Pure nixvim (Approach A)**: Use nixvim's native module system for everything. Plugin declarations, options, and keymaps are Nix expressions. Lua callbacks that can't be expressed in Nix use nixvim's `__raw` escape hatch.

## Directory Structure

```
nvim/
├── default.nix          # Entry point: imports, nixvim enable, colorscheme, extraPackages
├── options.nix          # Neovim options (mirrors 10_options.lua)
├── keymaps.nix          # Key mappings (mirrors 20_keymaps.lua)
├── mini/
│   ├── default.nix      # Imports all mini module files
│   ├── ui.nix           # statusline, tabline, starter, notify, icons, map,
│   │                    #   indentscope, hipatterns, trailspace
│   ├── editing.nix      # ai, align, comment, move, operators, pairs, splitjoin, surround
│   ├── navigation.nix   # files, pick, jump, jump2d, bracketed, visits
│   ├── git.nix          # git, diff
│   ├── completion.nix   # completion, snippets, keymap
│   └── misc.nix         # basics, bufremove, clue, cmdline, extra, misc, sessions
└── plugins/
    ├── default.nix      # Imports all plugin files
    ├── treesitter.nix   # nvim-treesitter + textobjects
    ├── lsp.nix          # nvim-lspconfig + server declarations
    ├── conform.nix      # stevearc/conform.nvim
    ├── snippets.nix     # friendly-snippets
    ├── dropbar.nix      # dropbar.nvim
    ├── rustacean.nix    # rustaceanvim
    ├── clangd.nix       # clangd_extensions.nvim
    └── cscope.nix       # cscope_maps.nvim
```

## Integration

`home.nix` imports `nvim/default.nix`, which fans out to all sub-modules.

## Translation Rules

### Options (options.nix)

- `vim.g.mapleader = ' '` becomes `globals.mapleader = " ";`
- `vim.o.xxx = value` becomes `opts.xxx = value;`
- Diagnostic config uses `diagnostics = { ... };`
- The `formatoptions` autocmd uses `autoCmd = [ { ... } ];`

### Keymaps (keymaps.nix)

- Each mapping becomes an entry in `keymaps = [ { mode; key; action; options.desc; } ];`
- Simple `<Cmd>...<CR>` mappings are pure Nix strings
- Callback functions (e.g., `new_scratch_buffer`, `make_pick_core`) use `action.__raw`
- `edit_plugin_file` mappings point to the Nix source directory

### Mini Modules

All modules configured via `plugins.mini.modules = { ... };`.

**Pure Nix modules** (default or simple config):
align, bracketed, bufremove, cmdline, comment, diff, extra, git, indentscope,
jump, jump2d, move, pick, sessions, splitjoin, starter, statusline, surround,
tabline, trailspace, visits

**Modules needing `__raw`**:
- `icons` - `use_file_extension` callback
- `completion` - `process_items` function, `completefunc_lsp` autocmd
- `ai` - `custom_textobjects` references `MiniExtra` and `ai.gen_spec.treesitter()`
- `clue` - `clues` table with `gen_clues.*` calls, `triggers` table
- `hipatterns` - `highlighters` references `MiniExtra` and `hipatterns` methods
- `map` - `symbols` and `integrations` reference `map.gen_*` functions
- `snippets` - `snippets` table with `gen_loader.*` calls
- `keymap` - post-setup `map_multistep` calls

**Post-setup hooks** (via `extraConfigLua` in relevant files):
- `MiniIcons.mock_nvim_web_devicons()` and `MiniIcons.tweak_lsp_kind()`
- `MiniMisc.setup_auto_root()`, `setup_restore_cursor()`, `setup_termbg_sync()`
- `MiniKeymap.map_multistep(...)` (4 calls)
- `MiniFiles.set_bookmark(...)` via autocmd
- `MiniMap` navigation key remaps
- `MiniOperators` swap-argument keymaps

### External Plugins

**Tree-sitter**: `plugins.treesitter.enable = true` with `ensure_installed` list.
Parsers are pre-compiled by nixpkgs (no runtime C compiler needed).
`plugins.treesitter-textobjects.enable = true` for textobjects.

**LSP**: `plugins.lsp.enable = true` with `servers` attrset.
Servers are Nix packages (no mason needed).

**Conform**: `plugins.conform-nvim.enable = true` with `formatters_by_ft`.

**Snippets**: `plugins.friendly-snippets.enable = true`.
Loader config in `mini/completion.nix` via `mini.snippets`.

### Additional Plugins

- **dropbar.nvim**: `plugins.dropbar.enable = true` (has nixvim module)
- **rustaceanvim**: `plugins.rustacean.enable = true` (has nixvim module)
- **clangd_extensions.nvim**: May need `extraPlugins` if no nixvim module
- **cscope_maps.nvim**: May need `extraPlugins` + `extraConfigLua`

### Runtime Dependencies

```nix
programs.nixvim.extraPackages = with pkgs; [
  ripgrep
  fd
  stylua
];
```

LSP servers and formatters are managed by their respective plugin configs.

### Eliminated MiniMax Components

These MiniMax pieces are unnecessary in Nix and are not translated:

- `init.lua` bootstrap (git clone of mini.nvim) - Nix provides the plugin
- `mini.deps` setup and `now()`/`later()`/`now_if_args` lazy loading - nixvim handles load order
- `_G.Config` table - only existed to coordinate mini.deps
- Tree-sitter `TSUpdate` hook and parser installation logic - nixpkgs pre-compiles parsers
- `setup.lua` generator script - not applicable

### Colorscheme

`miniwinter` ships with `mini.nvim`. Set via:
```nix
extraConfigLua = "vim.cmd('colorscheme miniwinter')";
```
Or via nixvim's colorscheme module if it supports mini.hues presets.

## File Summary

| File | Complexity | Notes |
|---|---|---|
| `nvim/default.nix` | Simple | Entry point, extraPackages |
| `nvim/options.nix` | Pure Nix | ~40 opts, diagnostics, 1 autocmd |
| `nvim/keymaps.nix` | Mostly pure | ~65 keymaps, 2-3 `__raw` callbacks |
| `nvim/mini/default.nix` | Simple | Imports only |
| `nvim/mini/ui.nix` | Mixed | 9 modules; icons, map, hipatterns need `__raw` |
| `nvim/mini/editing.nix` | Mostly pure | 8 modules; ai needs `__raw` for textobjects |
| `nvim/mini/navigation.nix` | Mostly pure | 6 modules; files bookmarks need `__raw` |
| `nvim/mini/git.nix` | Pure Nix | 2 modules |
| `nvim/mini/completion.nix` | Mixed | 3 modules; completion, snippets, keymap need `__raw` |
| `nvim/mini/misc.nix` | Mixed | 5 modules; clue triggers/clues need `__raw` |
| `nvim/plugins/default.nix` | Simple | Imports only |
| `nvim/plugins/treesitter.nix` | Pure Nix | treesitter + textobjects |
| `nvim/plugins/lsp.nix` | Pure Nix | lspconfig + servers |
| `nvim/plugins/conform.nix` | Pure Nix | formatter setup |
| `nvim/plugins/snippets.nix` | Pure Nix | friendly-snippets |
| `nvim/plugins/dropbar.nix` | Pure Nix | breadcrumb bar |
| `nvim/plugins/rustacean.nix` | Pure Nix | Rust tooling |
| `nvim/plugins/clangd.nix` | May need extraPlugins | clangd extensions |
| `nvim/plugins/cscope.nix` | May need extraPlugins | cscope keybindings |

18 files total. ~70% pure Nix, ~30% with small `__raw` blocks.
