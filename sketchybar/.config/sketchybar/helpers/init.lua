local helpers = os.getenv("HOME") .. "/.config/sketchybar/helpers"
local binaries = {
    helpers .. "/event_providers/cpu_load/bin/cpu_load",
    helpers .. "/event_providers/network_load/bin/network_load",
    helpers .. "/menus/bin/menus",
    helpers .. "/bluetooth/bin/bluetooth_battery",
}

local needs_build = false
for _, path in ipairs(binaries) do
    local f = io.open(path, "r")
    if f then f:close() else needs_build = true end
end

if needs_build then
    os.execute("cd '" .. helpers .. "' && make 2>/dev/null")
end
