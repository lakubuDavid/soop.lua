-- Shared template helpers used by the launcher and manifests.
local M = {}

local filters = {
  safe_name = function(value)
    return (value:gsub("-", "_"))
  end,
  lower = function(value)
    return value:lower()
  end,
  upper = function(value)
    return value:upper()
  end,
}

--- Render Soop template tokens in a string.
---
--- Supported forms:
---   @@NAME@@
---   ${NAME}
---   ${{NAME:filter}}
---
--- Prefix a token with a backslash to preserve it literally. Filtered
--- interpolation accepts whitespace around the variable and filter names.
---@param content string
---@param variables table<string, any>
---@param options? {strict?: boolean}
---@return string
function M.template_string(content, variables, options)
  variables = variables or {}
  options = options or {}

  local escaped = {}
  local marker = string.char(1)
  local function protect(token)
    escaped[#escaped + 1] = token
    return marker .. tostring(#escaped) .. marker
  end

  content = content:gsub("\\(%$%{[%w_]+%})", protect)
  content = content:gsub("\\(%${{%s*[%w_]+%s*:%s*[%w_]+%s*}})", protect)
  content = content:gsub("\\(@@[%w_]+@@)", protect)

  content = content:gsub("@@([%w_]+)@@", function(name)
    local value = variables[name]
    if value ~= nil then return tostring(value) end
    return ""
  end)

  content = content:gsub("%${{%s*([%w_]+)%s*:%s*([%w_]+)%s*}}", function(name, filter_name)
    local value = variables[name]
    if value == nil then
      if options.strict then
        error("Template variable not found: " .. name, 0)
      end
      return "${{" .. name .. ":" .. filter_name .. "}}"
    end

    local filter = filters[filter_name]
    if not filter then
      error("Unknown interpolation filter: " .. filter_name, 0)
    end
    return filter(tostring(value))
  end)

  content = content:gsub("%$%{([%w_]+)%}", function(name)
    local value = variables[name]
    if value ~= nil then return tostring(value) end
    if options.strict then
      error("Template variable not found: " .. name, 0)
    end
    return "${" .. name .. "}"
  end)

  content = content:gsub(marker .. "(%d+)" .. marker, function(index)
    return escaped[tonumber(index)]
  end)

  return content
end

function M.template_filter(name, value)
  local filter = filters[name]
  if not filter then error("Unknown interpolation filter: " .. tostring(name), 0) end
  return filter(tostring(value))
end

return M
