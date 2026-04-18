-- ~/.config/nvim/lua/plugins/cuda-dual-lsp.lua
-- LazyVim plugin spec for dual CUDA LSP (host + device)

return {
  -- Disable the default clangd for CUDA files (we'll use our own)
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Make sure clangd doesn't auto-attach to cuda files
      -- We handle cuda files with our dual-client approach
      opts.servers = opts.servers or {}
      opts.servers.clangd = opts.servers.clangd or {}
      opts.servers.clangd.filetypes = { "c", "cpp", "objc", "objcpp" } -- Remove "cuda"
    end,
  },

  -- Our custom CUDA dual LSP plugin
  {
    dir = "~/.config/nvim/lua/cuda-lsp", -- or wherever you put it
    name = "cuda-lsp",
    ft = { "cuda" },
    config = function()
      require("cuda-lsp").setup({
        clangd_path = "clangd",
        cuda_path = "/opt/cuda",
        gpu_arch = "sm_120", -- Change this to match your GPU!
        debug = false,       -- Set to true for debugging
      })

      -- Disable inlay hints for CUDA files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "cuda",
        callback = function(args)
          vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
        end,
        desc = "Disable inlay hints for CUDA",
      })
    end,
  },

  -- Treesitter with CUDA support (helps with range detection)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "cuda", "cpp", "c" },
    },
  },

  -- Optional: Better CUDA syntax highlighting
  {
    "bfrg/vim-cuda-syntax",
    ft = { "cuda" },
    init = function()
      vim.g.cuda_kernel_highlight = 1
      vim.g.cuda_runtime_api_highlight = 1
    end,
  },
}
