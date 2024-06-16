local management = require("neodim.management")
local session = require("neodim.session")
local telescope = require("neodim.telescope")

return {
  new_snapshot = management.new_snapshot,
  next_snapshot = management.next_snapshot,
  prev_snapshot = management.prev_snapshot,
  shift_snapshot_front = management.shift_snapshot_front,
  shift_snapshot_back = management.shift_snapshot_back,
  rename_snapshot = management.rename_snapshot,
  serialize_state = session.serialize_state,
  restore_state = session.restore_state,
  delete_buffers_not_in_any_snapshot = management.delete_buffers_not_in_any_snapshot,
  snapshots_picker = telescope.snapshots_picker,
}
