local recent_bufs = {}

return {
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      opts.options = opts.options or {}

      vim.api.nvim_create_autocmd("BufEnter", {
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          if vim.bo[bufnr].buflisted then
            for i, b in ipairs(recent_bufs) do
              if b == bufnr then
                table.remove(recent_bufs, i)
                break
              end
            end
            table.insert(recent_bufs, 1, bufnr)
          end
        end,
      })

      opts.options.custom_filter = function(bufnr)
        for i = 1, 6 do
          if recent_bufs[i] == bufnr then
            return true
          end
        end
        return false
      end

      opts.options.numbers = function(o)
        local ok, state = pcall(require, "bufferline.state")
        if not ok or not state.components then
          return o.ordinal
        end
        local position = 1
        for _, component in ipairs(state.components) do
          if component.id == o.id then
            return position
          end
          if component.id then
            position = position + 1
          end
        end
        return o.ordinal
      end

      opts.highlights = opts.highlights or {}
      opts.highlights.numbers = { link = "Comment" }
      opts.highlights.numbers_selected = { link = "Comment" }
      opts.highlights.numbers_visible = { link = "Comment" }
    end,
    keys = {
      { "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<C-Tab>",   "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<S-h>",     false },
      { "<S-l>",     false },
      {
        "ba",
        function()
          require("bufferline.groups").toggle_pin()
          vim.schedule(function()
            vim.cmd("redrawtabline")
          end)
        end,
        desc = "Toggle pin buffer",
      },
      { "bp",        false },
      { "<leader>w", "<cmd>bdelete<cr>",                                  desc = "Delete buffer" },
      -- { "<leader>D",        "<cmd>BufferLineGroupClose ungrouped<cr>",           desc = "Delete unpinned buffers" },
      { "<leader>D", "<cmd>bufdo bdelete<cr>",                            desc = "Delete all buffers" },
      { "<leader>1", function() require("bufferline").go_to(1, true) end, desc = "Go to buffer 1" },
      { "<leader>2", function() require("bufferline").go_to(2, true) end, desc = "Go to buffer 2" },
      { "<leader>3", function() require("bufferline").go_to(3, true) end, desc = "Go to buffer 3" },
      { "<leader>4", function() require("bufferline").go_to(4, true) end, desc = "Go to buffer 4" },
      { "<leader>5", function() require("bufferline").go_to(5, true) end, desc = "Go to buffer 5" },
      { "<leader>6", function() require("bufferline").go_to(6, true) end, desc = "Go to buffer 6" },
    },
  },
}
