-- Basic settings
vim.g.mapleader = " "  -- Set leader key to space
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Detect OS
local os_name = vim.loop.os_uname().sysname

-- Bootstrap packer
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

-- Only configure plugins here
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'folke/tokyonight.nvim'           -- Theme
  use 'nvim-tree/nvim-tree.lua'         -- File explorer
  use 'nvim-tree/nvim-web-devicons'     -- Icons
  use 'numToStr/Comment.nvim'           -- Easy commenting
  use 'lukas-reineke/indent-blankline.nvim'  -- Indent guides

  -- Conditionally load Treesitter only on non-Windows systems
  if os_name ~= "Windows_NT" then
    use {
      'nvim-treesitter/nvim-treesitter',  -- Better syntax highlighting
      run = function() require('nvim-treesitter.install').update({ with_sync = true }) end
    }
  end
  
  if packer_bootstrap then
    require('packer').sync()
  end
end)

-- If we've just bootstrapped packer, stop here
if packer_bootstrap then
  print('Installing plugins... Restart Neovim when complete!')
  return
end

-- Configure file explorer
require('nvim-tree').setup({
  sort_by = "case_sensitive",
  view = { width = 30 },
  renderer = { group_empty = true },
  filters = { dotfiles = true },
})

-- Configure indent guides
require('ibl').setup()

-- Configure comment plugin
require('Comment').setup()

-- Set up Treesitter only if not on Windows
if os_name ~= "Windows_NT" then
  require('nvim-treesitter.configs').setup {
    ensure_installed = { "c" },
    highlight = { enable = true },
  }
end

-- Key mappings
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- File explorer
keymap('n', '<C-n>', ':NvimTreeToggle<CR>', opts)

-- Easier split navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Some nice C-specific settings
vim.cmd [[
  autocmd FileType c setlocal cindent
  autocmd FileType c setlocal complete-=i
]]

-- OS-specific include path for C files
if os_name ~= "Windows_NT" then
  vim.cmd [[ autocmd FileType c setlocal path+=/usr/include ]]
else
  vim.cmd [[ autocmd FileType c setlocal path+=C:/Path/To/Windows/Include ]]
end

-- Theme
vim.cmd [[colorscheme tokyonight]]
