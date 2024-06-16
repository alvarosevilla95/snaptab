local get_current = require("neodim.management").get_current
local set_current = require("neodim.management").set_current
local get_snapshots = require("neodim.management").get_snapshots
local set_snapshots = require("neodim.management").set_snapshots

local M = {}

M.serialize_state = function()
  return vim.fn.json_encode({ current = get_current(), snapshots = get_snapshots() })
end

M.restore_state = function(json_str)
  local state = vim.fn.json_decode(json_str)
  set_current(state.current)
  set_snapshots(state.snapshots)
end

return M
