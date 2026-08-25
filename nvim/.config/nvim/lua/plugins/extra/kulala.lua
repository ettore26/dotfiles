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
  end,
}
