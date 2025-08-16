require("john.core")
require("john.lazy")

vim.cmd [[
  highlight Normal guibg=NONE
]]

vim.cmd [[
	if has('python')
	  map <C-K> :pyf /home/john/.config/NVIM-Config/clang-format.py<cr>
	  imap <C-K> <c-o>:pyf /home/john/.config/NVIM-Config/clang-format.py<cr>
	elseif has('python3')
	  map <C-K> :py3f /home/john/.config/NVIM-Config/clang-format.py<cr>
	  imap <C-K> <c-o>:py3f /home/john/.config/NVIM-Config/clang-format.py<cr>
	endif
]]

vim.cmd [[
    nnoremap <Leader>c :let @+=expand('%:p')<CR>
]]

vim.cmd [[
    source ~/.config/nvim/version482.vim
]]

-- disable supression of floating virtual text
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  float = {
    border = "rounded",
    source = "always",
  },
})
