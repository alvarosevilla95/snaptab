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

--- @param plugin string
local function has_plugin(plugin)
  return pcall(require, plugin)
end

return {
  open_or_go_to_file = open_or_go_to_file,
  has_plugin = has_plugin,
}
