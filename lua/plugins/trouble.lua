return {
  {
    "folke/trouble.nvim",
    opts = {
      keys = {
        [";"] = "jump",
        ["<cr>"] = "jump_close",
        ["j"] = "fold_close",
        ["cf"] = "fold_close",
        ["co"] = "fold_open",
        ["<leader>cf"] = "fold_close_all",
        ["<leader>co"] = "fold_open_all",
        ["s"] = false,
      },
    },
    keys = {
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=true<cr>", desc = "Symbols (Trouble)" },
    },
  },
}
