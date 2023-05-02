-- change the leader to ,
vim.g.mapleader = ','
vim.g.maplocalleader = ','

-- enable mouse
vim.o.mouse = 'a'

-- yank to clipboard
vim.o.clipboard = 'unnamedplus'

-- expand tabs to 2 spaces
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true

-- highlight the current line
vim.o.cursorline = true

-- disable the mode line
vim.o.showmode = false

-- disable bells
vim.o.visualbell = false

-- persistent undo
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath('data')..'/undo'
vim.o.undolevels = 1000
vim.o.undoreload = 10000

-- case insensitive search unless capital used
vim.o.ignorecase = true
vim.o.smartcase = true

-- neovide settings
if vim.g.neovide then
  vim.o.guifont = 'Hack Nerd Font Mono:h14'
  vim.g.neovide_scroll_animation_length = 0.0
  vim.g.neovide_cursor_animation_length = 0.0
end

-- install and load lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', '--branch=stable', lazypath })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup('plugins', {
  defaults = {
    lazy = true,
  },
  ui = {
    border = 'rounded',
  },
})
