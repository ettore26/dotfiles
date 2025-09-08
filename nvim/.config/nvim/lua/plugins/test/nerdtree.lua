return {
  'preservim/nerdtree',
  config = function()
    vim.g.NERDTreeWinSize = 99999
    vim.g.NERDTreeAutoDeleteBuffer = 1

    -- vim.api.nvim_create_autocmd('BufEnter', {
    --   callback = function()
    --     vim.cmd ':NERD_tree_* normal A'
    --   end,
    -- })

    function ToggleNERDTree()
      if vim.bo.filetype == 'nerdtree' then
        vim.api.nvim_command 'NERDTreeClose'
      else
        vim.api.nvim_command 'NERDTreeFind'
        vim.api.nvim_command 'only'
      end
    end
    vim.api.nvim_command 'command! ToggleNERDTree lua ToggleNERDTree()'

    vim.keymap.set('n', '<leader>e', '<cmd>ToggleNERDTree<CR>')

    -- vim.api.nvim_create_autocmd('FileType', {
    --   -- group = 'nerdtree',
    --   pattern = 'nerdtree',
    --   callback = function()
    --     vim.keymap.set('n', '<leader>e', ':NERDTreeClose<CR>', { silent = true, desc = 'Close NERDTree' })
    --     print 'netrw!!!!!!'
    --   end,
    -- })
  end,
}

-- return {
--   'SidOfc/carbon.nvim',
--   opts = {
--     -- vim.keymap.set('n', '<leader>e', ':Rexplore<CR>', { silent = true, desc = 'Toggle Netrw' }),
--     vim.keymap.set('n', '<leader>e', ':Carbon!<CR>', { silent = true, desc = 'Toggle Netrw' }),

--     -- vim.api.nvim_create_autocmd('BufWinEnter', {
--     --   callback = function()
--     --     vim.keymap.set('n', '<leader>e', ':bd<CR>', { silent = true, desc = 'Toggle Netrw' })
--     --   end,
--     -- }),
--   },
-- }
