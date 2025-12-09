local get_current = require("snaptab.management").get_current
local get_snapshots = require("snaptab.management").get_snapshots
local open_snapshot = require("snaptab.management").open_snapshot
local delete_snapshot = require("snaptab.management").delete_snapshot
local rename_snapshot = require("snaptab.management").rename_snapshot
local has_plugin = require("snaptab.utils").has_plugin

local function snapshots_picker()
  if not has_plugin("snacks") then return end

  local snapshots = get_snapshots()
  if #snapshots == 0 then
    vim.notify("No snapshots available", vim.log.levels.INFO)
    return
  end

  local current = get_current()
  local items = {}
  for i, snapshot in ipairs(snapshots) do
    local prefix = i == current and "* " or "  "
    table.insert(items, {
      idx = i,
      text = prefix .. snapshot.name,
      name = snapshot.name,
    })
  end

  Snacks.picker({
    title = "Select a Layout",
    items = items,
    layout = "select",
    on_show = function() vim.cmd.stopinsert() end,
    format = function(item) return { { item.text } } end,
    confirm = function(picker, item)
      picker:close()
      if item then open_snapshot(item.idx) end
    end,
    actions = {
      delete = function(picker, item)
        picker:close()
        if item then delete_snapshot(item.idx) end
        vim.schedule(snapshots_picker)
      end,
      rename = function(picker, item)
        picker:close()
        if item then rename_snapshot(item.idx) end
        vim.schedule(snapshots_picker)
      end,
    },
    win = {
      input = {
        keys = {
          ["dd"] = { "delete", mode = { "n" } },
          ["r"] = { "rename", mode = { "n" } },
        },
      },
      list = {
        keys = {
          ["dd"] = { "delete", mode = { "n" } },
          ["r"] = { "rename", mode = { "n" } },
        },
      },
    },
  })
end

return {
  snapshots_picker = snapshots_picker,
}
