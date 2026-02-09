vim.lsp.completion.enable()
vim.lsp.config('lua_ls', {
    cmd = { "lua-language-server" },
    root_markers = { ".luarc.json", ".luarc.jsonc", ".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml", "selene.yml", ".git" },
    filetypes = { "lua" },
    -- avoid type def error in lua nvim config
    settings = {
      Lua = {
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        }
      }
    }
})
-- add more server configs here

vim.lsp.enable('lua_ls')
vim.lsp.enable('nushell')
-- enable other configured servers here
