return {
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "nvim-mini/mini.files",
    version = false,
    lazy = false,
    config = function()
      require("mini.files").setup({
        mappings = {
          close       = "`",
          go_in       = "+",
          go_in_plus  = ";",
          go_out      = "j",
          go_out_plus = "J",
          mark_goto   = "=",
          mark_set    = "m",
          reset       = "<BS>",
          reveal_cwd  = "@",
          show_help   = "g?",
          synchronize = "y",
          trim_left   = "<",
          trim_right  = ">",
        },
        windows = {
          max_number = math.huge,
          preview = true,
          width_focus = 50,
          width_nofocus = 15,
          width_preview = 50,
        },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          vim.keymap.set("n", "<Esc>", function()
            require("mini.files").close()
          end, { buffer = args.data.buf_id })
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesExplorerClose",
        callback = function() end, -- just to ensure the event exists
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "snacks_picker_input", "snacks_picker" },
        callback = function()
          require("mini.files").close()
        end,
      })
    end,
  },
}
