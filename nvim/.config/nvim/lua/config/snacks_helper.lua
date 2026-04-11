local M = {}

function M.pick_and_paste_path()
  local was_insert = vim.fn.mode():sub(1, 1) == "i"
  Snacks.picker.files({
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      local rel = vim.fn.fnamemodify(item.file, ":.")
      vim.schedule(function()
        vim.api.nvim_put({ rel }, "c", true, true)
        if was_insert then
          vim.cmd("startinsert")
        end
      end)
    end,
  })
end

return M
