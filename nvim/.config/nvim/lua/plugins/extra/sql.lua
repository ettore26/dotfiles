return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "tpope/vim-dotenv", lazy = true },
      {
        "kristijanhusak/vim-dadbod-completion",
        dependencies = { "tpope/vim-dadbod" },
        ft = { "sql", "mysql", "plsql" },
        lazy = true,
        config = function()
          -- Drop the eager FileType fetch that hits the DB on open.
          -- lazy sources the plugin (defines augroup) then runs this config,
          -- then re-fires FileType -> clearing here happens before that re-fire.
          -- Completion still works: omni() lazy-fetches on first trigger.
          -- Connection comes from b:db (.env); :DB stays untouched.
          pcall(vim.api.nvim_clear_autocmds, { group = "vim_dadbod_completion", event = "FileType" })
        end,
      },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Configure dadbod behavior
      vim.g.db_ui_use_nerd_fonts = 1
      -- .redis isn't a built-in filetype; map it so directly-opened redis query
      -- files trigger the dadbod-dir-env autocmd (b:db bind) like .sql do.
      vim.filetype.add({ extension = { redis = "redis" } })
      -- g:db_ui_save_location is set dynamically per opened .sql file -- see the
      -- "dadbod-dir-env" autocmd in lua/config/autocmds.lua. It points at the
      -- parent of the file's dir, so connection <dirname> globs its saved
      -- queries from that very dir. No hardcoded project path.
    end,
  },
}
