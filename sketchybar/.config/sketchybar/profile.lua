-- Returns "work" when the work sentinel file is present (stowed by work dotfiles),
-- "personal" otherwise. This drives conditional loading of work-only bar items.
local f = io.open(os.getenv("HOME") .. "/.config/sketchybar/.work", "r")
if f then f:close(); return "work" end
return "personal"
