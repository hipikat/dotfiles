-- Plugins
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    -- add your plugins here
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

--------
-- Set default options
vim.opt.autoindent = true -- Auto-indenting
vim.opt.hlsearch = false  -- No highlighting search matches
vim.opt.number = true     -- Enable line numbers
vim.opt.ic = true         -- Ignore case in search patterns
vim.opt.incsearch = true  -- Incremental search
vim.opt.wrap = false      -- No wrapping of lines
vim.o.mouse = ''          -- Disable mouse supportp
vim.wo.scrolloff = 3      -- Display context around the cursor line

vim.opt.expandtab = true  -- Convert tabs to spaces
vim.opt.shiftwidth = 4    -- Number of spaces to use for each step of (auto)indent
vim.opt.softtabstop = 0   -- Number of spaces that a <Tab> counts for while editing
vim.opt.tabstop = 4       -- Number of spaces that a <Tab> in the file counts for
vim.opt.smarttab = false  -- Disable smarttab to prevent smart behavior

vim.cmd([[
  autocmd FileType yaml setlocal shiftwidth=2 softtabstop=2 tabstop=2
]])

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
--vim.api.nvim_set_keymap('n', '<leader>v', ':set paste!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>w', ':set nolist!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>s', ':set spell!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', ':set wrap!<CR>:set linebreak!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>,', ':set hlsearch!<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>l', ':set syntax=', {noremap = true, silent = false})

-- Function to toggle paste mode and restore tab settings
function TogglePasteMode()
    vim.g.original_expandtab = vim.o.expandtab
    vim.g.original_tabstop = vim.o.tabstop
    vim.g.original_shiftwidth = vim.o.shiftwidth
    vim.g.original_softtabstop = vim.o.softtabstop

    vim.cmd('set paste!')

    vim.opt.expandtab = vim.g.original_expandtab
    vim.opt.tabstop = vim.g.original_tabstop
    vim.opt.shiftwidth = vim.g.original_shiftwidth
    vim.opt.softtabstop = vim.g.original_softtabstop
    vim.opt.smarttab = false -- Disable smarttab to prevent smart behavior

    if vim.g.paste_mode_enabled then
        print("Paste-mode enabled")
    else
        print("Paste-mode disabled")
    end
end

-- Initialize paste mode status
vim.g.paste_mode_enabled = false

-- Set keymap to toggle paste mode and restore tab settings
vim.api.nvim_set_keymap('n', '<leader>v', ':lua TogglePasteMode()<CR>', { noremap = true, silent = true })

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

