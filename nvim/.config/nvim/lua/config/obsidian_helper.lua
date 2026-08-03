local M = {}

--- Discover per-org note vaults instead of hardcoding them: every
--- `~/<org>/Documents/notes` directory becomes a workspace named after `<org>`,
--- e.g. `~/Weedmaps/Documents/notes` -> `weedmaps`.
---
--- Called from obsidian.nvim's `opts` table, so the glob runs once when
--- lazy.nvim sources the spec at startup: a newly created org notes dir is
--- picked up on the next nvim restart.
---
---@return table[] workspaces obsidian.nvim workspace specs
function M.discover_workspaces()
  local workspaces = {
    -- Keep first: obsidian.nvim falls back to `workspaces[1]` when the cwd
    -- doesn't resolve to any workspace, and requires at least one to exist.
    {
      name = "personal",
      path = "~/Documents/notes",
    },
  }

  -- Exactly one level below `~/`; org dirs are never searched for any deeper.
  local pattern = vim.fs.joinpath(vim.fn.expand("~"), "*", "Documents", "notes")
  for _, path in ipairs(vim.fn.glob(pattern, true, true)) do
    -- obsidian.nvim only checks that the path exists, so filter out plain files.
    if vim.fn.isdirectory(path) == 1 then
      -- ~/Weedmaps/Documents/notes -> Weedmaps -> weedmaps
      local org = vim.fs.basename(vim.fs.dirname(vim.fs.dirname(path)))
      table.insert(workspaces, {
        -- Explicit: without it every workspace would be named after its own
        -- basename, i.e. all of them 'notes'.
        name = org:lower(),
        path = path,
        -- Pin the root to `notes/` instead of walking up for a parent `.obsidian/`.
        strict = true,
      })
    end
  end

  return workspaces
end

return M
