--- Returns high precision system time in seconds.
---@type fun(): number
local time = require("socket").gettime

return time
