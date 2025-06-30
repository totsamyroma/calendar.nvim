local calendar = require("calendar")

local M = {}

function M.run()
  local calendars = calendar.config.calendars

  if not calendars or vim.tbl_isempty(calendars) then
    print("No calendars found.")

    return
  end

  print("Calendars:")
  for name, url in pairs(calendars) do
    print("- " .. tostring(name))
  end
end

return M
