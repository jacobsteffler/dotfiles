-- Clone 'mini.nvim' manually in a way that it gets managed by 'mini.deps'
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = { 'git', 'clone', '--filter=blob:none', 'https://github.com/echasnovski/mini.nvim', mini_path }
	vim.fn.system(clone_cmd)
	vim.cmd('packadd mini.nvim | helptags ALL')
	vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

-- Set up 'mini.deps'
require('mini.deps').setup({ path = { package = path_package } })

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- Execute immediately, before initial render
now(function() require('mini.starter').setup() end)
now(function() require('mini.icons').setup() end)
now(function() require('mini.statusline').setup() end)
now(function() add({ source = 'catppuccin/nvim', name = 'catppuccin' }) end)

-- Execute sometime after initialization
later(function() require('mini.trailspace').setup() end)
later(function() require('mini.jump2d').setup() end)
later(function() require('mini.move').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.indentscope').setup() end)

later(function()
	add({ source = 'NeogitOrg/neogit', depends = {
		{ source = 'nvim-lua/plenary.nvim' },
		{ source = 'sindrets/diffview.nvim' },
		{ source = 'nvim-telescope/telescope.nvim' },
	} })

	require('neogit').setup()
end)

-- Load vimrc configuration
local vimrc = vim.fn.stdpath('config') .. '/vimrc.vim'
vim.cmd.source(vimrc)
