return {
  {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  build = ":TSUpdate",
  ensure_installed = {
    'bash',
    'lua',
    'nix',
    'nu',
    'markdown',
    'markdown-inline',
    }
  }
}
