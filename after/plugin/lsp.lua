require('mini.icons').setup({ 
  style = 'glyph',
})

require('noirbuddy').setup {
  preset = 'miami-nights',

  colors = {
    primary = '#5f8787',
  },
}

require('mini.files').setup({
  mappings = {
    close       = "'",
    go_in       = 'ç',  -- Changed to 'ç' to expand entry
    go_in_plus  = 'Ç',  -- Changed to 'Ç' for consistency
    go_out      = 'j',  -- Changed to 'j' to go to parent directory
    go_out_plus = 'J',  -- Changed to 'J' for consistency
    mark_goto   = "=",
    mark_set    = 'm',
    reset       = '<BS>',
    reveal_cwd  = '@',
    show_help   = 'g?',
    synchronize = 's',
    trim_left   = '<',
    trim_right  = '>',
  },

  -- Customization of explorer windows
  windows = {
    -- Maximum number of windows to show side by side
    max_number = math.huge,
    -- Whether to show preview of file/directory under cursor
    preview = true,
    -- Width of focused window
    width_focus = 50,
    -- Width of non-focused window
    width_nofocus = 15,
    -- Width of preview window
    width_preview = 50,
  },
})


--[[
require('mini.base16').setup({
  palette = {
        base00 = "#262626",
        base01 = "#303030",
        base02 = "#333333",
        base03 = "#6C6C6C",
        base04 = "#787878",
        base05 = "#BCBCBC",
        base06 = "#C9C9C9",
        base07 = "#FFFFFF",
        base08 = "#5F8787",
        base09 = "#FF8700",
        base0A = "#5F8787",
        base0B = "#87AF87",
        base0C = "#5F875F",
        base0D = "#FFFFAF",
        base0E = "#87AFD7",
        base0F = "#5F87AF",
      },
})
--]]

--- lsp
local lsp = require("lsp-zero")

local lspconfig = require('lspconfig')
lspconfig.zls.setup{}

lsp.preset("recommended")

lsp.ensure_installed({
  'clangd',
  -- 'gopls',
  'rust_analyzer',
})

-- Fix Undefined global 'vim'
lsp.nvim_workspace()


local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ['<CR>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})

lsp.set_preferences({
    suggest_lsp_servers = false,
    sign_icons = {
        error = 'E',
        warn = 'W',
        hint = 'H',
        info = 'I'
    }
})

lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})
