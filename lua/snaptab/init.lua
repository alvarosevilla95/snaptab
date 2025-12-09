local management = require("snaptab.management")
local session = require("snaptab.session")
local picker = require("snaptab.picker")

-- Used to save / restore the state of the plugin after calling "Lazy reload", mostly for dev purposes
if SNAPTAB_GLOBAL_CACHE then
	management.set_snapshots(SNAPTAB_GLOBAL_CACHE.snapshots)
	management.set_current(SNAPTAB_GLOBAL_CACHE.current)
end

return {
	new_snapshot = management.new_snapshot,
	next_snapshot = management.next_snapshot,
	prev_snapshot = management.prev_snapshot,
	shift_snapshot_front = management.shift_snapshot_front,
	shift_snapshot_back = management.shift_snapshot_back,
	current_snapshot = management.current_snapshot,
	rename_current_snapshot = management.rename_current_snapshot,
	serialize_state = session.serialize_state,
	restore_state = session.restore_state,
	delete_buffers_not_in_any_snapshot = management.delete_buffers_not_in_any_snapshot,
	snapshots_picker = picker.snapshots_picker,
	deactivate = function()
		SNAPTAB_GLOBAL_CACHE = {
			snapshots = management.get_snapshots(),
			current = management.get_current(),
		}
	end,
}
