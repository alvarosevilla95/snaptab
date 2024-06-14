local get_current = require("neodim.management").get_current
local set_current = require("neodim.management").set_current
local get_snapshots = require("neodim.management").get_snapshots
local set_snapshots = require("neodim.management").set_snapshots

local function serialize_state()
  return vim.fn.json_encode({ current = get_current(), snapshots = get_snapshots() })
end

local function deserialize_state(json_str)
  local state = vim.fn.json_decode(json_str)
  set_current(state.current)
  set_snapshots(state.snapshots)
end

local group_id = vim.api.nvim_create_augroup("NeodimSession", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group_id,
  pattern = "*",
  callback = function()
    local session = vim.v.this_session
    if vim.v.this_session ~= "" then
      local layout_file = session:gsub(".vim$", ".vim.layout")
      vim.fn.writefile({ serialize_state() }, layout_file)
    end
  end,
})

vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = group_id,
  pattern = "*",
  callback = function()
    local session = vim.v.this_session
    if vim.v.this_session ~= "" then
      local layout_file = session:gsub(".vim$", ".vim.layout")
      if vim.fn.filereadable(layout_file) then
        deserialize_state(vim.fn.readfile(layout_file)[1])
      end
    end
  end,
})
