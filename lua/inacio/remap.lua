vim.g.mapleader =  " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- -- greatest remap ever
-- vim.keymap.set("x", "<leader>p", [["_dP]])

-- -- next greatest remap ever : asbjornHaland
-- vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
-- vim.keymap.set("n", "<leader>Y", [["+Y]])

-- vim.keymap.set({"n", "v"}, "<leader>d", [["_d]])

-- -- This is going to get me cancelled
-- vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
-- vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- vim.keymap.set("n", "<leader>vpp", "<cmd>e ~/.dotfiles/nvim/.config/nvim/lua/theprimeagen/packer.lua<CR>");
-- vim.keymap.set("n", "<leader>mr", "<cmd>CellularAutomaton make_it_rain<CR>");

-- vim.keymap.set("n", "<leader><leader>", function()
--     vim.cmd("so")
-- end)

-- harpoon!
local harpoon = require("harpoon")
vim.keymap.set("n", "<leader>ha", function() harpoon:list():add() end)
vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)
vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

-- inacio

-- change movement to jkl; AND order be left *up* down right
vim.keymap.set("n", "ç", "l", {noremap = true})
vim.keymap.set("v", "ç", "l", {noremap = true})
vim.keymap.set("n", "l", "j", {noremap = true})
vim.keymap.set("v", "l", "j", {noremap = true})
-- vim.keymap.set("n", "k", "j", {noremap = true})
vim.keymap.set("n", "j", "h", {noremap = true})
vim.keymap.set("v", "j", "h", {noremap = true})

-- Source the Vimscript file
vim.cmd('source ~/.config/nvim/autoload/op_remaps.vim')

-- Call the function
vim.cmd('call OpRemaps()')

-- change word backwards to be 'q' instead of 'b'
vim.keymap.set('n', 'q', 'b', { noremap = true })
vim.keymap.set('n', 'q', 'b', { noremap = true })

-- create option navigation when in insert mode
vim.keymap.set('i', '<M-Right>', '<Right><C-Right>', { noremap = true })
vim.keymap.set('i', '<M-Left>', '<Left><C-Left>', { noremap = true })
vim.keymap.set('i', '<M-BS>', '<C-w>', { noremap = true })

-- create toggle for option+i to switch between insert and normal mode
vim.keymap.set('i', '<M-i>', '<Esc>', { noremap = true })

-- change redo to be option+u
vim.keymap.set("n", "<M-u>", "<C-r>")
vim.keymap.set("v", "<M-u>", "<C-r>")

-- not working
vim.keymap.set("i", "·", "<C-\\><C-n>", { noremap = true })

-- option+backspace but in vim insert mode
vim.keymap.set('i', 'ckspace', '<C-w>')

vim.keymap.set('i', '<M-q>', '/')

-- code block folding
vim.keymap.set('n', 'co', 'zo')
vim.keymap.set('n', 'cf', 'zc')
vim.keymap.set('n', '<leader>cf', 'zC')

-- set '-' to go to end of line
vim.keymap.set('n', '-', '$', {noremap = true})

-- add pipe
vim.keymap.set('i', '<M-e>', '|', {noremap = true})

-- select all (cmd + a)
vim.keymap.set('n', '<leader>a', 'ggVG', {noremap = true})

-- save while in insert mode
vim.keymap.set('n', '<M-w>', ':w<CR>', { noremap = true })
vim.keymap.set('i', '<M-w>', '<esc>:w<CR>', { noremap = true })

-- go to previous buffer
-- Initialize the buffer history table
local buffer_history = {}

-- Function to update the buffer history
local function update_buffer_history()
  local current_buffer = vim.fn.bufnr('%')
  if #buffer_history == 0 or buffer_history[#buffer_history] ~= current_buffer then
    table.insert(buffer_history, current_buffer)
    if #buffer_history > 2 then
      table.remove(buffer_history, 1)
    end
  end
end

-- Set up an autocmd to update the buffer history on buffer enter
vim.api.nvim_create_autocmd("BufEnter", {
  callback = update_buffer_history
})

-- Function to switch to the last buffer
local function switch_to_last_buffer()
  if #buffer_history > 1 then
    local last_buffer = buffer_history[#buffer_history - 1]
    vim.cmd('buffer ' .. last_buffer)
  end
end

-- Set the keymap for <Tab> to switch to the last buffer
vim.keymap.set('n', '<Tab>', function()
  switch_to_last_buffer()
end, { noremap = true, silent = true })

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
    vim.api.nvim_buf_set_text(0, line, 0, line, 0, {'\t'})
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
      vim.api.nvim_buf_set_text(0, line, 0, line, 1, {''})
    elseif current_line and vim.startswith(current_line, '    ') then  -- handle spaces as tabs if needed
      vim.api.nvim_buf_set_text(0, line, 0, line, 4, {''})
    end
  end
end

-- Set the keymap for visual line mode to remove a tab
vim.keymap.set('x', '<S-Tab>', remove_tab, { noremap = true, silent = true })


-- Define a command to insert LaTeX snippet
vim.api.nvim_set_keymap('n', '<Leader>lt', '<ESC>:lua InsertLatexSnippet()<CR>', { noremap = true, silent = true })

function InsertLatexSnippet()
  vim.api.nvim_input('i\\textbf{\\textit{}}<ESC>3hi')
end

-- stop word search
vim.keymap.set('n', '<leader><S-f>', '<ESC>:nohlsearch<CR>', { noremap = true, silent = true })

-- new lines ENTER when in normal mode
vim.keymap.set('n', '<CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]
    vim.api.nvim_buf_set_lines(0, line - 1, line - 1, false, {""})
    vim.api.nvim_win_set_cursor(0, {line, 0})
end, { noremap = true, silent = true, desc = "Insert line above" })

vim.keymap.set('n', '<Leader><CR>', function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1]
    vim.api.nvim_buf_set_lines(0, line, line, false, {""})
    vim.api.nvim_win_set_cursor(0, {line + 1, 0})
end, { noremap = true, silent = true, desc = "Insert line below" })



vim.keymap.set('n', "'", function ()
  MiniFiles.open()
end, { noremap = true })
