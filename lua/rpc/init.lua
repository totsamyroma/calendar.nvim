local M = {}

local calendar_job = nil
local next_id = 1
local pending = {}

-- Start the Ruby calendar server as a job
function M.start_server(cmd)
  if calendar_job then
    vim.notify("Calendar server already started", vim.log.levels.WARN)
    return
  end
  vim.notify("Starting calendar server...", vim.log.levels.INFO)
  calendar_job = vim.fn.jobstart(cmd or { "./server/server.rb" }, {
    on_stdout = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.notify("[calendar_server] " .. line, vim.log.levels.INFO)
        end
      end
    end,
    on_stderr = function(_, data)
      for _, line in ipairs(data) do
        if line ~= "" then
          vim.notify("[calendar_server] " .. line, vim.log.levels.ERROR)
        end
      end
    end,
    stdout_buffered = false,
    stderr_buffered = false,
  })
end

-- Send a JSON-RPC request to the server
function M.send_request(method, params, callback)
  if not calendar_job then
    vim.notify("Calendar server not started", vim.log.levels.ERROR)
    return
  end
  vim.notify("Sending request: " .. method, vim.log.levels.DEBUG)
  local id = next_id
  next_id = next_id + 1
  pending[id] = callback
  local req = {
    jsonrpc = "2.0",
    id = id,
    method = method,
    params = params or {}
  }
  vim.fn.chansend(calendar_job, vim.fn.json_encode(req) .. "\n")
end

return M
