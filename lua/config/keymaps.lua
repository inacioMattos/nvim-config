-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Movement remaps: j=left, k=up, l=down, ;=right
local modes = { "n", "v", "o" }

for _, mode in ipairs(modes) do
  vim.keymap.set(mode, "j", "h", { noremap = true })
  vim.keymap.set(mode, "k", "k", { noremap = true }) -- stays the same, but explicit
  vim.keymap.set(mode, "l", "j", { noremap = true })
  vim.keymap.set(mode, ";", "l", { noremap = true })
end

-- Word search mode
vim.keymap.set("n", "<Leader>f", ":/")
-- stop word search
vim.keymap.set('n', '<leader><S-f>', '<ESC>:nohlsearch<CR>', { noremap = true, silent = true })



-- Change word backward to be `q`
vim.keymap.set('n', 'q', 'b', { noremap = true })
vim.keymap.set('o', 'q', 'b', { noremap = true })
vim.keymap.set('n', 'q', 'b', { noremap = true })
vim.keymap.set("n", "b", "<Nop>", { noremap = true })

-- `-` to go to end of line
vim.keymap.set('n', '-', '$', { noremap = true, desc = 'Go to end of line' })
vim.keymap.set('o', '-', '$', { noremap = true, desc = 'Go to end of line' })
vim.keymap.set('v', '-', '$', { noremap = true, desc = 'Go to end of line' })

-- select all (cmd + a)
vim.keymap.set('n', '<leader>a', 'ggVG', { noremap = true, desc = 'Select all lines in buffer' })

-- change redo to be option+u
vim.keymap.set("n", "<M-u>", "<C-r>")
vim.keymap.set("v", "<M-u>", "<C-r>")

-- tabs when in visual line mode
local function add_tab()
  -- Get the current visual selection range
  local start_pos = vim.fn.getpos("v")[2]
  local end_pos = vim.fn.getcurpos()[2]

  -- Ensure start_pos is less than end_pos
  if start_pos > end_pos then
    start_pos, end_pos = end_pos, start_pos
  end

  -- Iterate over the lines and add a tab at the beginning
  for line = start_pos - 1, end_pos - 1 do
    vim.api.nvim_buf_set_text(0, line, 0, line, 0, { '\t' })
  end
end

-- Set the keymap for visual line mode
vim.keymap.set('x', '<Tab>', add_tab, { noremap = true, silent = true })

local function remove_tab()
  -- Get the current visual selection range
  local start_pos = vim.fn.getpos("v")[2]
  local end_pos = vim.fn.getcurpos()[2]

  -- Ensure start_pos is less than end_pos
  if start_pos > end_pos then
    start_pos, end_pos = end_pos, start_pos
  end

  -- Iterate over the lines and remove a tab at the beginning if it exists
  for line = start_pos - 1, end_pos - 1 do
    local current_line = vim.api.nvim_buf_get_lines(0, line, line + 1, false)[1]
    if current_line and vim.startswith(current_line, '\t') then
      vim.api.nvim_buf_set_text(0, line, 0, line, 1, { '' })
    elseif current_line and vim.startswith(current_line, '    ') then -- handle spaces as tabs if needed
      vim.api.nvim_buf_set_text(0, line, 0, line, 4, { '' })
    end
  end
end

-- Set the keymap for visual line mode to remove a tab
vim.keymap.set('x', '<S-Tab>', remove_tab, { noremap = true, silent = true })


-- Set the keymap for visual line mode to remove a tab
vim.keymap.set('i', '<S-Tab>', remove_tab, { noremap = true, silent = true })

-- ENTER to add new line
vim.keymap.set('n', '<Leader><CR>', function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, { "" })
  vim.api.nvim_win_set_cursor(0, { line, 0 })
end, { noremap = true, silent = true, desc = "Insert line above" })

vim.keymap.set('n', '<CR>', function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1]
  vim.api.nvim_buf_set_lines(0, line, line, false, { "" })
  vim.api.nvim_win_set_cursor(0, { line + 1, 0 })
end, { noremap = true, silent = true, desc = "Insert line below" })

vim.keymap.set('n', '`', function()
  local mf = require('mini.files')
  if not mf.close() then
    mf.open(vim.api.nvim_buf_get_name(0))
  end
end, { noremap = true, desc = "Toggle mini.files" })

vim.keymap.set('n', '<Tab>', '<cmd>b#<cr>', { noremap = true, desc = 'Switch to previous buffer' })

-- Window navigation
vim.keymap.set('n', '<C-j>', '<C-w>h', { noremap = true, desc = 'Window left' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true, desc = 'Window up' })
vim.keymap.set('n', '<C-l>', '<C-w>j', { noremap = true, desc = 'Window down' })
vim.keymap.set('n', '<C-;>', '<C-w>l', { noremap = true, desc = 'Window right' })

-- Run cpp file
vim.keymap.set("n", "<F5>", function()
  vim.cmd("w")
  vim.cmd("split | terminal clang++ % -o %<:p && ./%")
end, { desc = "Compile and run C++ in terminal split" })
