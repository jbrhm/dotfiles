return 	{
		"nvim-tree/nvim-tree.lua",
		config = function()
		require("nvim-tree").setup({
			filters = {
				dotfiles = false,
			},
		})
        local keymap = vim.keymap
		keymap.set("n", "<C-N>", "<cmd>NvimTreeToggle<CR>", {desc = "Toggles the Tree"})
		end,
	}
