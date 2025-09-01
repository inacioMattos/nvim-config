-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

	use { 'm4xshen/autoclose.nvim', commit = 'b2077aa' }

  use 'fxn/vim-monochrome'

  use 'mg979/vim-visual-multi'

  use 'lervag/vimtex'

  use { 'mfussenegger/nvim-jdtls', ft = { 'java' } }

  -- marks.nvim
  use {
	  "chentoast/marks.nvim",
	  opts = {},
	}

  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    commit = '2d9b061',
  -- or                            , branch = '0.1.x',
    requires = { {'nvim-lua/plenary.nvim'} }
  }

  use {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    commit = 'a84ab82',
    dependencies = { "nvim-lua/plenary.nvim" }
  }


  use { 'echasnovski/mini.files', commit = '6abe854', version = '*' }
  use { 'echasnovski/mini.colors', version = '*', commit = 'd64b1c0' }
  use { 'echasnovski/mini.base16', version = '*', commit = '97abc91' }
  use { 'echasnovski/mini.icons', version = false }

  use {
	  "jesseleite/nvim-noirbuddy",
    commit = '7fa6c89',
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
    commit = "92725df",
    run = function()
      local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
      ts_update()
    end,}

  use("theprimeagen/vim-be-good")

  use('mbbill/undotree')
  
  use('tpope/vim-fugitive')

  use {
    'VonHeikemen/lsp-zero.nvim',
    commit = '9a68651',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      {'neovim/nvim-lspconfig', commit = '4ae9796'},             -- Required
      {                                      -- Optional
        'williamboman/mason.nvim',
        commit = 'e2f7f90',
        run = function()
          pcall(vim.cmd, 'MasonUpdate')
        end,
      },
      {'williamboman/mason-lspconfig.nvim', commit = '43894ad'}, -- Optional
  
      -- Autocompletion
      {'hrsh7th/nvim-cmp', commit = 'ed31156'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    };

    use {'kevinhwang91/nvim-ufo', requires = 'kevinhwang91/promise-async', commit = '1ebb9ea'}
  }
end)
