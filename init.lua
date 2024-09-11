require("inacio.remap")
require("inacio.set")
require('inacio.packer')

-- Vimtex configuration
vim.g.vimtex_view_method = 'zathura'  -- Or your preferred PDF viewer
vim.g.vimtex_compiler_method = 'latexmk'

-- Set up tex concealment
vim.g.tex_conceal = 'abdmg'
vim.g.vimtex_quickfix_open_on_warning = 0
