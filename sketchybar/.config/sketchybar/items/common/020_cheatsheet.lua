local colors        = require("colors")
local settings      = require("settings")
local popup_manager = require("helpers.popup_manager")

sbar.add("event", "cheatsheet_toggle")

local cheatsheet = sbar.add("item", "cheatsheet", {
    position = "right",
    icon = {
        drawing       = false,
        width         = 0,
        padding_left  = 0,
        padding_right = 0,
    },
    label = {
        string        = "?",
        font          = { family = settings.font.text, style = "Bold", size = 14.0 },
        color         = colors.grey,
        padding_left  = settings.widget.icon_padding_left,
        padding_right = settings.widget.icon_padding_right,
    },
    background = {
        color        = colors.bg1,
        border_color = colors.grey,
        border_width = 1,
        height       = settings.items.height,
        corner_radius = settings.items.corner_radius,
    },
    padding_left  = 1,
    padding_right = 1,
    popup = {
        align = "right",
        background = {
            color        = colors.popup.bg,
            border_color = colors.popup.border,
            border_width  = 1,
            corner_radius = 9,
        }
    }
})

-- Populate popup items at startup by parsing ~/.aerospace.toml
sbar.exec("$CONFIG_DIR/helpers/common/parse_cheatsheet.sh", function(output)
    local idx = 0
    for raw in output:gmatch("[^\n]+") do
        idx = idx + 1
        local kind, text = raw:match("^(%a+):(.*)$")
        if not kind then goto continue end

        if kind == "HEADER" then
            sbar.add("item", "cheatsheet.h" .. idx, {
                position = "popup.cheatsheet",
                icon     = { drawing = false },
                label    = {
                    string        = text,
                    font          = { family = settings.font.text, style = "Bold", size = 11.0 },
                    color         = colors.blue,
                    padding_left  = 12,
                    padding_right = 12,
                },
                background = { drawing = false },
                padding_left  = 0,
                padding_right = 0,
            })
        elseif kind == "LINE" then
            sbar.add("item", "cheatsheet.l" .. idx, {
                position = "popup.cheatsheet",
                icon     = { drawing = false },
                label    = {
                    string        = text ~= "" and text or " ",
                    font          = { family = settings.font.text, style = "Regular", size = 11.0 },
                    color         = colors.white,
                    padding_left  = 12,
                    padding_right = 12,
                },
                background = { drawing = false },
                padding_left  = 0,
                padding_right = 0,
            })
        end
        ::continue::
    end
end)

local popup_open = false

local function close()
    if not popup_open then return end
    popup_open = false
    cheatsheet:set({ label = { color = colors.grey }, popup = { drawing = false } })
end

popup_manager.register(close)

local function toggle()
    local was_open = popup_open
    popup_manager.close_all()
    if not was_open then
        popup_open = true
        cheatsheet:set({ label = { color = colors.blue }, popup = { drawing = true } })
    end
end

cheatsheet:subscribe("cheatsheet_toggle", function(_) toggle() end)
cheatsheet:subscribe("mouse.clicked",     function(_) toggle() end)
cheatsheet:subscribe("mouse.exited.global", function(_) close() end)

sbar.add("item", "cheatsheet.padding", {
    position = "right",
    width    = settings.group_paddings
})
