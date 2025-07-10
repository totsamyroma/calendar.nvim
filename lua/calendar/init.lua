M = {}

local function ensure_file(file)
  local f = io.open(file, "r")
  if not f then
    f = io.open(file, "w")
    if f then
      f:write("{}")
      f:close()
    end
  else
    f:close()
  end
end

function M.config_path()
  local path = vim.fn.stdpath("data") .. "/calendars.json"

  ensure_file(path)

  return path
end

function M.config()
  local path = M.config_path or "/default/config/path"
  local f = io.open(path, "r")
  if not f then
    print("Could not open " .. path .. " for reading")
    return {}
  end
  local content = f:read("*a")
  f:close()
  if content == "" then
    print("No calendars found in " .. path)
    return {}
  end
  local ok, data = pcall(vim.fn.json_decode, content)
  if ok and type(data) == "table" then
    return data
  end
  return {}
end

M.config_path = M:config_path()
M.config = M:config()

return M
