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
vim.keymap.set('v', 'q', 'b', { noremap = true })

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
vim.keymap.set('n', 'cf', 'zC')

-- set '-' to go to end of line
vim.keymap.set('n', '-', '$', {noremap = true})

-- add pipe
vim.keymap.set('i', '<M-e>', '|', {noremap = true})

-- select all (cmd + a)
vim.keymap.set('n', '<leader>a', 'ggVG', {noremap = true})

-- save while in insert mode
vim.keymap.set('n', '<M-w>', ':w<CR>', { noremap = true })
vim.keymap.set('i', '<M-w>', '<esc>:w<CR>', { noremap = true })
