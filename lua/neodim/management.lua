local restore_layout = require("neodim.layout").restore_layout
local take_snapshot = require("neodim.layout").take_snapshot

local current = 1

local snapshots = { take_snapshot("Default") }

local M = {}

M.get_current = function()
  return current
end

M.get_snapshots = function()
  return snapshots
end

M.open_layout = function(name)
  for i, snapshot in ipairs(snapshots) do
    if snapshot.name == name and current ~= i then
      snapshots[current] = take_snapshot(snapshots[current].name)
      restore_layout(snapshot)
      current = i
      return
    end
  end
end

M.next_layout = function()
  if #snapshots == 0 then
    return
  end
  snapshots[current] = take_snapshot(snapshots[current].name)
  current = current + 1 % #snapshots
  if current > #snapshots then
    current = 1
  end
  restore_layout(snapshots[current])
end

M.prev_layout = function()
  if #snapshots == 0 then
    return
  end
  snapshots[current] = take_snapshot(snapshots[current].name)
  current = current - 1
  if current < 1 then
    current = #snapshots
  end
  restore_layout(snapshots[current])
end

M.shift_layout_back = function()
  local next = current - 1
  if next < 1 then
    next = #snapshots
  end
  snapshots[current], snapshots[next] = snapshots[next], snapshots[current]
  current = next
end

M.shift_layout_front = function()
  local next = current + 1
  if next > #snapshots then
    next = 1
  end
  snapshots[current], snapshots[next] = snapshots[next], snapshots[current]
  current = next
end

M.new_layout = function()
  snapshots[current] = take_snapshot(snapshots[current].name)
  current = #snapshots + 1
  vim.cmd("silent! tabonly")
  vim.cmd("silent! only")
  snapshots[current] = take_snapshot("Snapshot " .. current)
end

M.delete_layout = function(name)
  for i, snapshot in ipairs(snapshots) do
    if snapshot.name == name then
      if current == i then
        print("Cannot delete current layout")
        return
      end
      table.remove(snapshots, i)
      if current > i then
        current = current - 1
      end
      return
    end
  end
end

M.rename_layout = function(name)
  for _, snapshot in ipairs(snapshots) do
    if snapshot.name == name then
      local new_name = vim.fn.input("New name: ", name)
      if new_name ~= "" then
        snapshot.name = new_name
      end
      return
    end
  end
end

return M
