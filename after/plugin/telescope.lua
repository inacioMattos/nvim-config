local builtin = require('telescope.builtin')
local mini_files = require('mini.files')

vim.keymap.set('n', '<leader>pf', function()
    MiniFiles.close()
    local function is_git_repo()
        vim.fn.system("git rev-parse --is-inside-work-tree")
        return vim.v.shell_error == 0
    end

    local opts = {
        file_ignore_patterns = { "node_modules" }
    }

    if is_git_repo() then
        builtin.git_files(opts)
    else
        builtin.find_files(opts)
    end
end, {})

vim.keymap.set('n', '<C-p>', function()
    MiniFiles.close()
    builtin.find_files({ file_ignore_patterns = { "node_modules" } })
end, {})

vim.keymap.set('n', '<leader>ps', function()
    MiniFiles.close()
    builtin.grep_string({ 
        search = vim.fn.input("Grep > "),
        file_ignore_patterns = { "node_modules" }
    })
end)

vim.keymap.set('n', '<leader>pa', function()
    MiniFiles.close()
    builtin.live_grep({ file_ignore_patterns = { "node_modules" } })
end, {})
