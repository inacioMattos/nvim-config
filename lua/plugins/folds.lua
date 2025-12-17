local function fold_except_current(level)
  local pos = vim.api.nvim_win_get_cursor(0)
  require("ufo").closeFoldsWith(level)
  vim.api.nvim_win_set_cursor(0, pos)
  vim.cmd("normal! zv") -- open just enough folds to reveal cursor line
end

return {
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      provider_selector = function()
        return { "lsp", "indent" }
      end,
    },
    keys = {
      -- Fold/unfold all
      { "<leader>cf", function() require("ufo").closeAllFolds() end, desc = "Fold all" },
      { "<leader>co", function() require("ufo").openAllFolds() end,  desc = "Unfold all" },

      -- Fold/unfold current
      { "cf",         "zc",                                          desc = "Fold current" },
      { "co",         "zo",                                          desc = "Unfold current" },

      -- Fold to level N, keeping current context open
      { "cl1",        function() fold_except_current(0) end,         desc = "Fold level 1" },
      { "cl2",        function() fold_except_current(1) end,         desc = "Fold level 2" },
      { "cl3",        function() fold_except_current(2) end,         desc = "Fold level 3" },
      { "cl4",        function() fold_except_current(3) end,         desc = "Fold level 4" },
      { "cl5",        function() fold_except_current(4) end,         desc = "Fold level 5" },
      { "cl6",        function() fold_except_current(5) end,         desc = "Fold level 6" },
      { "cl7",        function() fold_except_current(6) end,         desc = "Fold level 7" },
      { "cl8",        function() fold_except_current(7) end,         desc = "Fold level 8" },
      { "cl9",        function() fold_except_current(8) end,         desc = "Fold level 9" },
    },
  },
}
