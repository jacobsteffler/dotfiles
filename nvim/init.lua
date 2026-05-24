vim.pack.add({
    'https://github.com/nvim-mini/mini.nvim',
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
require('mini.splitjoin').setup()
require('mini.completion').setup()
require('mini.notify').setup()
require('mini.pick').setup({
    options = { use_cache = true }, -- Faster but more memory usage
})

local extra = require('mini.extra')
extra.setup()

local hi_words = extra.gen_highlighter.words
local hipatterns = require('mini.hipatterns')
hipatterns.setup({
    highlighters = {
        -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
        fixme = hi_words({ 'FIXME', 'FixMe', 'Fixme', 'fixme' }, 'MiniHipatternsFixme'),
        hack  = hi_words({ 'HACK', 'Hack', 'hack' }, 'MiniHipatternsHack'),
        todo  = hi_words({ 'TODO', 'Todo', 'todo' }, 'MiniHipatternsTodo'),
        note  = hi_words({ 'NOTE', 'Note', 'note' },  'MiniHipatternsNote'),

        -- Highlight hex color strings (`#rrggbb`) using that color
        hex_color = hipatterns.gen_highlighter.hex_color(),
    },
})

vim.cmd('colorscheme dracula')

vim.o.title = true
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true

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

vim.o.wrap = false
vim.o.list = true
vim.o.winborder = 'rounded'

vim.g.mapleader = ','
vim.keymap.set('n', '<Leader>w', '<Cmd>set wrap!<CR>')  -- To toggle word wrap
vim.keymap.set({'i', 'o', 'v'}, '<Leader><Leader>', '<Esc>')  -- To exit insert, operator, or visual mode
vim.keymap.set('c', '<Leader><Leader>', '<C-c>')  -- To exit command mode, uses C-c to avoid executing the command
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

-- LSP
vim.lsp.config['rust-analyzer'] = {
    cmd = { 'rust-analyzer' },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', '.git' },
}

vim.lsp.enable('rust-analyzer')
