local colors    = require("colors")
local icons     = require("icons")
local settings  = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_layout_change")

local spaces          = {}
local space_paddings  = {}

-- Build workspace -> monitor mapping at startup
local monitors           = get_monitors()
local workspace_to_monitor = {}
local all_workspaces     = {}

for _, monitor in ipairs(monitors) do
    local mid = tonumber(monitor)
    for _, ws in ipairs(get_workspaces_on_monitor(monitor)) do
        workspace_to_monitor[ws] = mid
        table.insert(all_workspaces, ws)
    end
end

table.sort(all_workspaces, function(a, b)
    local na, nb = tonumber(a), tonumber(b)
    if na == 0 then return false end
    if nb == 0 then return true end
    return na < nb
end)

local current_workspace = get_current_workspace()

-- Fetch window list for a workspace, call callback(icon_line, has_windows).
-- Deduplicates icons when all windows in a workspace are the same app.
local function fetch_workspace_state(workspace, callback)
    sbar.exec("aerospace list-windows --workspace " .. workspace .. " --format '%{app-name}' --json", function(apps)
        local has_windows = #apps > 0
        local icon_line   = ""
        if has_windows then
            local icon_list = {}
            for _, app in ipairs(apps) do
                icon_list[#icon_list + 1] = app_icons[app["app-name"]] or app_icons["default"]
            end
            local all_same = true
            for j = 2, #icon_list do
                if icon_list[j] ~= icon_list[1] then all_same = false; break end
            end
            if all_same then
                icon_line = " " .. icon_list[1]
            else
                for _, icon in ipairs(icon_list) do icon_line = icon_line .. " " .. icon end
            end
        else
            icon_line = " —"
        end
        callback(icon_line, has_windows)
    end)
end

local function update_all_workspaces()
    local focused          = get_current_workspace()
    local workspace_monitor = {}
    local ws_apps          = {}
    local pending          = 2

    local function apply()
        for _, workspace in ipairs(all_workspaces) do
            local space   = spaces[workspace]
            local padding = space_paddings[workspace]
            if not space then goto continue end

            local mid = workspace_monitor[workspace]
            if mid and workspace_to_monitor[workspace] ~= mid then
                workspace_to_monitor[workspace] = mid
                space:set({ associated_display = mid })
                padding:set({ associated_display = mid })
            end

            local is_focused  = workspace == focused
            local apps        = ws_apps[workspace] or {}
            local has_windows = #apps > 0
            local icon_line   = ""

            if has_windows then
                local icon_list = {}
                for _, app_name in ipairs(apps) do
                    icon_list[#icon_list + 1] = app_icons[app_name] or app_icons["default"]
                end
                local all_same = true
                for j = 2, #icon_list do
                    if icon_list[j] ~= icon_list[1] then all_same = false; break end
                end
                if all_same then
                    icon_line = " " .. icon_list[1]
                else
                    for _, icon in ipairs(icon_list) do icon_line = icon_line .. " " .. icon end
                end
            else
                icon_line = " —"
            end

            space:set({
                drawing = has_windows or is_focused,
                icon    = { highlight = is_focused },
                label   = { string = icon_line, highlight = is_focused }
            })
            padding:set({ drawing = has_windows or is_focused })

            ::continue::
        end
    end

    -- Both queries run in parallel; apply() fires once both have returned.
    sbar.exec("aerospace list-workspaces --all --format '%{monitor-id} %{workspace}' --json 2>/dev/null", function(result)
        if type(result) == "table" then
            for _, entry in ipairs(result) do
                local mid = tonumber(entry["monitor-id"])
                local ws  = entry["workspace"]
                if mid and ws then workspace_monitor[ws] = mid end
            end
        end
        pending = pending - 1
        if pending == 0 then apply() end
    end)

    sbar.exec("aerospace list-windows --all --format '%{workspace} %{app-name}' --json 2>/dev/null", function(result)
        if type(result) == "table" then
            for _, win in ipairs(result) do
                local ws  = win["workspace"]
                local app = win["app-name"]
                if ws and app then
                    ws_apps[ws] = ws_apps[ws] or {}
                    table.insert(ws_apps[ws], app)
                end
            end
        end
        pending = pending - 1
        if pending == 0 then apply() end
    end)
end

for i, workspace in ipairs(all_workspaces) do
    local selected = workspace == current_workspace
    local display  = workspace_to_monitor[workspace] or 1

    local space = sbar.add("item", "item." .. workspace, {
        associated_display = display,
        drawing = selected,
        icon = {
            font            = { family = settings.font.numbers },
            string          = workspace,
            padding_left    = settings.items.padding.left,
            padding_right   = settings.items.padding.left / 2,
            color           = settings.items.default_color(i),
            highlight_color = settings.items.highlight_color(i),
            highlight       = selected
        },
        label = {
            padding_right   = settings.items.padding.right,
            color           = settings.items.default_color(i),
            highlight_color = settings.items.highlight_color(i),
            font            = settings.icons,
            y_offset        = -1,
            highlight       = selected
        },
        padding_right = 1,
        padding_left  = 1,
        background = {
            color        = settings.items.colors.background,
            border_width = 1,
            height       = settings.items.height,
            border_color = selected
                and settings.items.highlight_color(i)
                or  settings.items.default_color(i)
        },
        popup = {
            background = {
                border_width = 5,
                border_color = colors.black
            }
        }
    })

    local padding = sbar.add("item", "item." .. workspace .. ".padding", {
        associated_display = display,
        drawing = selected,
        script  = "",
        width   = settings.items.gap
    })

    local space_popup = sbar.add("item", {
        position      = "popup." .. space.name,
        padding_left  = 5,
        padding_right = 0,
        background    = {
            drawing = true,
            image   = { corner_radius = 9, scale = 0.2 }
        }
    })

    spaces[workspace]         = space
    space_paddings[workspace] = padding

    fetch_workspace_state(workspace, function(icon_line, has_windows)
        local visible = has_windows or selected
        space:set({ drawing = visible, label = { string = icon_line } })
        padding:set({ drawing = visible })
    end)

    space:subscribe("aerospace_workspace_change", function(env)
        local is_focused = env.FOCUSED_WORKSPACE == workspace
        if is_focused then
            space:set({ drawing = true })
            padding:set({ drawing = true })
        end
        space:set({
            icon  = { highlight = is_focused },
            label = { highlight = is_focused },
            background = {
                border_color = is_focused
                    and settings.items.highlight_color(i)
                    or  settings.items.default_color(i)
            }
        })
    end)

    space:subscribe("mouse.clicked", function(env)
        local ws = env.NAME:match("^item%.(.+)$")
        if not ws then return end
        if env.BUTTON == "other" then
            space_popup:set({ background = { image = "item." .. ws } })
            space:set({ popup = { drawing = "toggle" } })
        else
            sbar.exec("aerospace workspace " .. ws)
        end
    end)

    space:subscribe("mouse.exited", function(_)
        space:set({ popup = { drawing = false } })
    end)
end

local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true
})

local spaces_indicator = sbar.add("item", {
    padding_left  = -3,
    padding_right = 0,
    icon = {
        padding_left  = 8,
        padding_right = 9,
        color         = colors.grey,
        string        = icons.switch.on
    },
    label = {
        width         = 0,
        padding_left  = 0,
        padding_right = 8,
        string        = "Spaces",
        color         = colors.bg1
    },
    background = {
        color        = colors.with_alpha(colors.grey, 0.0),
        border_color = colors.with_alpha(colors.bg1, 0.0)
    }
})

space_window_observer:subscribe("aerospace_layout_change",   function(_) update_all_workspaces() end)
space_window_observer:subscribe("aerospace_workspace_change", function(_) update_all_workspaces() end)
space_window_observer:subscribe("display_change",             function(_) update_all_workspaces() end)
space_window_observer:subscribe("system_woke",                function(_) update_all_workspaces() end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(_)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
end)

spaces_indicator:subscribe("mouse.entered", function(_)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color        = { alpha = 1.0 },
                border_color = { alpha = 1.0 }
            },
            icon  = { color = colors.bg1 },
            label = { width = "dynamic" }
        })
    end)
end)

spaces_indicator:subscribe("mouse.exited", function(_)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color        = { alpha = 0.0 },
                border_color = { alpha = 0.0 }
            },
            icon  = { color = colors.grey },
            label = { width = 0 }
        })
    end)
end)

spaces_indicator:subscribe("mouse.clicked", function(_)
    sbar.trigger("swap_menus_and_spaces")
end)
