local open_or_go_to_file = require("neodim.utils").open_or_go_to_file
local has_plugin = require("neodim.utils").has_plugin

local M = {}

local function capture_layout(node)
  if node[1] == "leaf" then
    local layout = {
      type = "leaf",
      winid = node[2],
      current = node[2] == vim.api.nvim_get_current_win(),
      bufnr = vim.api.nvim_win_get_buf(node[2]),
      cursor = vim.api.nvim_win_get_cursor(node[2]),
      bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(node[2])),
      width = vim.api.nvim_win_get_width(node[2]),
      height = vim.api.nvim_win_get_height(node[2]),
    }
    -- store cwd for nvim-tree
    if has_plugin("nvim-tree") and string.match(layout.bufname, "NvimTree_.*") then
      layout.tree_cwd = require("nvim-tree.core").get_cwd()
    end
    return layout
  else
    return { type = node[1], children = vim.tbl_map(capture_layout, node[2]) }
  end
end

--- Takes a snapshot of the current layout
--- Will store the layout of each tab
--- @param name string
--- @return table
M.take_snapshot = function(name)
  local layouts = {}
  for tabnr = 1, vim.fn.tabpagenr("$") do
    layouts[tabnr] = capture_layout(vim.fn.winlayout(tabnr))
  end
  return { name = name, layouts = layouts, cwd = vim.fn.getcwd() }
end

--- Restores the sizes of the windows in the layout
--- Needs to be done after all windows are open
--- @param layout table
local function restore_sizes(layout)
  if layout.type == "leaf" then
    vim.api.nvim_win_set_width(layout.winid, layout.width)
    vim.api.nvim_win_set_height(layout.winid, layout.height)
  elseif layout.type == "col" or layout.type == "row" then
    for _, child in ipairs(layout.children) do
      restore_sizes(child)
    end
  end
end

local function restore_leaf(layout)
  if has_plugin("nvim-tree") and string.match(layout.bufname, "NvimTree_.*") then
    require("nvim-tree.lib").open({ path = layout.tree_cwd, current_window = true })
  else
    open_or_go_to_file(layout.bufname)
  end
  layout.winid = vim.api.nvim_get_current_win()
  pcall(vim.api.nvim_win_set_cursor, 0, layout.cursor)
  if layout.current then
    return vim.api.nvim_get_current_win()
  end
end

local function restore_node(layout)
  local window = vim.api.nvim_get_current_win()
  local winid = nil
  local opened_wins = {}
  for i, _ in ipairs(layout.children) do
    if i > 1 then
      vim.cmd(layout.type == "col" and "belowright split" or "belowright vsplit")
    end
    opened_wins[i] = vim.api.nvim_get_current_win()
  end
  for i, child in ipairs(layout.children) do
    vim.api.nvim_set_current_win(opened_wins[i])
    local _winid = M.restore_layout(child)
    if _winid then
      winid = _winid
    end
  end
  vim.api.nvim_set_current_win(window)
  return winid
end

--- Restores the layout of a single tab
--- Returns the id of the focused window if it was found
--- @param layout table
--- @return number | nil
M.restore_layout = function(layout)
  if layout.type == "leaf" then
    return restore_leaf(layout)
  else
    return restore_node(layout)
  end
end

--- Fully restores the layout from a snapshot
--- Will open all tabs and windows
--- @param snapshot table
M.restore_snapshot = function(snapshot)
  vim.cmd("silent! tabonly | only")
  vim.cmd("silent! NvimTreeClose")
  vim.cmd("cd " .. snapshot.cwd)
  local winid
  for i, layout in ipairs(snapshot.layouts) do
    if i > 1 then
      vim.cmd("tab split")
    end
    winid = M.restore_layout(layout) or winid
    -- Restore sizes after all windows are open
    restore_sizes(layout)
  end
  if winid then
    vim.api.nvim_set_current_win(winid)
  end
end

return M
