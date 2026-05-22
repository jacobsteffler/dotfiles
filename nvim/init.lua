vim.pack.add({
    'https://github.com/nvim-mini/mini.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-lua/plenary.nvim', -- Dep for telescope
    { src = 'https://github.com/dracula/vim', name = 'dracula' },
})

require('mini.icons').setup()
require('mini.statusline').setup()
require('mini.trailspace').setup()
require('mini.move').setup()
require('mini.pairs').setup()
require('mini.indentscope').setup()
require('mini.comment').setup()
require('mini.diff').setup()

local hipatterns = require('mini.hipatterns')
hipatterns.setup({
    highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
        hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
        todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
        note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})

require('telescope').setup({
    defaults = {
        file_sorter = require('mini.fuzzy').get_telescope_sorter,
        generic_sorter = require('mini.fuzzy').get_telescope_sorter,
    }
})

vim.cmd('colorscheme dracula')

vim.o.title = true
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true

vim.o.list = true
vim.o.fixeol = false
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

vim.g.mapleader = ','
vim.keymap.set('n', '<Leader>w', '<Cmd>set wrap!<CR>')  -- To toggle word wrap
vim.keymap.set({'i', 'o', 'v'}, ',,', '<Esc>')  -- To exit insert, operation, or visual mode
vim.keymap.set('c', ',,', '<C-c>')  -- To exit command mode, uses C-c to avoid executing the command
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
