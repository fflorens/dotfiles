-- Shared popup manager: ensures only one popup is open at a time.
-- Each widget that has a popup registers a close function here.
-- Before opening a popup, call close_all() to dismiss any open one.
local M = {}
local closers = {}

function M.register(close_fn)
    table.insert(closers, close_fn)
end

function M.close_all()
    for _, fn in ipairs(closers) do
        fn()
    end
end

return M
