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
now(function()
	add({ source = 'catppuccin/nvim', name = 'catppuccin' })
	require('catppuccin').setup({
		custom_highlights = function(colors)
			return {
				LineNr = {
					-- Default text color is a bit hard to read
					fg = colors.overlay2,
				},
			}
		end,
	})
end)

now(function()
	add({ source = 'williamboman/mason.nvim' })
	add({ source = 'williamboman/mason-lspconfig.nvim' })
	add({ source = 'neovim/nvim-lspconfig' })

	require('mason').setup()
	require('mason-lspconfig').setup()
	require('mason-lspconfig').setup_handlers({
		function(server_name)
			require('lspconfig')[server_name].setup({})
		end,
	})
end)

-- Execute sometime after initialization
later(function() require('mini.trailspace').setup() end)
later(function() require('mini.jump2d').setup() end)
later(function() require('mini.move').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.indentscope').setup() end)

later(function()
	add({
		source = 'nvim-treesitter/nvim-treesitter',
		hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
	})

	require('nvim-treesitter.configs').setup({
		highlight = { enable = true },
		indent = { enable = true },
		ensure_installed = {
			'lua',
			'bash',
			'c',
			'cpp',
			'rust',
			'python',
		},
	})
end)

-- Load vimrc configuration
local vimrc = vim.fn.stdpath('config') .. '/vimrc.vim'
vim.cmd.source(vimrc)
