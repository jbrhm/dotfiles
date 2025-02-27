return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
  config = function()
	--Load the colorscheme
    vim.cmd([[colorscheme tokyonight-night]])
  end,
}
