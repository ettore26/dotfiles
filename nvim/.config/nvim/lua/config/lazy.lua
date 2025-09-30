-- Lazy plugin manager config

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    error("Error cloning lazy.nvim:\n" .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require("lazy").setup(
  {
    -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
    "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

    -- NOTE: Plugins can also be added by using a table,
    -- with the first argument being the link and the following
    -- keys can be used to configure plugin behavior/loading/etc.
    --
    -- Use `opts = {}` to force a plugin to be loaded.
    --

    -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
    --
    --  Here are some example plugins that I've included in the Kickstart repository.
    --  Uncomment any of the lines below to enable them (you will need to restart nvim).
    --
    -- lang
    -- require("plugins.lang.lint"),
    require("plugins.lang.lsp-config"),
    require("plugins.lang.treesitter"),
    require("plugins.lang.conjure"),
    -- core
    require("plugins.core.oil"),
    require("plugins.core.telescope"),
    require("plugins.core.harpoon"),
    require("plugins.core.undotree"),
    require("plugins.core.git"),
    require("plugins.core.mini"),
    require("plugins.core.bufsurf"),
    -- AI
    require("plugins.extra.copilot"),
    require("plugins.extra.codecompanion"),
    -- require("plugins.extra.avante"),
    -- require("plugins.extra.claudecode"),
    require("plugins.extra.mcphub"),
    -- note taking
    require("plugins.extra.markdown"),
    require("plugins.extra.obsidian"),
    -- other
    require("plugins.extra.ui-style"),
    require("plugins.extra.autopairs"),
    require("plugins.extra.comments"),
    require("plugins.extra.which-key"),
    require("plugins.extra.hardtime"),
    require("plugins.extra.zen"),
    require("plugins.extra.aerial"),
    require("plugins.extra.snacks"),
    require("plugins.extra.kulala"),
    require("plugins.extra.vim-sexp"),
    -- tests
    -- require("plugins.test.debug"),
    -- require("plugins.test.indent_line"),
    -- require("plugins.test.lint"),
    -- require("plugins.test.neo-tree"),
    -- require("plugins.test.nvim-tree"),
    -- require("plugins.test.nerdtree"),
    -- require("plugins.test.health"),
    -- require("plugins.test.spec"),
    --

    -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
    --    This is the easiest way to modularize your config.
    --
    --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
    -- { import = 'custom.plugins' },
    --
    -- For additional information with loading, sourcing and examples see `:help lazy.nvim-🔌-plugin-spec`
    -- Or use telescope!
    -- In normal mode type `<space>sh` then write `lazy.nvim-plugin`
    -- you can continue same window with `<space>sr` which resumes last telescope search

    -- -- Configure any other settings here. See the documentation for more details.
    -- -- colorscheme that will be used when installing plugins.
    -- install = { colorscheme = { 'habamax' } },
    -- -- automatically check for plugin updates
    -- checker = { enabled = true },
  },
  ---@diagnostic disable-next-line: missing-fields
  {
    ui = {
      -- If you are using a Nerd Font: set icons to an empty table which will use the
      -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
      icons = vim.g.have_nerd_font and {} or {
        cmd = "⌘",
        config = "🛠",
        event = "📅",
        ft = "📂",
        init = "⚙",
        keys = "🗝",
        plugin = "🔌",
        runtime = "💻",
        require = "🌙",
        source = "📄",
        start = "🚀",
        task = "📌",
        lazy = "💤 ",
      },
    },
  }
)
