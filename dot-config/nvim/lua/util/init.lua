---@class util
---@field fn util.fn
---@field map util.map
---@field mini util.mini
---@field tabline util.tabline
---@field tbl util.tbl
local M = {}

setmetatable(M, {
  __index = function(t, k)
    t[k] = require("util." .. k)
    return t[k]
  end,
})

return M
