local restore_layout = require("neodim.layout").restore_layout
local take_snapshot = require("neodim.layout").take_snapshot

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

M.open_layout = function(index)
  if index == current then
    return
  end
  local snapshot = snapshots[index]
  snapshots[current] = take_snapshot(snapshots[current].name)
  restore_layout(snapshot)
  current = index
  print(snapshots[current].name)
end

M.next_layout = function()
  M.open_layout(next_index())
end

M.prev_layout = function()
  M.open_layout(prev_index())
end

M.shift_layout = function(index)
  snapshots[current], snapshots[index] = snapshots[index], snapshots[current]
  current = index
end

M.shift_layout_front = function()
  M.shift_layout(next_index())
end

M.shift_layout_back = function()
  M.shift_layout(prev_index())
end

M.new_layout = function()
  snapshots[current] = take_snapshot(snapshots[current].name)
  current = #snapshots + 1
  vim.cmd("silent! tabonly | only")
  snapshots[current] = take_snapshot("Layout " .. current)
  print(snapshots[current].name)
end

M.delete_layout = function(index)
  if current == index then
    vim.fn.confirm("Cannot delete current layout")
    return
  end
  table.remove(snapshots, index)
  if current > index then
    current = current - 1
  end
end

M.rename_layout = function(index)
  local snapshot = snapshots[index]
  local new_name = vim.fn.input("New name: ", snapshot.name)
  if new_name ~= "" then
    snapshot.name = new_name
  end
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

--- Wipes all buffers that are not opened in any layout
M.delete_buffers_not_in_layout = function()
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
