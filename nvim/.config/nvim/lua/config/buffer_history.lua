-- buffer_history.lua
local M = {}

-- Track buffer history
local buffer_history = {}

-- Function to navigate buffer history
function M.navigate_buffer_history(direction)
  local current_buf = vim.api.nvim_get_current_buf()
  local current_index = nil

  -- Find current buffer in history
  for i, buf in ipairs(buffer_history) do
    if buf == current_buf then
      current_index = i
      break
    end
  end

  if not current_index then
    table.insert(buffer_history, current_buf)
    current_index = #buffer_history
  end

  -- Calculate target index
  local target_index = current_index + direction

  -- Check bounds and provide specific messages
  if target_index <= 0 then
    vim.notify('Already at oldest buffer in history', vim.log.levels.WARN)
    return
  elseif target_index > #buffer_history then
    vim.notify('Already at newest buffer in history', vim.log.levels.WARN)
    return
  end

  -- If we're here, target index is valid
  local target_buf = buffer_history[target_index]

  -- Check if target buffer still exists
  if vim.api.nvim_buf_is_valid(target_buf) then
    vim.api.nvim_set_current_buf(target_buf)
  else
    vim.notify 'Target buffer no longer valid, removing from history'
    table.remove(buffer_history, target_index)
    -- Try navigation again with same direction
    M.navigate_buffer_history(direction)
  end
end

-- Setup function that creates autocommands
function M.setup()
  -- Create an autocommand group
  local augroup = vim.api.nvim_create_augroup('BufferHistory', { clear = true })

  -- Add BufEnter autocmd to track buffer history
  vim.api.nvim_create_autocmd('BufEnter', {
    group = augroup,
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      local bufname = vim.api.nvim_buf_get_name(bufnr)

      -- Only track named buffers
      if bufname ~= '' and not bufname:match '^%s*$' then
        -- Remove buffer if already in history (to avoid duplicates)
        for i, buf in ipairs(buffer_history) do
          if buf == bufnr then
            table.remove(buffer_history, i)
            break
          end
        end

        -- Add current buffer to history
        table.insert(buffer_history, bufnr)
      end
    end,
  })

  -- Set up key mappings
  vim.keymap.set('n', '<A-n>', function()
    M.navigate_buffer_history(1)
  end, { desc = 'Next buffer in history' })
  vim.keymap.set('n', '<A-p>', function()
    M.navigate_buffer_history(-1)
  end, { desc = 'Previous buffer in history' })

  return M
end

return M
