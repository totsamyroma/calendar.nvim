local config = require("calendar").config
local ics = require("ics")
local async = require("plenary.async")

local M = {}

function M.run(rest)
  async.run(function()
    local url = config.calendars[config.active]
    vim.notify("Fetching calendar from: " .. url, vim.log.levels.INFO, { title = "Calendar" })

    local current_calendar = ics.Info.new(url)
    local lines

    if rest and rest[1] == "events" and rest[2] == "today" then
      local today = os.date("%Y-%m-%d")
      lines = current_calendar:events_for_date(today)
      if #lines == 0 then
        lines = { "No events for today." }
      end
    else
      lines = current_calendar:print_last_events(11)
    end

    -- Floating window
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    local width = 60
    local height = math.min(#lines, 15)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)
    vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
      title = "Calendar Events"
    })
  end)
end

return M
