return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  config = function()
    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    local keymap = vim.keymap -- for conciseness

    local opts = { noremap = true, silent = true }

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end
	
	-- This is where the flags are passed to clangd --header-insertion=never disables auto import :)))
	lspconfig["clangd"].setup({cmd = { "clangd", "--completion-style=detailed", "--header-insertion=never"}})

	-- Python language server
	lspconfig["pyright"].setup({})

    -- CMake Language Server
    -- https://github.com/regen100/cmake-language-server
    lspconfig["cmake"].setup({})

	-- Rust Language Server
    lspconfig["rust_analyzer"].setup({})
  end,
}
