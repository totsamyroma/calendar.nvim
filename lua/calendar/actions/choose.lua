local calendar = require("calendar")

M = {}

function M.save_active_calendar(name)
  local config = calendar.config
  config.active = name
  local f = io.open(calendar.config_path, "w")
  if config ~= nil and vim and vim.fn and vim.fn.json_encode then
    f:write(vim.fn.json_encode(config))
  else
    f:write("{}")
  end
  f:close()
end

function M.run()
  local calendars = calendar.config.calendars

  local names = {}
  for name, _ in pairs(calendars) do
    table.insert(names, name)
  end
  if #names == 0 then
    print("No calendars found.")
    return
  end
  print("Choose a calendar:")
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
  M.save_active_calendar(selected)
  print("\nActive calendar set to: " .. selected)
end

return M
