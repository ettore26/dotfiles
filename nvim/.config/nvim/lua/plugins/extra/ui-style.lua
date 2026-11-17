-- UI style plugins
return {
  { -- vim-lumen
    "vimpostor/vim-lumen",
  },

  { -- gruvbox
    "ellisonleao/gruvbox.nvim",
    -- dir = "~/Projects/INEEDTOGETMYPROJECTSFROMTHENVME/open-source/gruvbox.nvim",
    -- name = "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      overrides = {
        NotifyBackground = { bg = "#000000", fg = "NONE" },

        SignColumn = { bg = "NONE" },
        GruvboxYellowSign = { bg = "NONE" },
        GruvboxRedSign = { bg = "NONE" },
        GruvboxBlueSign = { bg = "NONE" },
        GruvboxAquaSign = { bg = "NONE" },
        GruvboxGreenSign = { bg = "NONE" },

        NormalFloat = { link = "NONE" },
        FloatBorder = { link = "NONE" },

        LspReferenceRead = { link = "NONE" },
        LspReferenceWrite = { link = "NONE" },
        LspReferenceText = { link = "NONE" },

        Delimiter = { link = "GruvboxFg1" },

        ["@variable"] = { link = "GruvboxFg1" },
        ["@variable.builtin"] = { link = "GruvboxFg1" },
        ["@variable.parameter"] = { link = "GruvboxFg1" },
        ["@variable.member"] = { link = "GruvboxFg1" },

        ["@function"] = { link = "GruvboxGreen" },
        ["@function.builtin"] = { link = "GruvboxAqua" },
        ["@function.call"] = { link = "GruvboxFg1" },
        ["@function.method"] = { link = "GruvboxGreen" },
        ["@function.method.call"] = { link = "GruvboxFg1" },
        ["@method"] = { link = "NONE" },

        ["@type"] = { link = "GruvboxFg1" },
        ["@type.builtin"] = { link = "GruvboxFg1" },
        ["@constant"] = { link = "GruvboxFg1" },
        ["@constant.builtin"] = { link = "GruvboxFg1" },

        ["@keyword"] = { link = "GruvboxRed" },
        ["@keyword.function"] = { link = "GruvboxRed" },
        ["@keyword.return"] = { link = "GruvboxRed" },

        ["@operator"] = { link = "GruvboxFg2" },
        ["@punctuation.delimiter"] = { link = "GruvboxFg2" },
        ["@punctuation.bracket"] = { link = "GruvboxFg2" },

        ["@string"] = { link = "GruvboxGreen" },
        ["@number"] = { link = "GruvboxFg1" },
        ["@boolean"] = { link = "GruvboxFg1" },
        ["@comment"] = { link = "GruvboxGray" },

        -- render-markdown headings: one color per level (backgrounds set in config)
        ["@markup.heading.1.markdown"] = { link = "GruvboxRedBold" },
        ["@markup.heading.2.markdown"] = { link = "GruvboxOrangeBold" },
        ["@markup.heading.3.markdown"] = { link = "GruvboxYellowBold" },
        ["@markup.heading.4.markdown"] = { link = "GruvboxGreenBold" },
        ["@markup.heading.5.markdown"] = { link = "GruvboxAquaBold" },
        -- blue looks best on dark; on light neutral_blue (#458588) looks better than gruvbox's faded blue
        ["@markup.heading.6.markdown"] = { link = "GruvboxBlueBold" },
      },
      dim_inactive = false,
      transparent_mode = false,
    },
    config = function(_, opts)
      -- render-markdown heading backgrounds: each heading color blended into Normal bg,
      -- recomputed on every load so it follows light/dark switches
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_gruvbox", {}),
        pattern = "gruvbox",
        callback = function()
          local function blend(fg, bg, alpha)
            local function channel(c, shift)
              return bit.band(bit.rshift(c, shift), 0xff)
            end
            local r = channel(fg, 16) * alpha + channel(bg, 16) * (1 - alpha)
            local g = channel(fg, 8) * alpha + channel(bg, 8) * (1 - alpha)
            local b = channel(fg, 0) * alpha + channel(bg, 0) * (1 - alpha)
            return string.format("#%02x%02x%02x", r, g, b)
          end
          local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
          for level = 1, 6 do
            local fg = vim.api.nvim_get_hl(0, { name = "@markup.heading." .. level .. ".markdown", link = false }).fg
            vim.api.nvim_set_hl(0, "RenderMarkdownH" .. level .. "Bg", { bg = blend(fg, normal_bg, 0.2) })
          end
        end,
      })
      require("gruvbox").setup(opts)
      vim.cmd("colorscheme gruvbox")
    end,
  },

  { -- tokyonight
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      on_highlights = function(hl, c)
        local prompt = "#2d3149"
        hl.TelescopeNormal = {
          bg = c.bg_dark,
          fg = c.fg_dark,
        }
        hl.TelescopeBorder = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopePromptNormal = {
          bg = prompt,
        }
        hl.TelescopePromptBorder = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePromptTitle = {
          bg = prompt,
          fg = prompt,
        }
        hl.TelescopePreviewTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
        hl.TelescopeResultsTitle = {
          bg = c.bg_dark,
          fg = c.bg_dark,
        }
      end,
    },
  },

  { -- catppuccin
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },

  { -- rose-pine
    "rose-pine/neovim",
    name = "rose-pine",
    -- config = function()
    --   vim.cmd 'colorscheme rose-pine'
    -- end,
  },

  { -- todo-comments: highlight todo, notes, etc in comments
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },

  { -- nvim-colorizer.lua
    "norcalli/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {},
  },

  { -- gruvbox-material
    "sainnhe/gruvbox-material",
    priority = 1000,
    lazy = false,
    init = function()
      vim.g.gruvbox_material_background = "medium"
      vim.g.gruvbox_material_foreground = "material"
      vim.g.gruvbox_material_ui_contrast = "low"
      vim.g.gruvbox_material_transparent_background = 0
      -- vim.g.gruvbox_material_float_style = 'bright'
      -- vim.g.gruvbox_material_sign_column_background = 'NONE'
      vim.g.gruvbox_material_enable_italic = 1
      -- vim.g.gruvbox_material_enable_bold = 1
      vim.g.gruvbox_material_better_performance = 1

      vim.cmd.colorscheme("gruvbox-material")

      vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { fg = "#318c4b" })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "Avante",
        callback = function()
          vim.api.nvim_set_hl(0, "AvanteSidebarNormal", { link = "Normal" })
          vim.api.nvim_set_hl(0, "AvanteSidebarWinSeparator", { link = "WinSeparator" })

          local normal_bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).bg)
          vim.api.nvim_set_hl(0, "AvanteSidebarWinHorizontalSeparator", { fg = normal_bg })
        end,
      })
      vim.api.nvim_create_autocmd({ "Filetype" }, {
        pattern = "harpoon",
        callback = function()
          local win_id = vim.api.nvim_get_current_win()
          vim.api.nvim_set_option_value("winblend", 0, { win = win_id })
          vim.api.nvim_set_option_value("winhighlight", "Normal:HarpoonFloat,FloatBorder:HarpoonBorder", { win = win_id })
          vim.api.nvim_set_option_value("cursorline", true, { win = win_id })
        end,
      })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("custom_highlights_gruvboxmaterial", {}),
        pattern = "gruvbox-material",
        callback = function()
          local config = vim.fn["gruvbox_material#get_configuration"]()
          local palette = vim.fn["gruvbox_material#get_palette"](config.background, config.foreground, config.colors_override)
          local set_hl = vim.fn["gruvbox_material#highlight"]

          -- seach (*) highlight
          -- set_hl('Search', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('IncSearch', palette.NONE, palette.bg_visual_red)
          -- set_hl('Search', palette.NONE, palette.bg_visual_yellow)

          -- telescope
          -- set_hl('TelescopePromptNormal', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('TelescopePromptBorder', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('TelescopeResultsNormal', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('TelescopeResultsBorder', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('TelescopePreviewNormal', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('TelescopePreviewBorder', palette.NONE, palette.bg_visual_yellow)

          -- harpoon
          -- set_hl('HarpoonBorder', palette.NONE, palette.bg_visual_yellow)
          -- set_hl('HarpoonFloat', palette.NONE, palette.bg_visual_yellow)

          -- TreeSitter highlight overrides for minimal syntax highlighting
          -- Core syntax elements - use more muted colors
          set_hl("@variable", palette.fg0, palette.NONE) -- Variables as normal text
          set_hl("@variable.builtin", palette.fg1, palette.NONE) -- Built-in variables slightly dimmed
          set_hl("@variable.parameter", palette.fg0, palette.NONE) -- Function parameters as normal text
          set_hl("@variable.member", palette.fg0, palette.NONE) -- Object properties as normal text

          -- Functions and methods - keep declarations green, calls uncolored
          set_hl("@function", palette.green, palette.NONE) -- Function declarations
          set_hl("@function.builtin", palette.aqua, palette.NONE) -- Built-in function declarations
          set_hl("@function.method", palette.green, palette.NONE) -- Method declarations
          set_hl("@function.call", palette.NONE, palette.none) -- Function calls uncolored
          set_hl("@function.method.call", palette.NONE, palette.none) -- Method calls uncolored

          -- Types and constants - use muted colors
          set_hl("@type", palette.fg1, palette.NONE) -- Types as dimmed text
          set_hl("@type.builtin", palette.fg1, palette.NONE) -- Built-in types same as custom
          set_hl("@constant", palette.fg0, palette.NONE) -- Constants as normal text
          set_hl("@constant.builtin", palette.fg1, palette.NONE) -- Built-in constants dimmed

          -- Keywords - keep some distinction but minimal
          set_hl("@keyword", palette.red, palette.NONE) -- Keep keywords red
          set_hl("@keyword.function", palette.red, palette.NONE) -- Function keywords same
          set_hl("@keyword.return", palette.red, palette.NONE) -- Return statements same

          -- Operators and punctuation - very minimal
          set_hl("@operator", palette.fg2, palette.NONE) -- Operators dimmed
          set_hl("@punctuation.delimiter", palette.fg2, palette.NONE) -- Commas, semicolons dimmed
          set_hl("@punctuation.bracket", palette.fg2, palette.NONE) -- Brackets dimmed

          -- Literals - minimal distinction
          set_hl("@string", palette.green, palette.NONE) -- Strings stay green
          set_hl("@number", palette.fg0, palette.NONE) -- Numbers as normal text
          set_hl("@boolean", palette.fg1, palette.NONE) -- Booleans dimmed

          -- Comments - keep them distinct but subtle
          set_hl("@comment", palette.gray, palette.NONE)
        end,
      })
    end,
  },
}
