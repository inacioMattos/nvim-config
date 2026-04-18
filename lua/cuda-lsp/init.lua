-- cuda-lsp.lua
-- Dual clangd LSP for CUDA: one for host code, one for device code
-- Intelligently merges diagnostics to avoid false positives
--
-- ARCHITECTURE:
-- Host client: C++ mode with CUDA runtime API (full stdlib + cudaMalloc etc)
-- Device client: CUDA mode for __global__/__device__ functions
-- Filter: suppress kernel launch syntax and CUDA keywords from host client

local M = {}

-- Track our custom LSP clients
M.host_client_id = nil
M.device_client_id = nil

-- Cache for device function ranges (updated on buffer change)
M.device_ranges = {}

-- Temp directories for configs
M.host_config_dir = nil
M.device_config_dir = nil

-- Configuration
M.config = {
  clangd_path = "clangd",
  cuda_path = "/opt/cuda",
  gpu_arch = "sm_120",
  debug = false,
}

local function log(msg)
  if M.config.debug then
    vim.notify("[cuda-lsp] " .. msg, vim.log.levels.DEBUG)
  end
end

-- Create a temporary directory
local function create_config_dir(mode)
  local tmp_dir = vim.fn.tempname()
  vim.fn.mkdir(tmp_dir, "p")
  log("Created " .. mode .. " temp dir at: " .. tmp_dir)
  return tmp_dir
end

-- Generate compile_commands.json for a specific file
local function write_compile_commands(config_dir, filepath, mode)
  local abs_path = vim.fn.fnamemodify(filepath, ":p")
  local dir = vim.fn.fnamemodify(filepath, ":p:h")

  -- Escape for JSON
  abs_path = abs_path:gsub("\\", "\\\\"):gsub('"', '\\"')
  dir = dir:gsub("\\", "\\\\"):gsub('"', '\\"')

  local compile_commands
  if mode == "host" then
    -- Host mode: plain C++ with CUDA runtime API header
    -- Gets full stdlib support + cudaMalloc, cudaError_t, etc.
    -- Won't understand __global__ or <<<>>> syntax (filtered out)
    compile_commands = string.format(
      [[
[
  {
    "directory": "%s",
    "file": "%s",
    "arguments": [
      "clang++",
      "-xc++",
      "-std=c++17",
      "-I%s/include",
      "-include", "cuda_runtime_api.h",
      "-c",
      "%s"
    ]
  }
]
]],
      dir,
      abs_path,
      M.config.cuda_path,
      abs_path
    )
  else
    -- Device mode: CUDA with device-only flag
    compile_commands = string.format(
      [[
[
  {
    "directory": "%s",
    "file": "%s",
    "arguments": [
      "clang++",
      "-xcuda",
      "--cuda-device-only",
      "--cuda-path=%s",
      "--cuda-gpu-arch=%s",
      "-Wno-unknown-cuda-version",
      "-I%s/include",
      "-std=c++17",
      "-c",
      "%s"
    ]
  }
]
]],
      dir,
      abs_path,
      M.config.cuda_path,
      M.config.gpu_arch,
      M.config.cuda_path,
      abs_path
    )
  end

  local cc_path = config_dir .. "/compile_commands.json"
  local f = io.open(cc_path, "w")
  if f then
    f:write(compile_commands)
    f:close()
    log("Wrote " .. mode .. " compile_commands.json for: " .. abs_path)
    return true
  else
    vim.notify("[cuda-lsp] Failed to write: " .. cc_path, vim.log.levels.ERROR)
    return false
  end
end

-- Regex-based detection of __global__ and __device__ function ranges
local function get_device_function_ranges_regex(bufnr)
  local ranges = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local in_device_func = false
  local brace_depth = 0
  local func_start = nil

  for i, line in ipairs(lines) do
    local row = i - 1 -- 0-indexed

    -- Check for device function start
    if not in_device_func then
      if
          line:match("__global__%s+")
          or line:match("__device__%s+")
          or line:match("__global__$")
          or line:match("__device__$")
      then
        -- Look for opening brace
        local open_braces = select(2, line:gsub("{", ""))
        local close_braces = select(2, line:gsub("}", ""))

        if open_braces > 0 then
          in_device_func = true
          func_start = row
          brace_depth = open_braces - close_braces

          if brace_depth <= 0 then
            -- Single-line function
            table.insert(ranges, { start_row = row, end_row = row })
            in_device_func = false
            func_start = nil
            brace_depth = 0
          end
        else
          -- Function signature spans multiple lines, mark as pending
          in_device_func = true
          func_start = row
          brace_depth = 0
        end
      end
    else
      -- Inside device function, track braces
      local open_braces = select(2, line:gsub("{", ""))
      local close_braces = select(2, line:gsub("}", ""))

      brace_depth = brace_depth + open_braces - close_braces

      if brace_depth <= 0 and (open_braces > 0 or close_braces > 0 or func_start ~= nil) then
        if open_braces > 0 or close_braces > 0 then
          -- Function ended
          table.insert(ranges, { start_row = func_start, end_row = row })
          log(string.format("Found device function: lines %d-%d", func_start + 1, row + 1))
          in_device_func = false
          func_start = nil
          brace_depth = 0
        end
      end
    end
  end

  return ranges
end

-- Check if a line is inside a device function
local function is_in_device_code(bufnr, line)
  local ranges = M.device_ranges[bufnr] or {}

  for _, range in ipairs(ranges) do
    if line >= range.start_row and line <= range.end_row then
      return true
    end
  end

  return false
end

-- Filter diagnostics based on source (host vs device)
local function filter_diagnostics(diagnostics, bufnr, is_device_client)
  local filtered = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  for _, diag in ipairs(diagnostics) do
    local line_num = diag.range and diag.range.start and diag.range.start.line or diag.lnum or 0
    local in_device = is_in_device_code(bufnr, line_num)
    local line_text = lines[line_num + 1] or ""
    local msg = diag.message or ""

    local suppress = false

    if is_device_client then
      -- Device client: only show diagnostics inside device functions
      if not in_device then
        suppress = true
      end
    else
      -- Host client: suppress device function bodies
      if in_device then
        suppress = true
      end

      -- Suppress kernel launch syntax (<<<>>>) - not valid C++
      if line_text:match("<<<") then
        suppress = true
      end

      -- Suppress __global__/__device__/__host__ keyword errors
      if
          msg:match("__global__")
          or msg:match("__device__")
          or msg:match("__host__")
          or msg:match("unknown attribute 'global'")
          or msg:match("unknown attribute 'device'")
          or msg:match("unknown attribute 'host'")
          or msg:match("expected expression")
          and line_text:match("<<<")
      then
        suppress = true
      end
    end

    if not suppress then
      table.insert(filtered, diag)
    end
  end

  return filtered
end

-- Custom diagnostic handler that filters based on client
local function make_diagnostic_handler(is_device_client)
  return function(err, result, ctx, config)
    if err then
      return
    end
    if not result then
      return
    end

    local bufnr = vim.uri_to_bufnr(result.uri)

    -- Update device function ranges
    M.device_ranges[bufnr] = get_device_function_ranges_regex(bufnr)

    -- Filter diagnostics
    local original_count = #(result.diagnostics or {})
    local filtered = filter_diagnostics(result.diagnostics, bufnr, is_device_client)
    result.diagnostics = filtered

    local client_name = is_device_client and "device" or "host"
    log(string.format("[%s] Diagnostics: %d -> %d", client_name, original_count, #filtered))

    -- Call the default handler with filtered results
    vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
  end
end

-- Get the root directory for LSP
local function get_root_dir(fname)
  return vim.fs.dirname(vim.fs.find({
    "compile_commands.json",
    "compile_flags.txt",
    ".clangd",
    ".git",
    "Makefile",
    "CMakeLists.txt",
  }, { path = fname, upward = true })[1]) or vim.fn.getcwd()
end

-- Setup host clangd
local function setup_host_client(bufnr)
  if not M.host_config_dir then
    M.host_config_dir = create_config_dir("host")
  end

  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root = get_root_dir(fname)

  -- Write compile_commands.json for this file
  write_compile_commands(M.host_config_dir, fname, "host")

  local config = {
    name = "clangd_cuda_host",
    cmd = {
      M.config.clangd_path,
      "--background-index",
      "--completion-style=detailed",
      "--header-insertion=never",
      "--log=verbose",
      "--compile-commands-dir=" .. M.host_config_dir,
    },
    filetypes = { "cuda" },
    root_dir = root,
    handlers = {
      ["textDocument/publishDiagnostics"] = make_diagnostic_handler(false),
    },
    on_attach = function(client, buf)
      log("Host client attached to buffer " .. buf)
      M.host_client_id = client.id
    end,
    on_error = function(code, ...)
      log("Host client error: " .. tostring(code))
    end,
  }

  return config
end

-- Setup device clangd
local function setup_device_client(bufnr)
  if not M.device_config_dir then
    M.device_config_dir = create_config_dir("device")
  end

  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root = get_root_dir(fname)

  -- Write compile_commands.json for this file
  write_compile_commands(M.device_config_dir, fname, "device")

  local config = {
    name = "clangd_cuda_device",
    cmd = {
      M.config.clangd_path,
      "--background-index",
      "--completion-style=detailed",
      "--header-insertion=never",
      "--log=verbose",
      "--compile-commands-dir=" .. M.device_config_dir,
    },
    filetypes = { "cuda" },
    root_dir = root,
    handlers = {
      ["textDocument/publishDiagnostics"] = make_diagnostic_handler(true),
    },
    on_attach = function(client, buf)
      log("Device client attached to buffer " .. buf)
      M.device_client_id = client.id
    end,
    on_error = function(code, ...)
      log("Device client error: " .. tostring(code))
    end,
  }

  return config
end

-- Start both LSP clients for a buffer
function M.attach(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Initialize device ranges for this buffer
  M.device_ranges[bufnr] = get_device_function_ranges_regex(bufnr)

  local host_config = setup_host_client(bufnr)
  local device_config = setup_device_client(bufnr)

  -- Start clients
  local host_id = vim.lsp.start(host_config, { bufnr = bufnr })
  local device_id = vim.lsp.start(device_config, { bufnr = bufnr })

  if host_id then
    log("Started host LSP client (id=" .. host_id .. ")")
  else
    vim.notify("[cuda-lsp] Failed to start host LSP", vim.log.levels.WARN)
  end

  if device_id then
    log("Started device LSP client (id=" .. device_id .. ")")
  else
    vim.notify("[cuda-lsp] Failed to start device LSP", vim.log.levels.WARN)
  end
end

-- Setup autocmd to attach to CUDA files
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "cuda" },
    callback = function(args)
      -- Small delay to ensure buffer is ready
      vim.defer_fn(function()
        M.attach(args.buf)
      end, 100)
    end,
    desc = "Attach dual CUDA LSP clients",
  })

  -- Disable inlay hints for CUDA files
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      if vim.bo[args.buf].filetype == "cuda" then
        vim.defer_fn(function()
          vim.lsp.inlay_hint.enable(false, { bufnr = args.buf })
        end, 200)
      end
    end,
    desc = "Disable inlay hints for CUDA buffers",
  })

  -- Update device ranges on text change
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    pattern = { "*.cu", "*.cuh" },
    callback = function(args)
      M.device_ranges[args.buf] = get_device_function_ranges_regex(args.buf)
    end,
    desc = "Update CUDA device function ranges",
  })

  -- Cleanup temp dirs on exit
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      if M.host_config_dir then
        vim.fn.delete(M.host_config_dir, "rf")
      end
      if M.device_config_dir then
        vim.fn.delete(M.device_config_dir, "rf")
      end
    end,
    desc = "Cleanup CUDA LSP temp directories",
  })

  -- Commands
  vim.api.nvim_create_user_command("CudaLspDebug", function()
    M.config.debug = not M.config.debug
    vim.notify("CUDA LSP debug: " .. tostring(M.config.debug))
  end, {})

  vim.api.nvim_create_user_command("CudaLspShowRanges", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local ranges = M.device_ranges[bufnr] or {}
    if #ranges == 0 then
      vim.notify("No device functions detected")
    else
      local msg = "Device function ranges:\n"
      for _, r in ipairs(ranges) do
        msg = msg .. string.format("  Lines %d-%d\n", r.start_row + 1, r.end_row + 1)
      end
      vim.notify(msg)
    end
  end, {})

  vim.api.nvim_create_user_command("CudaLspShowConfig", function()
    local msg = string.format(
      [[CUDA LSP Config:
  clangd: %s
  cuda_path: %s
  gpu_arch: %s
  host_config: %s
  device_config: %s
  debug: %s
]],
      M.config.clangd_path,
      M.config.cuda_path,
      M.config.gpu_arch,
      M.host_config_dir or "nil",
      M.device_config_dir or "nil",
      tostring(M.config.debug)
    )
    vim.notify(msg)
  end, {})

  vim.api.nvim_create_user_command("CudaLspRestart", function()
    -- Stop all cuda lsp clients
    for _, client in ipairs(vim.lsp.get_clients()) do
      if client.name:match("^clangd_cuda") then
        client:stop()
      end
    end
    -- Clean up old config dirs
    if M.host_config_dir then
      vim.fn.delete(M.host_config_dir, "rf")
    end
    if M.device_config_dir then
      vim.fn.delete(M.device_config_dir, "rf")
    end
    M.host_config_dir = nil
    M.device_config_dir = nil
    -- Reattach (will recreate config dirs)
    vim.defer_fn(function()
      M.attach()
    end, 200)
    vim.notify("CUDA LSP restarted")
  end, {})

  log("CUDA dual LSP setup complete")
end

return M
