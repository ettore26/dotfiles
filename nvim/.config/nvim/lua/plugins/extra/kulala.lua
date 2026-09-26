return {
  "mistweaverco/kulala.nvim",
  keys = {
    { "<leader>Rs", desc = "Send request" },
    { "<leader>Rq", desc = "Interrupt requests" },
    { "<leader>Ra", desc = "Send all requests" },
    { "<leader>Rb", desc = "Open scratchpad" },
  },
  ft = { "http", "rest" },
  --- @module 'kulala'
  --- @type KulalaDefaultConfig
  --- kulala declares its config fields as required; `opts` is a partial override.
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    -- Custom entries replace same-named defaults whole (`false` disables one)
    -- and are NOT prefixed, so spell out the full lhs, action and ft.
    --
    -- <C-c> stays the global "close buffer/split" (config/keymaps.lua)
    -- everywhere, the kulala_ui response split included; interrupting moves
    -- to <leader>Rq in both the .http buffer and the response split.
    global_keymaps = {
      -- Default <leader>Rq; dropped to free the key for interrupting
      ["Close window"] = false,
      ["Interrupt requests"] = {
        "<leader>Rq",
        function()
          require("kulala.ui").interrupt_requests()
        end,
        ft = { "http", "rest" },
      },
    },
    kulala_keymaps = {
      -- Default <C-c>, which would shadow the global close in the response split.
      -- Each press cancels the newest pending request, then the running one.
      ["Interrupt requests"] = {
        "<leader>Rq",
        function()
          require("kulala.ui").interrupt_requests()
        end,
        desc = "Interrupt requests / close WS connection",
        prefix = false,
      },
      -- Global <C-n>/<C-p> cycle buffers; don't let them swap one into the response split
      ["Disable next buffer"] = { "<C-n>", "<Nop>", prefix = false },
      ["Disable previous buffer"] = { "<C-p>", "<Nop>", prefix = false },
    },
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
