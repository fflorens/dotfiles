local colors        = require("colors")
local icons         = require("icons")
local settings      = require("settings")
local popup_manager = require("helpers.popup_manager")

local BT_HELPER = "$CONFIG_DIR/helpers/bluetooth/bin/bluetooth_battery"

local popup_open = false

local bluetooth = sbar.add("item", "widgets.bluetooth", {
    position     = "right",
    padding_left  = settings.widget.padding_left,
    padding_right = settings.widget.padding_right,
    icon = {
        string = icons.bluetooth.on,
        color = colors.grey,
        padding_left  = settings.widget.icon_padding_left,
        padding_right = settings.widget.icon_padding_right,
        font = {
            style = settings.font.style_map["Regular"],
            size = 14.0
        }
    },
    label = { drawing = false },
    background = {
        color = colors.bg1,
        border_color = colors.blue,
        border_width = 1
    },
    popup = { align = "center" }
})

sbar.add("item", "widgets.bluetooth.padding", {
    position = "right",
    width = settings.group_paddings
})

local function bluetooth_collapse()
    if not popup_open then return end
    popup_open = false
    bluetooth:set({ popup = { drawing = false } })
    sbar.remove("/bluetooth.device\\..*/")
end

popup_manager.register(bluetooth_collapse)

local function battery_icon_for(pct)
    if pct > 75 then return icons.battery._100
    elseif pct > 50 then return icons.battery._75
    elseif pct > 25 then return icons.battery._50
    elseif pct > 5  then return icons.battery._25
    else                  return icons.battery._0
    end
end

local function battery_color_for(pct)
    if pct > 30 then return colors.green
    elseif pct > 15 then return colors.yellow
    else return colors.red
    end
end

local function bluetooth_toggle(env)
    local was_open = popup_open
    popup_manager.close_all()
    if was_open then return end
    popup_open = true
    bluetooth:set({ popup = { drawing = true } })

    -- Helper outputs: address|name|connected|battery (-1 = unavailable)
    sbar.exec(BT_HELPER, function(result)
        local devices = {}
        for line in result:gmatch("[^\r\n]+") do
            local address, name, conn_str, batt_str = line:match("([^|]+)|([^|]+)|([^|]+)|([^|]+)")
            if address then
                devices[#devices + 1] = {
                    address = address,
                    name    = name,
                    conn    = conn_str == "1",
                    battery = tonumber(batt_str) or -1
                }
            end
        end

        -- Connected devices first, then alphabetical
        table.sort(devices, function(a, b)
            if a.conn ~= b.conn then return a.conn end
            return a.name < b.name
        end)

        if #devices == 0 then
            sbar.add("item", "bluetooth.device.none", {
                position = "popup." .. bluetooth.name,
                icon = {
                    string = "No paired devices",
                    color = colors.grey,
                    align = "left",
                    padding_left = 8,
                    width = 200,
                    font = { style = settings.font.style_map["Regular"], size = 13.0 }
                },
                label = { drawing = false }
            })
            return
        end

        for i, dev in ipairs(devices) do
            local batt_str   = ""
            local batt_color = colors.grey
            if dev.conn and dev.battery >= 0 then
                batt_str   = battery_icon_for(dev.battery) .. " " .. dev.battery .. "%"
                batt_color = battery_color_for(dev.battery)
            end

            local prefix     = dev.conn and "● " or "○ "
            local name_color = dev.conn and colors.white or colors.grey

            sbar.add("item", "bluetooth.device." .. i, {
                position = "popup." .. bluetooth.name,
                icon = {
                    string = prefix .. dev.name,
                    color = name_color,
                    align = "left",
                    padding_left = 8,
                    width = 170,
                    font = {
                        style = settings.font.style_map["Regular"],
                        size = 13.0
                    }
                },
                label = {
                    string = batt_str,
                    color = batt_color,
                    align = "right",
                    padding_right = 8,
                    width = 60,
                    font = { size = 13.0 }
                },
                click_script = dev.conn
                    and 'blueutil --disconnect "' .. dev.address .. '"'
                        .. ' && sketchybar --set $NAME icon.color=' .. colors.grey
                    or  'blueutil --connect "' .. dev.address .. '"'
                        .. ' && sketchybar --set $NAME icon.color=' .. colors.white
            })
        end
    end)
end

local function bluetooth_update()
    sbar.exec(BT_HELPER, function(result)
        local any_connected = result:find("|1|") ~= nil
        bluetooth:set({
            icon = { color = any_connected and colors.blue or colors.grey }
        })
    end)
end

bluetooth:subscribe("mouse.clicked", bluetooth_toggle)
bluetooth:subscribe("mouse.exited.global", bluetooth_collapse)

local bluetooth_poller = sbar.add("item", "bluetooth.poller", {
    drawing = false,
    updates = true,
    update_freq = 10
})
bluetooth_poller:subscribe("routine", bluetooth_update)
bluetooth_poller:subscribe("system_woke", bluetooth_update)

bluetooth_update()
