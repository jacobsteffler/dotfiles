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

    vim.cmd('colorscheme catppuccin')
end)

now(function()
    add({ source = 'williamboman/mason.nvim', name = 'mason' })
    add({ source = 'williamboman/mason-lspconfig.nvim', name = 'mason-lspconfig' })
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
later(function() require('mini.move').setup() end)
later(function() require('mini.pairs').setup() end)
later(function() require('mini.indentscope').setup() end)
later(function() require('mini.comment').setup() end)

later(function()
    add({
        source = 'nvim-treesitter/nvim-treesitter',
        hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
    })

    require('nvim-treesitter.configs').setup({
        highlight = { enable = true },
        indent = { enable = true },
        ensure_installed = {
            'bash',
            'c',
            'c_sharp',
            'cpp',
            'css',
            'csv',
            'git_config',
            'git_rebase',
            'gitattributes',
            'gitcommit',
            'gitignore',
            'html',
            'javascript',
            'json',
            'lua',
            'python',
            'rust',
            'scss',
            'ssh_config',
            'toml',
            'tsx',
            'typescript',
            'vim',
            'vimdoc',
        },
    })
end)

vim.o.title = true
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true

vim.o.linebreak = true
vim.o.showbreak = '+++ '

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.wildignorecase = true

vim.o.splitbelow = true
vim.o.splitright = true

vim.o.expandtab = true
vim.o.softtabstop = 4
vim.o.shiftwidth = 4

if vim.g.neovide then
    vim.g.neovide_scroll_animation_length = 0.2
    vim.g.neovide_cursor_animation_length = 0
end

vim.g.mapleader = ','
vim.keymap.set('n', '<Leader>w', '<Cmd>set wrap!<CR>')  -- To toggle word wrap
vim.keymap.set('i', ';;', '<Esc>')  -- To exit insert mode
vim.keymap.set('c', ';;', '<C-c>')  -- To exit command mode, uses C-c to avoid executing the command
vim.keymap.set({'o', 'v'}, ';', '<Esc>')    -- To exit operator or visual mode
vim.keymap.set('n', '<BS>', '<Cmd>nohlsearch<CR><BS>')  -- Clear search highlight, <Cmd> obviates the need for nore and silent

vim.api.nvim_create_autocmd(
    'FileType',
    {
        pattern = 'gitcommit',
        callback = function()
            vim.wo.spell = true
        end,
    }
)
