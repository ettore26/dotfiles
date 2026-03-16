return {
  { -- 'folke/snacks.nvim'
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      explorer = { enabled = true },
      input = { enabled = true },
      picker = {
        enabled = true,
        layout = {
          preset = "telescope",
        },
        win = {
          input = {
            keys = {
              ["<C-s>"] = { "toggle_preview", mode = { "n", "i" } },
            },
          },
        },
        sources = {
          files = {
            hidden = true,
            ignored = false,
            exclude = { "node_modules", ".git" },
          },
          grep = {
            hidden = true,
            ignored = false,
            exclude = { "node_modules", ".git" },
          },
        },
      },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      --
      words = { enabled = false },
      scope = { enabled = false },
      --
      indent = { enabled = false },
      dashboard = { enabled = false },
      notifier = { enabled = false },
      scroll = { enabled = false },
      lazygit = {},
      -- image = {},
    },
    keys = {
      -- Explorer
      { "<leader>E", function() Snacks.explorer() end, desc = "File Explorer" },
      -- Find
      { "<leader>ff", function() Snacks.picker.files() end, desc = "[F]ind [F]iles" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "[F]ind [G]rep" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "[F]ind [B]uffers" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "[F]ind [K]eymaps" },
      { "<leader>ft", function() Snacks.picker.pickers() end, desc = "[F]ind Pickers (Telescope equivalent)" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "[F]ind [W]ord current" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "[F]ind [D]iagnostics" },
      { "<leader>fr", function() Snacks.picker.resume() end, desc = "[F]ind [R]esume" },
      { "<leader>f.", function() Snacks.picker.recent() end, desc = "[F]ind Recent Files" },
      { "<leader>fq", function() Snacks.picker.qflist() end, desc = "[F]ind [Q]uickfix List" },
      { "<leader>fx", function() Snacks.picker.lsp_symbols() end, desc = "[F]ind Document Symbols" },
      { "<leader>fy", function() Snacks.picker.lsp_workspace_symbols() end, desc = "[F]ind Dynamic Workspace Symbols" },
      { "<leader>/", function() Snacks.picker.lines() end, desc = "[/] Fuzzily search in current buffer" },
      { "<leader>fF", function() Snacks.picker.files({ cwd = vim.fn.expand("%:p:h") }) end, desc = "[F]ind [F]iles Current Dir" },
      { "<leader>fi", function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = "[F]ind [I]gnored files" },
      { "<leader>f/", function() Snacks.picker.grep_buffers() end, desc = "[F]ind [/] in Open Files" },
      { "<leader>fn", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "[F]ind [N]eovim files" },
      -- Help
      { "<leader>hf", function() Snacks.picker.help() end, desc = "[H]elp Tags [F]ind" },
      { "<leader>hm", function() Snacks.picker.man() end, desc = "[H]elp [M]an Pages" },
      { "<leader>hg", function() Snacks.picker.grep({ dirs = vim.fn.globpath(vim.o.runtimepath, "doc/*", 1, 1) }) end, desc = "[H]elp Tags [Grep]" },
    },
  },
}
