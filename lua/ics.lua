local calendar = require("calendar")

local Ics = {}
local json = {
  encode = vim.fn.json_encode,
  decode = vim.fn.json_decode
}

Ics.Info = {}
Ics.Info.__index = Ics.Info

function Ics.Info.new(url)
  local self = setmetatable({}, Ics.Info)
  self.url = url
  return self
end

-- Fetch calendar data using curl
function Ics.Info:fetch_ics()
  local handle = io.popen('curl -s "' .. self.url .. '"')
  local data = handle:read("*a")
  handle:close()
  return data
end

-- Parse events from ICS data (very basic, finds DTSTART/DTEND/SUMMARY)
function Ics.Info:parse_events(ics_data)
  local events = {}
  for event_block in ics_data:gmatch("BEGIN:VEVENT(.-)END:VEVENT") do
    local dtstart = event_block:match("DTSTART.-:(.-)\r?\n")
    local dtend = event_block:match("DTEND.-:(.-)\r?\n")
    local summary = event_block:match("SUMMARY:(.-)\r?\n")
    table.insert(events, {
      dtstart = dtstart or "",
      dtend = dtend or "",
      summary = summary or "",
    })
  end
  return events
end

function Ics.Info:format_date(dt)
    -- Handles basic YYYYMMDD or YYYYMMDDTHHMMSSZ
    if not dt or dt == "" then return "" end
    local y, m, d, h, min = dt:match("^(%d%d%d%d)(%d%d)(%d%d)T?(%d%d?)(%d%d?)")
    if y and m and d and h and min then
        return string.format("%s-%s-%s %s:%s", y, m, d, h, min)
    end
    y, m, d = dt:match("^(%d%d%d%d)(%d%d)(%d%d)")
    if y and m and d then
        return string.format("%s-%s-%s", y, m, d)
    end
    return dt
end

-- Print last 10 events
function Ics.Info:print_last_events(count)
  local ics = self:fetch_ics()
  local events = self:parse_events(ics)
  local out = {}
  for i = math.max(1, #events - count + 1), #events do
    local e = events[i]
    local dtstart = self:format_date(e.dtstart)
    local dtend = self:format_date(e.dtend)
    table.insert(out, string.format("%s - %s: %s", dtstart, dtend, e.summary))
  end
  return out
end

-- Return events for a specific date (YYYY-MM-DD)
function Ics.Info:events_for_date(date)
  local ics = self:fetch_ics()
  local events = self:parse_events(ics)
  local out = {}
  for _, e in ipairs(events) do
    local dtstart = self:format_date(e.dtstart)
    if dtstart:sub(1, 10) == date then
      local dtend = self:format_date(e.dtend)
      table.insert(out, string.format("%s - %s: %s", dtstart, dtend, e.summary))
    end
  end
  return out
end

function Ics.Info:events_for_today()
  local today = os.date("%Y-%m-%d")
  return self:events_for_date(today)
end

function Ics.Info:events_for_tomorrow()
  local tomorrow = os.date("%Y-%m-%d", os.time() + 86400)
  return self:events_for_date(tomorrow)
end

local function week_range(offset)
  local now = os.date("*t")
  local weekday = now.wday - 1
  local start = os.time { year = now.year, month = now.month, day = now.day } - (weekday * 86400) + (offset * 7 * 86400)
  local days = {}
  for i = 0, 6 do
    table.insert(days, os.date("%Y-%m-%d", start + i * 86400))
  end
  return days
end

function Ics.Info:events_for_this_week()
  local days = week_range(0)
  local out = {}
  for _, day in ipairs(days) do
    for _, line in ipairs(self:events_for_date(day)) do
      table.insert(out, line)
    end
  end
  return out
end

function Ics.Info:events_for_next_week()
  local days = week_range(1)
  local out = {}
  for _, day in ipairs(days) do
    for _, line in ipairs(self:events_for_date(day)) do
      table.insert(out, line)
    end
  end
  return out
end

function Ics.Info:events_for_this_month()
  local now = os.date("*t")
  local out = {}
  for day = 1, 31 do
    local ok, date = pcall(function()
      return os.date("%Y-%m-%d", os.time { year = now.year, month = now.month, day = day })
    end)
    if not ok or date:sub(6, 7) ~= string.format("%02d", now.month) then break end
    for _, line in ipairs(self:events_for_date(date)) do
      table.insert(out, line)
    end
  end
  return out
end

function Ics.Info:events_for_next_month()
  local now = os.date("*t")
  local year, month = now.year, now.month + 1
  if month > 12 then
    year = year + 1
    month = 1
  end
  local out = {}
  for day = 1, 31 do
    local ok, date = pcall(function()
      return os.date("%Y-%m-%d", os.time { year = year, month = month, day = day })
    end)
    if not ok or date:sub(6, 7) ~= string.format("%02d", month) then break end
    for _, line in ipairs(self:events_for_date(date)) do
      table.insert(out, line)
    end
  end
  return out
end

function Ics.Info:events_for_this_year()
  local now = os.date("*t")
  local out = {}
  for month = 1, 12 do
    for day = 1, 31 do
      local ok, date = pcall(function()
        return os.date("%Y-%m-%d", os.time { year = now.year, month = month, day = day })
      end)
      if not ok or date:sub(1, 4) ~= tostring(now.year) or date:sub(6, 7) ~= string.format("%02d", month) then break end
      for _, line in ipairs(self:events_for_date(date)) do
        table.insert(out, line)
      end
    end
  end
  return out
end

function Ics.Info:events_for_next_year()
  local now = os.date("*t")
  local year = now.year + 1
  local out = {}
  for month = 1, 12 do
    for day = 1, 31 do
      local ok, date = pcall(function()
        return os.date("%Y-%m-%d", os.time { year = year, month = month, day = day })
      end)
      if not ok or date:sub(1, 4) ~= tostring(year) or date:sub(6, 7) ~= string.format("%02d", month) then break end
      for _, line in ipairs(self:events_for_date(date)) do
        table.insert(out, line)
      end
    end
  end
  return out
end

return Ics
