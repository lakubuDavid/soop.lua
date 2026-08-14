local source = debug.getinfo(1, "S").source:match("^@(.+)$") or "version.lua"
local directory = source:match("^(.*/)") or "./"
local file = assert(io.open(directory .. "VERSION", "r"), "VERSION file not found")
local version = file:read("*l")
file:close()
return assert(version and version:match("^%d+%.%d+%.%d+$"), "invalid VERSION")
