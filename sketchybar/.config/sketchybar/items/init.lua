local profile = require("profile")
local base    = os.getenv("HOME") .. "/.config/sketchybar/items"

-- Collect .lua files from common/ (always) and work/ (when sentinel present)
local dirs = { base .. "/common" }
if profile == "work" then dirs[#dirs + 1] = base .. "/work" end
if profile == "personal" then dirs[#dirs + 1] = base .. "/personal" end

local all = {}
for _, dir in ipairs(dirs) do
    local h = io.popen("ls '" .. dir .. "'/*.lua 2>/dev/null")
    if h then
        for line in h:lines() do all[#all + 1] = line end
        h:close()
    end
end

-- Sort by filename (NNN_name.lua) — lower number loads first = further right in bar
table.sort(all, function(a, b)
    return a:match("[^/]+$") < b:match("[^/]+$")
end)

for _, path in ipairs(all) do dofile(path) end
