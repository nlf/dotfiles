local Terminal = {}

function Terminal:new()
  self.buffer = nil
  self.window = nil
  self.last_window = nil

  return self
end

function Terminal:open()
  local needs_window = true
  if self.window ~= nil then
    needs_window = not vim.api.nvim_win_is_valid(self.window)
  end

  local needs_buffer = true
  if self.buffer ~= nil then
    needs_buffer = not vim.api.nvim_buf_is_valid(self.buffer)
  end

  if needs_window and needs_buffer then
    self.last_window = vim.api.nvim_get_current_win()
    vim.cmd('botright new +term')
    self.window = vim.fn.win_getid()
    self.buffer = vim.api.nvim_win_get_buf(self.window)
  elseif needs_window then
    self.last_window = vim.api.nvim_get_current_win()
    local cmd = 'botright split +buffer\\ %d'
    vim.cmd(cmd:format(self.buffer))
    self.window = vim.fn.win_getid()
  elseif needs_buffer then
    vim.api.nvim_set_current_win(self.window)
    vim.cmd('terminal')
    self.buffer = vim.api.nvim_win_get_buf(self.window)
  else
    vim.api.nvim_win_set_buf(self.window, self.buffer)
    vim.api.nvim_set_current_win(self.window)
  end

  vim.cmd('startinsert')
  vim.api.nvim_buf_set_option(self.buffer, 'buflisted', false)
end

function Terminal:close()
  if self.window ~= nil and vim.api.nvim_win_is_valid(self.window) then
    local current_window = vim.api.nvim_get_current_win()
    vim.api.nvim_win_close(self.window, false)
    if current_window == self.window then
      vim.api.nvim_set_current_win(self.last_window)
    end
  end
end

function Terminal:focus_last()
  vim.api.nvim_set_current_win(self.last_window)
end

return Terminal
