local get_current = require("snaptab.management").get_current
local get_snapshots = require("snaptab.management").get_snapshots
local open_snapshot = require("snaptab.management").open_snapshot
local delete_snapshot = require("snaptab.management").delete_snapshot
local rename_snapshot = require("snaptab.management").rename_snapshot

local function snapshots_picker()
  local snapshots = get_snapshots()
  if #snapshots == 0 then
    vim.notify("No snapshots available", vim.log.levels.INFO)
    return
  end

  local current = get_current()
  local items = {}
  for i, snapshot in ipairs(snapshots) do
    local prefix = i == current and "* " or "  "
    table.insert(items, { index = i, name = snapshot.name, display = prefix .. snapshot.name })
  end

  vim.ui.select(items, {
    prompt = "Select a Layout:",
    format_item = function(item) return item.display end,
  }, function(selected)
    if not selected then return end

    vim.ui.select({ "Open", "Rename", "Delete" }, {
      prompt = selected.name .. ":",
    }, function(action)
      if action == "Open" then
        open_snapshot(selected.index)
      elseif action == "Rename" then
        rename_snapshot(selected.index)
      elseif action == "Delete" then
        delete_snapshot(selected.index)
      end
    end)
  end)
end

return {
  snapshots_picker = snapshots_picker,
}

