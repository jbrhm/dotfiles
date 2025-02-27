return {
	"mfussenegger/nvim-dap",
	config = function()
		--[[local dap = require("dap")
		dap.configurations.cpp = {
		  {
			name = "Launch",
			type = "gdb",
			request = "launch",
			program = function()
			  return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'a.out')
			end,
			cwd = "${workspaceFolder}",
			stopAtBeginningOfMainSubprogram = false,
		  },
		}]]--
	end,
}
