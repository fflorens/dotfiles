local icons         = require("icons")
local colors        = require("colors")
local settings      = require("settings")
local popup_manager = require("helpers.popup_manager")

local battery = sbar.add("item", "widgets.battery", {
    position      = "right",
    padding_left  = settings.widget.padding_left,
    padding_right = settings.widget.padding_right,
    icon = {
        font = {
            style = settings.font.style_map["Regular"],
            size = 19.0
        }
    },
    label = {
        font = {
            family = settings.font.numbers
        }
    },
    update_freq = 180,
    popup = {
        align = "center"
    }
})

local remaining_time = sbar.add("item", {
    position = "popup." .. battery.name,
    icon = {
        string = "Time remaining:",
        width = 100,
        align = "left"
    },
    label = {
        string = "??:??h",
        width = 100,
        align = "right"
    }
})

battery:subscribe({"routine", "power_source_change", "system_woke"}, function()
    sbar.exec("pmset -g batt", function(batt_info)
        local icon = "!"
        local label = "?"

        local found, _, charge = batt_info:find("(%d+)%%")
        if found then
            charge = tonumber(charge)
            label = charge .. "%"
        end

        local color = colors.green
        local charging, _, _ = batt_info:find("AC Power")

        if charging then
            icon = icons.battery.charging
        else
            if found and charge > 80 then
                icon = icons.battery._100
            elseif found and charge > 60 then
                icon = icons.battery._75
            elseif found and charge > 40 then
                icon = icons.battery._50
            elseif found and charge > 20 then
                icon = icons.battery._25
                color = colors.orange
            else
                icon = icons.battery._0
                color = colors.red
            end
        end

        local lead = ""
        if found and charge < 10 then
            lead = "0"
        end

        battery:set({
            icon = {
                string = icon,
                color = color
            },
            label = {
                string = lead .. label
            }
        })
    end)
end)

popup_manager.register(function()
    battery:set({ popup = { drawing = false } })
end)

battery:subscribe("mouse.clicked", function(env)
    local was_open = battery:query().popup.drawing == "on"
    popup_manager.close_all()

    if not was_open then
        battery:set({ popup = { drawing = true } })
        sbar.exec("pmset -g batt", function(batt_info)
            local charging = batt_info:find("AC Power")
            local _, _, charge = batt_info:find("(%d+)%%")
            local label
            if charging and tonumber(charge) == 100 then
                remaining_time:set({
                    icon  = { string = "Status:" },
                    label = { string = "Fully charged" }
                })
            else
                local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
                remaining_time:set({
                    icon  = { string = "Time remaining:" },
                    label = { string = found and remaining .. "h" or "No estimate" }
                })
            end
        end)
    end
end)

sbar.add("bracket", "widgets.battery.bracket", {battery.name}, {
    background = {
        color = colors.bg1,
        border_color = colors.rainbow[#colors.rainbow - 2],
        border_width = 1
    }
})

sbar.add("item", "widgets.battery.padding", {
    position = "right",
    width = settings.group_paddings
})
