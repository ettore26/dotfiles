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
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function()
      -- Scratchpad notes live in the current directory. Root = parent of cwd,
      -- used only as the persistence fallback below.
      local root_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":h")
      -- persistence.json (connections): search upward from the opened note's dir,
      -- so it's picked up whether it sits beside the note, in a parent, or at root.
      -- Fall back to the root when none found.
      local start = vim.fn.expand("%:p:h")
      if start == "" then
        start = vim.fn.getcwd()
      end
      local found = vim.fn.findfile("persistence.json", start .. ";")
      local persistence = found ~= "" and vim.fn.fnamemodify(found, ":p") or (root_dir .. "/persistence.json")
      require("dbee").setup({
        sources = {
          -- require("dbee.sources").MemorySource:new({
          --   {
          --     name = "DB from env",
          --     type = "postgres",
          --     url = "postgres://usrdev:x4P8aBPqzbhlLR0@psql-tuefectivo-des-eastus2-02.postgres.database.azure.com:5432/tu_efectivo?sslmode=require",
          --   },
          -- }),
          -- require("dbee.sources").EnvSource:new("DBEE_CONNECTIONS"),
          require("dbee.sources").FileSource:new(persistence),
        },
        editor = {
          directory = vim.fn.getcwd(),
        },
      })
    end,
  },
}
