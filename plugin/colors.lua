function ColorMyPencil(color)
  color = color or "rose-pine"
  vim.cmd.colorscheme(color)
  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

function LightMode()
	require('noirbuddy').setup {
	  preset = 'miami-nights',

	  colors = {
	    background = '#fafafa',
	    noir_9 = '#C2C2C2', -- `noir_0` is light for dark themes, and dark for light themes
	    noir_8 = '#ADADAD',
	    noir_7 = '#999999',
	    noir_6 = '#858585',
	    noir_5 = '#707070',
	    noir_4 = '#5C5C5C',
	    noir_3 = '#474747',
	    noir_2 = '#333333',
	    noir_1 = '#1F1F1F',
	    noir_0 = '#0A0A0A', -- `noir_9` is dark for dark themes, and light for light themes
	  },

	  styles = {
	    italic = true,
	  },
	}

  local groups = {
    "Normal", "NormalFloat", "LineNr", "SignColumn", "Gutter",
    "FoldColumn", "ColorColumn", "VertSplit", "EndOfBuffer"
  }

  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = "none" })
  end

end

-- ColorMyPencil()
