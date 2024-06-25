local restore_snaphot = require("snaptab.layout").restore_snapshot
local take_snapshot = require("snaptab.layout").take_snapshot

local current = 1
local snapshots = { take_snapshot("Default") }

local M = {}

M.get_current = function()
  return current
end

M.set_current = function(value)
  current = value
end

M.get_snapshots = function()
  return snapshots
end

M.set_snapshots = function(value)
  snapshots = value
end

local function next_index()
  return (current % #snapshots) + 1
end

local function prev_index()
  return (current - 2) % #snapshots + 1
end

M.open_snapshot = function(index)
  if index == current then
    return
  end
  local snapshot = snapshots[index]
  snapshots[current] = take_snapshot(snapshots[current].name)
  restore_snaphot(snapshot)
  current = index
  print(snapshots[current].name)
end

M.next_snapshot = function()
  M.open_snapshot(next_index())
end

M.prev_snapshot = function()
  M.open_snapshot(prev_index())
end

M.shift_shapshot = function(index)
  snapshots[current], snapshots[index] = snapshots[index], snapshots[current]
  current = index
end

M.shift_snapshot_front = function()
  M.shift_shapshot(next_index())
end

M.shift_snapshot_back = function()
  M.shift_shapshot(prev_index())
end

M.new_snapshot = function()
  snapshots[current] = take_snapshot(snapshots[current].name)
  current = #snapshots + 1
  vim.cmd("silent! tabonly | only")
  snapshots[current] = take_snapshot("Snapshot " .. current)
  print(snapshots[current].name)
end

M.delete_snapshot = function(index)
  if current == index then
    vim.fn.confirm("Cannot delete current layout")
    return
  end
  table.remove(snapshots, index)
  if current > index then
    current = current - 1
  end
end

M.rename_snapshot = function(index)
  local snapshot = snapshots[index]
  local new_name = vim.fn.input("New name: ", snapshot.name)
  if new_name ~= "" then
    snapshot.name = new_name
  end
end

M.rename_current_snapshot = function()
  M.rename_snapshot(current)
end

local function get_layout_buffers(layout, buffers)
  if layout.type == "leaf" then
    buffers[layout.bufnr] = true
  else
    for _, child in ipairs(layout.children) do
      get_layout_buffers(child, buffers)
    end
  end
end

local function get_snapshot_buffers(snapshot, buffers)
  for _, layout in ipairs(snapshot.layouts) do
    get_layout_buffers(layout, buffers)
  end
end

local function get_all_snapshot_buffers()
  local buffers = {}
  for _, snapshot in ipairs(snapshots) do
    get_snapshot_buffers(snapshot, buffers)
  end
  return buffers
end

--- Wipes all buffers that are not opened in any snapshot
M.delete_buffers_not_in_any_snapshot = function()
  snapshots[current] = take_snapshot(snapshots[current].name)
  local in_layout = get_all_snapshot_buffers()
  local bufs = vim.fn.range(1, vim.fn.bufnr("$"))
  for _, buf in ipairs(bufs) do
    if vim.fn.bufexists(buf) == 1 and not in_layout[buf] then
      if buf ~= vim.g.term_bf then
        vim.cmd("silent! bwipeout " .. buf, false)
      end
    end
  end
end

return M
