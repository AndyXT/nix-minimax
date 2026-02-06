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
          client.server_capabilities.completionProvider.triggerCharacters =
            { '.', ':', '#', '(' }
        '';
      };
    };
  };
}
