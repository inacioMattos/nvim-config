local ok, jdtls = pcall(require, 'jdtls')
if not ok then return end

local mason = vim.fn.stdpath('data') .. '/mason'
local jdtls_bin = mason .. '/bin/jdtls'
if vim.fn.executable(jdtls_bin) == 0 then
  vim.notify('Install jdtls with :Mason', vim.log.levels.ERROR)
  return
end

-- workspace per project
local project = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
local workspace = vim.fn.stdpath('data') .. '/jdtls/' .. project

-- detect root (git/gradle/maven)
local util = require('lspconfig.util')
local root = util.root_pattern('gradlew', '.git', 'mvnw', 'pom.xml', 'build.gradle')(vim.fn.getcwd())
              or vim.loop.cwd()

local config = {
  cmd = { jdtls_bin, '-data', workspace },
  root_dir = root,
  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      configuration = { updateBuildConfiguration = 'interactive' },
      referencesCodeLens = { enabled = true },
      implementationsCodeLens = { enabled = true },
      format = { enabled = true },
    },
  },
  init_options = { bundles = {} },
  on_attach = function(_, bufnr)
    -- handy Java actions
    vim.keymap.set('n', '<leader>oi', jdtls.organize_imports, { buffer = bufnr, desc = 'Java: Organize Imports' })
    vim.keymap.set('n', '<leader>ev', jdtls.extract_variable, { buffer = bufnr, desc = 'Java: Extract Variable' })
    vim.keymap.set('v', '<leader>em', function() jdtls.extract_method(true) end,
      { buffer = bufnr, desc = 'Java: Extract Method' })
  end,
}

jdtls.start_or_attach(config)

