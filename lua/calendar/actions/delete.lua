local calendar = require("calendar")

local M = {}

function M.run(rest)
  local config = calendar.config
  local calendars = config.calendars or {}

  local names = {}
  for name, _ in pairs(calendars) do
    table.insert(names, name)
  end
  if #names == 0 then
    print("No calendars found.")
    return
  end
  print("Choose a calendar to delete:")
  for i, name in ipairs(names) do
    print(i .. ". " .. name)
  end
  local choice = vim.fn.input("Enter number: ")
  local idx = tonumber(choice)
  if not idx or idx < 1 or idx > #names then
    print("Invalid choice.")
    return
  end
  local selected = names[idx]
  calendars[selected] = nil
  if config.active == selected then
    config.active = nil
  end
  local f = io.open(calendar.config_path, "w")
  if config ~= nil and vim and vim.fn and vim.fn.json_encode then
    f:write(vim.fn.json_encode(config))
  else
    f:write("{}")
  end
  f:close()
  print("\nDeleted calendar: " .. selected)
end

return M
