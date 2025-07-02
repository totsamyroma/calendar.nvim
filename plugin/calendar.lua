local rpc = require("rpc.init")

vim.api.nvim_create_user_command("Calendar", function(opts)
  local args = opts.fargs
  if #args < 2 then
    print("Usage: Calendar [add|delete|list|choose] [calendar|event|calendars|events] ...")
    return
  end

  local action = args[1]
  local target = args[2]
  local rest = ""
  if #args > 2 then
    rest = table.concat(args, " ", 3)
  end

  if action == "add" and target == "calendar" then
    require("calendar.actions.add").run(rest)
  elseif action == "delete" and target == "calendar" then
    require("calendar.actions.delete").run(rest)
  elseif action == "add" and target == "event" then
    require("event.actions.add").run(rest)
  elseif action == "delete" and target == "event" then
    require("event.actions.delete").run(rest)
  elseif action == "list" and target == "calendars" then
    require("calendar.actions.list").run()
  elseif action == "choose" and target == "calendar" then
    require("calendar.actions.choose").run(rest)
  elseif action == "list" and target == "events" then
    require("event.actions.list").run(rest)
  else
    print("Unknown Calendar command: " .. table.concat(args, " "))
  end
end, {
  nargs = "+",
  complete = nil,
})

-- Start the calendar server
vim.api.nvim_create_user_command("CalendarRPCStart", function()
  rpc.start_server()
end, { nargs = "*" })

-- Add a calendar
vim.api.nvim_create_user_command("CalendarRPCAdd", function(opts)
  local args = vim.split(opts.args, " ")
  local name, url = args[1], args[2]
  rpc.send_request("add_calendar", { name = name, url = url }, function(resp)
    if resp.result then
      vim.notify("Calendar added: " .. resp.result, vim.log.levels.INFO)
    elseif resp.error then
      vim.notify("Error: " .. resp.error.message, vim.log.levels.ERROR)
    else
      vim.notify("Unexpected response: " .. vim.inspect(resp), vim.log.levels.ERROR)
    end
  end)
end, { nargs = "+" })

-- List calendars
vim.api.nvim_create_user_command("CalendarRPCList", function()
  rpc.send_request("list_calendars", {}, function(resp)
    if resp.result then
      vim.notify(vim.inspect(resp.result), vim.log.levels.INFO)
    elseif resp.error then
      vim.notify("Error: " .. resp.error.message, vim.log.levels.ERROR)
    else
      vim.notify("Unexpected response: " .. vim.inspect(resp), vim.log.levels.ERROR)
    end
  end)
end, {})
