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
    local children = {}
    for i, child in ipairs(node[2]) do
      children[i] = save_layout(child)
    end
    return {
      type = node[1],
      children = children,
    }
  end
end

local function take_snapshot(name)
  local snapshot = { name = name }
  for tabnr = 1, vim.fn.tabpagenr("$") do
    local layout = save_layout(vim.fn.winlayout(tabnr))
    snapshot[tabnr] = layout
  end
  return snapshot
end

local function open_or_go_to_file(filepath)
  local function buffer_for_file(filename)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) then
        if vim.api.nvim_buf_get_name(buf) == filename then
          return buf
        end
      end
    end
    return nil
  end

  local buf = buffer_for_file(filepath)
  if buf then
    vim.api.nvim_set_current_buf(buf)
  else
    vim.cmd("silent! edit " .. filepath)
  end
end

local function restore_tab(layout)
  if layout.type == "leaf" then
    open_or_go_to_file(layout.bufname)
    vim.api.nvim_win_set_cursor(0, layout.cursor)
    if layout.current then
      return vim.api.nvim_get_current_win()
    end
    -- vim.api.nvim_win_set_width(0, layout.width)
    -- vim.api.nvim_win_set_height(0, layout.height)
  elseif layout.type == "col" or layout.type == "row" then
    local window = vim.api.nvim_get_current_win()
    for i, child in ipairs(layout.children) do
      if i > 1 then
        vim.cmd(layout.type == "col" and "belowright split" or "belowright vsplit")
      end
      restore_tab(child)
    end
    vim.api.nvim_set_current_win(window)
  end
end

local function restore_layout(snapshot)
  vim.cmd("silent! tabonly")
  vim.cmd("silent! only")
  local winid
  for i, tab in ipairs(snapshot) do
    if i > 1 then
      vim.cmd("tab split")
    end
    local _winid = restore_tab(tab)
    if _winid then
      winid = _winid
    end
  end
  vim.api.nvim_set_current_win(winid)
end
