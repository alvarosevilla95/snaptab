local has_plugin = require("snaptab.utils").has_plugin

local function snapshots_picker()
  if has_plugin("snacks") then
    require("snaptab.picker.snacks").snapshots_picker()
  elseif has_plugin("telescope") then
    require("snaptab.picker.telescope").snapshots_picker()
  else
    require("snaptab.picker.select").snapshots_picker()
  end
end

return {
  snapshots_picker = snapshots_picker,
}
