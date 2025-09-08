-- Netrw configuration
-- Check this: https://www.reddit.com/r/neovim/comments/1dc78r4/custom_netrw_workflow_settings_maps_etc/
-- Check treview help: https://superuser.com/questions/1531456/how-to-reveal-a-file-in-vim-netrw-treeview
-- Check neovim config with netrw: https://www.roguelazer.com/blog/2019-vim-setup/

function ToggleNetRW()
  if vim.bo.filetype == 'netrw' then
    vim.api.nvim_command 'Rex'
    if vim.bo.filetype == 'netrw' then
      vim.api.nvim_command 'bdel'
    end
  else
    vim.api.nvim_command 'Ex'
  end
end
vim.api.nvim_command 'command! ToggleNetRW lua ToggleNetRW()'

-- makes dir the current
vim.g.netrw_keepdir = 0
-- vim.g.netrw_banner = 0
-- vim.g.netrw_liststyle = 3
vim.g.netrw_fastbrowse = 2
-- vim.g.netrw_bufsettings = 'nonu nornu noma ro nobl'
vim.g.netrw_bufsettings = 'noma nomod ro nobl nu rnu nowrap'
vim.g.netrw_browse_split = 0 -- (4 to open in other window)
vim.g.netrw_altfile = 0 -- (4 to open in other window)
-- vim.g.netrw_list_hide = '^\\.\\.\\?/$,\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
-- vim.g.netrw_list_hide = '^..//'
-- vim.g.netrw_list_hide = '^\\.\\.\\/'

-- vim.g.netrw_maxfilenamelen = 320

-- Keybinds to open Netrw file explorer
-- vim.keymap.set('n', '<leader>e', ':Explore $PWD<CR>', { desc = 'Toggle Netrw' })
-- vim.keymap.set('n', '<leader>e', ':Explore<CR>', { silent = true, desc = 'Toggle Netrw' })
-- vim.keymap.set('n', '<leader>e', ':Rexplore<CR>', { silent = true, desc = 'Toggle Netrw' })

-- Highlights opened buffer
-- vim.keymap.set('n', '<Leader>ex', '<cmd>Ex <bar> :sil! /<C-R>=expand("%:t")<CR><CR>')
-- vim.keymap.set('n', '<Leader>ex', '<cmd>Ex <bar> :sil! call search(expand("#:t"))<CR>')

-- vim.keymap.set('n', '<Leader>ex', '<cmd>:let @/=expand("%:t") <Bar> execute \'Explore\' expand("%:h") <Bar> normal n<CR>')
-- vim.keymap.set(
--   'n',
--   '<Leader>ex',
--   "<cmd>:let @/='\\<' . escape(expand(\"%:t\"), '.[]*~$/\\\\') . '\\>' <Bar> execute 'Explore' expand(\"%:h\") <Bar> normal n<CR>"
-- )

-- vim.keymap.set('n', '<Leader>ex', function()
--   -- Set search pattern with word boundaries
--   vim.fn.setreg('/', '\\<' .. vim.fn.escape(vim.fn.expand '%:t', '.[]*~$/\\') .. '\\>')

--   -- Explore the directory of the current file
--   vim.cmd('Explore ' .. vim.fn.expand '%:h')

--   -- Jump to the next match and center the screen
--   vim.cmd 'normal! n'
--   vim.cmd 'normal! zz'
-- end, { desc = 'Explore and highlight current file' })

vim.g.netrw_liststyle = 3
vim.keymap.set('n', '<leader>e', function()
  local relative_path = vim.fn.expand '%:h'
  -- local filename = vim.fn.expand '%:t'
  local filename = '\\<' .. vim.fn.escape(vim.fn.expand '%:t', '.[]*~$/\\') .. '\\>'

  -- Determine if we need to use root or relative path
  if string.sub(relative_path, 1, 1) == '/' then
    relative_path = '.'
  end

  -- Store the filename in the search register
  vim.fn.setreg('/', filename)

  -- Open netrw at the relative path
  vim.cmd('Lexplore ' .. relative_path)
  -- vim.cmd('Explore ' .. relative_path)

  -- Count how many directory levels we need to navigate up
  local levels = 0
  local path_copy = relative_path
  local pos = 0

  while true do
    pos = string.find(path_copy, '/', pos and pos + 1 or 1)
    if not pos then
      break
    end
    levels = levels + 1
  end

  -- Navigate up the directory structure
  for i = 1, levels + 1 do
    vim.cmd "call netrw#Call('NetrwBrowseUpDir', 1)"
  end

  -- Search for the file and center the screen
  vim.cmd 'normal! n'
  vim.cmd 'normal! zz'
end)

vim.api.nvim_create_augroup('netrw', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  group = 'netrw',
  pattern = 'netrw',
  callback = function()
    -- print 'netrw!!!!!!'
    -- vim.opt_local.bufhidden = 'wipe'
    vim.api.nvim_command 'setlocal buftype=nofile'
    vim.api.nvim_command 'setlocal bufhidden=wipe'

    -- vim.api.nvim_command ''
    -- vim.opt_local.winbar = '%!v:lua.WinBarNetRW()'
    -- vim.keymap.set('n', '<C-C>', '<CMD>ToggleNetRW<CR>', { noremap = true, silent = true, buffer = true })
    -- vim.keymap.set('n', '<esc>', '<CMD>ToggleNetRW<CR>', { noremap = true, silent = true, buffer = true })
    -- vim.keymap.set('n', 'e', '<CMD>Ex ~<CR>', { remap = true, silent = true, buffer = true })
    -- vim.keymap.set('n', 'w', '<CMD>Ex ' .. vim.fn.getcwd() .. '<CR>', { remap = true, silent = true, buffer = true })
    -- vim.keymap.set('n', '<BS>', '-', { remap = true, silent = true, buffer = true })
    -- vim.keymap.set('n', 'r', 'R', { remap = true, silent = true, buffer = true })

    local unbinds = {
      'a',
      '<F1>',
      '<del>',
      '<c-h>',
      '<c-r>',
      '<c-tab>',
      'C',
      'gb',
      'gd',
      'gf',
      'gn',
      'gp',
      'i',
      'I',
      'mb',
      'mc',
      'md',
      'me',
      'mf',
      'mF',
      'mg',
      'mh',
      'mm',
      'mr',
      'mt',
      'mT',
      'mu',
      'mv',
      'mx',
      'mX',
      'mz',
      'o',
      'O',
      'p',
      'P',
      'qb',
      'qf',
      'qF',
      'qL',
      's',
      'S',
      't',
      'u',
      'U',
      'v',
      'x',
      'X',
    }
    -- for _, value in pairs(unbinds) do
    --   vim.keymap.set('n', value, '<CMD>lua print("Keybind \'' .. value .. '\' has been removed")<CR>', { noremap = true, silent = true, buffer = true })
    -- end
  end,
})

local function Path()
  -- local path = vim.fn.expand('%:~:.') -- Relative
  local path = vim.fn.expand '%:~' -- Absolute
  return '%#StatusLine# ' .. path
end

WinBarNetRW = function()
  return table.concat {
    Path(),
    '%=',
    ' NETRW ',
    '%<',
  }
end

-- Netrw configuration old
-- vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
-- -- vim.g.netrw_liststyle = 3
-- vim.g.netrw_altfile = 1
-- vim.g.netrw_fastbrowse = 0
-- -- vim.api.nvim_create_autocmd('VimEnter', { command = 'clearjumps' })
-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function()
--     -- vim.opt_local.bufhidden = 'unload'
--     -- vim.opt_local.bufhidden = 'delete'
--     vim.opt_local.bufhidden = 'wipe'
--     vim.cmd 'clearjumps'
--   end,
-- })
-- -- vim.api.nvim_create_autocmd('FileType', {
-- --   pattern = { 'netrw' },
-- --   callback = function()
-- --     -- vim.opt_local.bufhidden = 'unload'
-- --     -- vim.opt_local.bufhidden = 'delete'
-- --     vim.opt_local.bufhidden = 'wipe'
-- --     -- vim.cmd 'clearjumps'
-- --   end,
-- -- })

-- TODO : check how to make Netrw take project path when `vim ./path/path`
--        to pass that path to Telescope and jdtls
-- lua vim.print(vim.w.netrw_treetop)
-- let l:pathUnderCursor=netrw#Call('NetrwTreePath', w:netrw_treetop)

-- TODO: read about this config to alternate insde Netrw:
-- https://www.reddit.com/r/vim/comments/2vfb8o/comment/coxggu0/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
