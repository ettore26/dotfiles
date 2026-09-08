return {
  "mistweaverco/kulala.nvim",
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  --- @module 'kulala'
  --- @type KulalaDefaultConfig
  --- kulala declares its config fields as required; `opts` is a partial override.
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    global_keymaps = true,
    global_keymaps_prefix = "<leader>R",
    kulala_keymaps_prefix = "",
    script_console_notify = false,
  },
  config = function(_, opts)
    require("kulala").setup(opts)
    -- Reshapes "Copy as cURL" (<leader>Rc) into a pasteable multi-line command
    require("config.kulala_curl").patch_copy()

    -- `g?` (show news) throws E344 upstream: kulala 3209abf deleted NEWS.md and
    -- docs/, but ui.show_news still reads NEWS.md and `lcd`s into docs/docs.
    -- The news moved into the help files, so send the keymap there instead.
    -- Remove once upstream fixes show_news.
    require("kulala.ui").show_news = function()
      vim.cmd("help kulala.NEWS.txt")
    end
  end,
}
