-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use 'fxn/vim-monochrome'

  use 'mg979/vim-visual-multi'

  use 'lervag/vimtex'

  -- marks.nvim
  use {
	  "chentoast/marks.nvim",
	  opts = {},
	}

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
  -- or                            , branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" }
  }


  use { 'echasnovski/mini.files', version = '*' }
  use { 'echasnovski/mini.colors', version = '*' }
  use { 'echasnovski/mini.base16', version = '*' }
  use { 'echasnovski/mini.icons', version = false }

  use {
	  "jesseleite/nvim-noirbuddy",
	  requires = { "tjdevries/colorbuddy.nvim" }
	}

--[[
  use({
	  'rose-pine/neovim',
	  as = 'rose-pine',
	  config = function()
		  vim.cmd('colorscheme rose-pine')
	  end
  })
--]]
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,}

  use("theprimeagen/vim-be-good")

  use('mbbill/undotree')
  
  use('tpope/vim-fugitive')

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {                                      -- Optional
        'williamboman/mason.nvim',
        run = function()
          pcall(vim.cmd, 'MasonUpdate')
        end,
      },
      {'williamboman/mason-lspconfig.nvim'}, -- Optional
  
      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    };

    use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async'}
  }
end)
