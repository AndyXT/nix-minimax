# nix-minimax

A pure [nixvim](https://github.com/nix-community/nixvim) translation of the [MiniMax](https://github.com/echasnovski/nvim) Neovim configuration. This repository contains **only NixOS module files** -- no `flake.nix`. It is designed to be imported into a parent home-manager flake.

## Features

- **30+ [mini.nvim](https://github.com/echasnovski/mini.nvim) modules** configured across UI, editing, navigation, git, completion, and utilities
- **65+ keymaps** organized in semantic two-key groups (`<leader>b` = Buffer, `<leader>f` = Find, `<leader>g` = Git, `<leader>l` = LSP, etc.)
- **9 external plugins** including treesitter, LSP, conform, dropbar, rustaceanvim, and more
- **~70% pure Nix / ~30% `__raw` Lua** -- declarative where possible, with escape hatches for runtime callbacks

## Architecture

Every `.nix` file is a NixOS module that sets attributes under `programs.nixvim`. The NixOS module system merges all definitions, so multiple files can contribute to `plugins.mini.modules`, `extraConfigLua`, `keymaps`, etc.

```
nvim/
├── default.nix             Entry point: enable nixvim, colorscheme, extraPackages
├── options.nix             Neovim opts, diagnostics, autocommands
├── keymaps.nix             ~65 leader keymaps (semantic two-key groups)
├── mini/
│   ├── default.nix         Imports all mini module files
│   ├── ui.nix              statusline, tabline, starter, notify, icons, map,
│   │                       indentscope, hipatterns, trailspace
│   ├── editing.nix         ai, align, comment, move, operators, pairs,
│   │                       splitjoin, surround
│   ├── navigation.nix      files, pick, jump, jump2d, bracketed, visits
│   ├── git.nix             git, diff
│   ├── completion.nix      completion, snippets, keymap + extraFiles for snippet JSON
│   └── misc.nix            basics, bufremove, clue, cmdline, extra, misc, sessions
└── plugins/
    ├── default.nix         Imports all plugin files
    ├── treesitter.nix      treesitter + textobjects
    ├── lsp.nix             lspconfig (lua_ls)
    ├── conform.nix         formatter (LSP format fallback)
    ├── snippets.nix        friendly-snippets
    ├── dropbar.nix         breadcrumb bar
    ├── rustacean.nix       Rust tooling
    ├── rustowl.nix         Rust ownership visualization (requires rustowl-flake overlay)
    ├── clangd.nix          clangd extensions
    └── cscope.nix          cscope keybindings (extraPlugins + extraConfigLua)
```

## Usage

### Import into home-manager

This module requires the [nixvim home-manager module](https://github.com/nix-community/nixvim) to be available. Add it to your flake inputs and import `nvim/default.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nixvim.url = "github:nix-community/nixvim";
    # If using rustowl:
    # rustowl-flake.url = "github:nickel-lang/rustowl";
  };

  outputs = { nixpkgs, home-manager, nixvim, ... }: {
    homeConfigurations."user" = home-manager.lib.homeManagerConfiguration {
      # ...
      modules = [
        nixvim.homeManagerModules.nixvim
        ./path/to/nix-minimax/nvim
      ];
    };
  };
}
```

### Runtime dependencies

The following packages are added via `extraPackages` in `nvim/default.nix`:

- `ripgrep` -- used by mini.pick grep
- `fd` -- used by mini.pick file finding
- `stylua` -- Lua formatter

## Mini.nvim modules

| Category   | Modules                                                           |
|------------|-------------------------------------------------------------------|
| UI         | statusline, tabline, starter, notify, icons, map, indentscope, hipatterns, trailspace |
| Editing    | ai, align, comment, move, operators, pairs, splitjoin, surround  |
| Navigation | files, pick, jump, jump2d, bracketed, visits                     |
| Git        | git, diff                                                        |
| Completion | completion, snippets, keymap                                     |
| Misc       | basics, bufremove, clue, cmdline, extra, misc, sessions          |

## External plugins

| Plugin           | Config approach            | Notes                              |
|------------------|----------------------------|------------------------------------|
| treesitter       | `plugins.treesitter`       | With textobjects                   |
| lspconfig        | `plugins.lsp`              | lua_ls configured                  |
| conform          | `plugins.conform-nvim`     | LSP format with fallback           |
| friendly-snippets| `plugins.friendly-snippets`| Snippet library                    |
| dropbar          | `plugins.dropbar`          | Breadcrumb bar                     |
| rustaceanvim     | `plugins.rustaceanvim`     | Rust tooling                       |
| rustowl          | `extraPlugins`             | Requires rustowl-flake overlay     |
| clangd-extensions| `plugins.clangd-extensions`| C/C++ support                      |
| cscope_maps      | `extraPlugins`             | cscope keybindings via extraConfigLua |

## Keymap groups

All keymaps use `<Space>` as leader. The second key selects the group:

| Prefix        | Group    | Examples                                        |
|---------------|----------|-------------------------------------------------|
| `<leader>b`   | Buffer   | `bd` delete, `ba` alternate, `bs` scratch       |
| `<leader>e`   | Explore  | `ed` file explorer, `en` notifications          |
| `<leader>f`   | Find     | `ff` files, `fg` grep, `fb` buffers, `fh` help  |
| `<leader>g`   | Git      | `gs` show at cursor, `go` diff overlay, `gl` log|
| `<leader>l`   | LSP      | `la` code action, `lr` rename, `ld` diagnostics |
| `<leader>m`   | Map      | `mf` focus, `mc` close, `mr` refresh            |
| `<leader>o`   | Other    | `oz` zoom, `ot` trim trailspace                 |
| `<leader>s`   | Session  | `ss` select, `sw` write                         |
| `<leader>t`   | Terminal | `tt` terminal                                   |
| `<leader>v`   | Visits   | `vv` select, `va` add label                     |

## Key patterns

### `__raw` escape hatch

When a Nix value needs to be a Lua expression (callbacks, function calls, runtime API references), wrap it in `__raw`:

```nix
process_items = {
  __raw = ''
    function(items, base)
      return MiniCompletion.default_process_items(items, base, { ... })
    end
  '';
};
```

### Plugin config approaches

- **nixvim module exists** -- use `plugins.<name>.enable = true` with `settings`
- **No nixvim module** -- use `extraPlugins` + `extraConfigLua`
- **mini.nvim modules** -- use `plugins.mini.modules.<module> = { ... }`

### Post-setup hooks

Some mini modules need Lua code that runs after `setup()`. These go in `extraConfigLua` within each file:

```nix
programs.nixvim.extraConfigLua = ''
  MiniIcons.mock_nvim_web_devicons()
  MiniMisc.setup_auto_root()
  MiniMisc.setup_restore_cursor()
'';
```

Multiple files can set `extraConfigLua` -- the module system concatenates all string values. Keep each file's block self-contained since ordering is not guaranteed.

## Colorscheme

The default colorscheme is `miniwinter` (ships with mini.nvim). To change it:

- **Other mini.hues presets** (minicyan, etc.) -- edit the `vim.cmd('colorscheme ...')` string in `nvim/default.nix`
- **nixvim-supported scheme** (tokyonight, catppuccin, etc.) -- use `colorschemes.<name>.enable = true` and remove the `extraConfigLua` colorscheme line
- **External scheme without nixvim module** -- add to `extraPlugins` and set via `extraConfigLua`

## Validation

There is no `flake.nix` in this repo. To syntax-check all Nix files:

```bash
for f in $(find nvim -name '*.nix'); do
  nix-instantiate --parse "$f" > /dev/null && echo "OK: $f" || echo "FAIL: $f"
done
```

Full integration testing requires importing `nvim/default.nix` into a home-manager flake with the nixvim module enabled.

## Adding a new plugin

1. Create `nvim/plugins/<name>.nix` using the appropriate config approach
2. Add `./<name>.nix` to the `imports` list in `nvim/plugins/default.nix`
3. If the plugin needs a nixpkgs overlay or flake input, document it in the file header (see `rustowl.nix` for an example)

## Design documentation

Detailed design decisions and translation rules are in [`docs/plans/`](docs/plans/):

- [`2026-02-05-nixvim-minimax-design.md`](docs/plans/2026-02-05-nixvim-minimax-design.md) -- translation rules and architecture decisions
- [`2026-02-05-nixvim-implementation.md`](docs/plans/2026-02-05-nixvim-implementation.md) -- step-by-step implementation plan

## License

See the original [MiniMax](https://github.com/echasnovski/nvim) and [mini.nvim](https://github.com/echasnovski/mini.nvim) projects for licensing information.
