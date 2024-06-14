local get_current = require("neodim.management").get_current
local set_current = require("neodim.management").set_current
local get_snapshots = require("neodim.management").get_snapshots
local set_snapshots = require("neodim.management").set_snapshots

local function serialize_state()
  local snapshots = get_snapshots()
  local names = vim.tbl_map(function(snapshot)
    local name = snapshot.name
    snapshot.name = nil
    return name
  end, snapshots)
  return vim.fn.json_encode({ current = get_current(), snapshots = snapshots, names = names })
end

local function deserialize_state(json_str)
  local state = vim.fn.json_decode(json_str)
  for i, snapshot in ipairs(state.snapshots) do
    snapshot.name = state.names[i]
  end
  set_current(state.current)
  set_snapshots(state.snapshots)
end

local group_id = vim.api.nvim_create_augroup("NeodimSession", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group_id,
  pattern = "*",
  callback = function()
    local session = vim.v.this_session
    if vim.v.this_session then
      vim.fn.writefile({ serialize_state() }, session:gsub(".vim$", ".vim.layout"))
    end
  end,
})

vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = group_id,
  pattern = "*",
  callback = function()
    local session = vim.v.this_session
    if not vim.v.this_session then
      return
    end
    local xsession = session:gsub(".vim$", ".vim.layout")
    if vim.fn.filereadable(xsession) == 0 then
      return
    end
    deserialize_state(vim.fn.readfile(xsession)[1])
  end,
})
