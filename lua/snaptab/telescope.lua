local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local sorters = require("telescope.sorters")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local get_current = require("snaptab.management").get_current
local get_snapshots = require("snaptab.management").get_snapshots
local open_snapshot = require("snaptab.management").open_snapshot
local delete_snapshot = require("snaptab.management").delete_snapshot
local rename_snapshot = require("snaptab.management").rename_snapshot
local has_plugin = require("snaptab.utils").has_plugin

local function snapshots_picker()
  if not has_plugin("telescope") then
    return
  end
  pickers
    .new(require("telescope.themes").get_dropdown({}), {
      layout_config = {
        width = 0.5,
        height = 0.2,
      },
      initial_mode = "normal",
      prompt_title = "Select a Layout",
      default_selection_index = get_current(),
      finder = finders.new_table({
        results = get_snapshots(),
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.name,
            ordinal = entry.name,
            name = entry.name,
          }
        end,
      }),
      sorter = sorters.get_generic_fuzzy_sorter(),
      attach_mappings = function(prompt_bufnr, map)
        local function enter_handler()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            open_snapshot(selection.index)
          end
        end

        local function delete_handler()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            delete_snapshot(selection.index)
          end
          snapshots_picker()
        end

        local function rename_handler()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            rename_snapshot(selection.index)
          end
          snapshots_picker()
        end

        map("i", "<CR>", enter_handler)
        map("n", "<CR>", enter_handler)
        map("n", "dd", delete_handler)
        map("n", "r", rename_handler)

        return true
      end,
    })
    :find()
end

return {
  snapshots_picker = snapshots_picker,
}
