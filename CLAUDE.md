# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A pure nixvim translation of the [MiniMax](https://github.com/echasnovski/nvim) Neovim configuration. This repo contains **only NixOS module files** — no `flake.nix`. It is imported into a parent home-manager flake via `nvim/default.nix`.

The original MiniMax Lua source (reference for translations) is at `~/proj/MiniMax/configs/nvim-0.11/`.
Design decisions and translation rules are documented in `docs/plans/2026-02-05-nixvim-minimax-design.md`.

## Architecture

Every `.nix` file is a NixOS module that sets attributes under `programs.nixvim`. The NixOS module system **merges** all definitions, so multiple files can contribute to `plugins.mini.modules`, `extraConfigLua`, `keymaps`, etc.

```
nvim/default.nix           → Entry point: enable nixvim, colorscheme, extraPackages
├── options.nix            → Neovim opts, diagnostics, autocommands
├── keymaps.nix            → ~65 leader keymaps (two-key semantic groups: b=Buffer, f=Find, g=Git, l=LSP, etc.)
├── mini/default.nix       → Imports 6 mini module files
│   ├── ui.nix             → statusline, tabline, starter, notify, icons, map, indentscope, hipatterns, trailspace
│   ├── editing.nix        → ai, align, comment, move, operators, pairs, splitjoin, surround
│   ├── navigation.nix     → files, pick, jump, jump2d, bracketed, visits
│   ├── git.nix            → git, diff
│   ├── completion.nix     → completion, snippets, keymap + extraFiles for snippet JSON
│   └── misc.nix           → basics, bufremove, clue, cmdline, extra, misc, sessions
└── plugins/default.nix    → Imports 9 plugin files
    ├── treesitter.nix     → treesitter + textobjects
    ├── lsp.nix            → lspconfig + server configs (lua_ls)
    ├── conform.nix        → formatter (lsp_format fallback)
    ├── snippets.nix       → friendly-snippets
    ├── dropbar.nix        → breadcrumb bar
    ├── rustacean.nix      → Rust tooling
    ├── rustowl.nix        → Rust ownership visualization (requires rustowl-flake overlay)
    ├── clangd.nix         → clangd extensions
    └── cscope.nix         → cscope keybindings (extraPlugins + extraConfigLua)
```

## Key Patterns

### `__raw` Escape Hatch
When a Nix value needs to be a Lua expression (callbacks, function calls, table constructors referencing runtime APIs), wrap it in `__raw`:
```nix
process_items = {
  __raw = ''
    function(items, base)
      return MiniCompletion.default_process_items(items, base, { ... })
    end
  '';
};
```
~70% of the config is pure Nix; ~30% uses `__raw` blocks.

### Plugin Config Approaches
- **nixvim module exists** → `plugins.<name>.enable = true` with `settings` (treesitter, lsp, conform, dropbar, rustaceanvim, clangd-extensions, friendly-snippets)
- **No nixvim module** → `extraPlugins` + `extraConfigLua` (cscope_maps, rustowl)
- **mini.nvim modules** → `plugins.mini.modules.<module> = { ... }` (all 30+ mini modules)

### Post-Setup Hooks
Many mini modules need Lua code that runs **after** `setup()`. These go in `extraConfigLua` within each file. Examples: `MiniIcons.mock_nvim_web_devicons()`, `MiniMisc.setup_auto_root()`, `MiniKeymap.map_multistep()`.

### extraConfigLua Merging
Multiple files set `programs.nixvim.extraConfigLua`. The NixOS module system concatenates all string values. Order is **not guaranteed** across files — keep each file's `extraConfigLua` self-contained.

## Validation

There is no `flake.nix` in this repo to build against. To validate:
```bash
# Syntax-check all Nix files
for f in $(find nvim -name '*.nix'); do
  nix-instantiate --parse "$f" > /dev/null && echo "OK: $f" || echo "FAIL: $f"
done
```

Full integration testing requires importing `nvim/default.nix` into a home-manager flake with the nixvim home-manager module enabled.

## Changing the Colorscheme

The colorscheme is set in `nvim/default.nix` via `extraConfigLua`. Current: `miniwinter` (ships with mini.nvim, no extra plugin needed).

- **mini.hues presets** (miniwinter, minicyan, etc.) → just change the `vim.cmd('colorscheme ...')` string
- **nixvim has a module** (e.g. tokyonight, catppuccin) → use `colorschemes.<name>.enable = true` in `nvim/default.nix` and remove the `extraConfigLua` colorscheme line
- **External with no nixvim module** → add to `extraPlugins` in `nvim/default.nix` and set via `extraConfigLua`

## Adding a New Plugin

1. Create `nvim/plugins/<name>.nix` using the appropriate config approach (see Key Patterns above)
2. Add `./<name>.nix` to the `imports` list in `nvim/plugins/default.nix`
3. If the plugin needs a nixpkgs overlay or flake input, document it in the file header (see `rustowl.nix` for an example)

## Commits

- Conventional commit prefixes: `feat:`, `fix:`, `chore:`, `docs:`
- Keep subjects concise and lowercase after the prefix

## Nix Style

- 2-space indentation
- Module signature: `{ pkgs, ... }:` (only include `pkgs` when used, otherwise `{ ... }:`)
- Attribute paths for deeply nested values: `programs.nixvim.plugins.mini.modules`
- String quoting: double quotes for Nix strings, `''` for multi-line strings (especially Lua blocks)
