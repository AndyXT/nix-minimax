{ ... }:
{
  programs.nixvim.plugins.mini.modules = {
    files = {
      windows = { preview = true; };
    };
    pick = {};
    jump = {};
    jump2d = {};
    bracketed = {};
    visits = {};
  };

  programs.nixvim.extraConfigLua = ''
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
