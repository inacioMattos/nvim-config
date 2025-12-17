-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.relativenumber = true

vim.g.loaded_netwr = 1
vim.g.loaded_netwrPlugin = 1

local function set_scrolloff()
  vim.opt.scrolloff = math.floor(vim.o.lines * 0.24)
end

set_scrolloff()

vim.api.nvim_create_autocmd("VimResized", {
  callback = set_scrolloff,
})
