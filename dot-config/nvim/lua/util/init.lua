---@class util
---@field fn util.fn
---@field map util.map
local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("util." .. k)
    return t[k]
  end,
})

return M
