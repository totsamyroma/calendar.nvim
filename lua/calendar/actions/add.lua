local calendar = require("calendar")

local M = {}

local function save_calendars(tbl)
  local config_path = calendar.config_path

  print("Writing to: " .. config_path)
  local f = io.open(config_path, "w")
  if not f then
    print("Could not open " .. config_path .. " for writing")
    return
  end
  f:write(vim.fn.json_encode(tbl))
  f:close()
end

function M.run(rest)
  local name, url = rest:match('^(%S+)%s+(%S+)$')
  if not name or not url then
    print("Usage: Calendar add calendar <name> <ics_url>")
    return
  end
  local config = calendar.config
  config.calendars[name] = url
  save_calendars(config)
  print("Calendar '" .. name .. "' added.")
end

return M
