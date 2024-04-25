-- Set default options
vim.opt.ic = true         -- Ignore case in search patterns
vim.opt.autoindent = true -- Auto-indenting
vim.opt.incsearch = true  -- Incremental search
vim.opt.hlsearch = false  -- No highlighting search matches
vim.opt.wrap = false      -- No wrapping of lines
vim.o.mouse = ''          -- Disable mouse supportp
vim.wo.scrolloff = 3      -- Display context around the cursor line

-- Clipboard options

-- Use the unnamed register for all yank, delete, change and put operations which would normally go to the clipboard.
-- vim.opt.clipboard = "unnamed"

-- Use the + and * registers for all yank, delete, change and put operations which would normally go to the clipboard.
-- vim.opt.clipboard = "unnamedplus"

-- Use both the unnamed and the + and * registers for all yank, delete, change and put operations which would normally go to the clipboard.
-- vim.opt.clipboard = "unnamed,unnamedplus"

-- GUI font settings
vim.opt.guifont = 'Fira Code:h13, Menlo:h13, Monospace:h13'

-- Visual bell instead of an auditory bell
vim.opt.visualbell = true

-- Load the colorscheme
vim.cmd('colorscheme torte')  -- Set preferred color scheme

-- Enable syntax highlighting
vim.cmd('syntax enable')

-- Set leader key to comma
vim.g.mapleader = ","

-- Always set cursor to a thin line in insert mode
vim.g.vscode = {}
vim.g.vscode.cursorStylePerMode = 1

-- Toggle commands
vim.api.nvim_set_keymap('n', '<leader>#', ':set number!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>v', ':set paste!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':set nolist!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', ':set spell!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':set wrap!<CR>:set linebreak!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>,', ':set hlsearch!<CR>', { noremap = true, silent = true })

-- Map key to open syntax setting prompt
vim.api.nvim_set_keymap('n', '<leader>sy', ':set syntax=', {noremap = true, silent = false})

-- Map F-keys to tabs for normal and insert modes
local function set_tab_keymap(key, tab_number)
    local command = '<Esc>' .. tab_number .. 'gt'
    vim.api.nvim_set_keymap('n', key, tab_number .. 'gt', {noremap = true, silent = true})
    vim.api.nvim_set_keymap('i', key, command, {noremap = true, silent = true})
end

for i = 1, 10 do
    set_tab_keymap('<F'..i..'>', tostring(i))
end

-- Restructured Text Headline Mappings
for i, char in ipairs({'#', '*', '=', '-', '^'}) do
    vim.api.nvim_set_keymap('n', '<leader>'..i, 'yyPVr'..char..'yyjp', { noremap = true, silent = true })
end

-- Packer and plugin setup
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end

local status_ok, packer = pcall(require, 'packer')
if not status_ok then
  return
end

packer.init({
    display = {
        open_fn = function()
            return require('packer.util').float({ border = 'single' })
        end
    },
})

packer.startup(function(use)
    use 'wbthomason/packer.nvim'
    use 'tpope/vim-surround'
    use {
        'nvim-lualine/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons', opt = true}
    }
end)

-- Setup lualine with adjusted colors for better visibility
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto', -- You may want to start with an existing theme and modify it
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = {
      {'mode', color = {fg = '#ffffff', bg = '#2e3440'}},  -- fg: white, bg: dark grey
    },
    lualine_b = {'branch', 'diff', {'diagnostics', sources={'nvim_diagnostic'}}},
    lualine_c = {'filename', {'filetype', icon_only = true}, 'encoding', 'fileformat'},
    lualine_x = {'%h%m%r', '%y', 'progress'},
    lualine_y = {'location'},
    lualine_z = {
      {'location', color = {fg = '#ffffff', bg = '#2e3440'}},  -- fg: white, bg: dark grey
    }
  },
  inactive_sections = {
    -- Define here if different from active
  },
  tabline = {},
  extensions = {}
}
