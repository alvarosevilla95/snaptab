local M = {}

--- Recurively iterates through the node returning its expanded structure
--- @param node any
--- @return any
local function save_layout(node)
  if node[1] == "leaf" then
    return {
      type = "leaf",
      winid = node[2],
      current = node[2] == vim.api.nvim_get_current_win(),
      bufnr = vim.api.nvim_win_get_buf(node[2]),
      cursor = vim.api.nvim_win_get_cursor(node[2]),
      bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(node[2])),
      width = vim.api.nvim_win_get_width(node[2]),
      height = vim.api.nvim_win_get_height(node[2]),
    }
  else
    return { type = node[1], children = vim.tbl_map(save_layout, node[2]) }
  end
end

--- Takes a snapshot of the current layout
--- Will store the layout of each tab
--- @param name string
--- @return table
M.take_snapshot = function(name)
  local layouts = {}
  for tabnr = 1, vim.fn.tabpagenr("$") do
    layouts[tabnr] = save_layout(vim.fn.winlayout(tabnr))
  end
  return { name = name, layouts = layouts }
end

--- Returns the buffer for a given filename
--- @param filename string
--- @return number | nil
local function buffer_for_file(filename)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == filename then
      return buf
    end
  end
end

--- Opens a file or goes to the buffer if it is already open
--- @param filepath string
local function open_or_go_to_file(filepath)
  local buf = buffer_for_file(filepath)
  if buf then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.cmd("silent! edit " .. filepath)
  end
end

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

--- Restores the layout of a single tab
--- Returns the id of the focused window if it was found
--- @param layout table
--- @return number | nil
local function restore_tab(layout)
  if layout.type == "leaf" then
    open_or_go_to_file(layout.bufname)
    vim.api.nvim_win_set_cursor(0, layout.cursor)
    layout.winid = vim.api.nvim_get_current_win()
    if layout.current then
      return vim.api.nvim_get_current_win()
    end
  elseif layout.type == "col" or layout.type == "row" then
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
      local _winid = restore_tab(child)
      if _winid then
        winid = _winid
      end
    end
    vim.api.nvim_set_current_win(window)
    return winid
  end
end

--- Fully restores the layout from a snapshot
--- Will open all tabs and windows
--- @param snapshot table
M.restore_layout = function(snapshot)
  vim.cmd("silent! tabonly")
  vim.cmd("silent! only")
  local winid
  for i, tab in ipairs(snapshot.layouts) do
    if i > 1 then
      vim.cmd("tab split")
    end
    local _winid = restore_tab(tab)
    if _winid then
      winid = _winid
    end
    -- Restore sizes after all windows are open
    restore_sizes(tab)
  end
  if winid ~= nil then
    vim.api.nvim_set_current_win(winid)
  end
end

return M
