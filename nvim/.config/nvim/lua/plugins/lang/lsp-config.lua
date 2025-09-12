-- LSP Plugins, Autoformat and Completion
return {
  { -- folke/lazydev.nvim, Lua APIs
    "folke/lazydev.nvim",
    event = "VeryLazy",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        -- Needs `LelouchHe/xmake-luals-addon` to be installed on
        --        ~/.local/share/nvim/mason/packages/lua-language-server/libexec/meta/3rd/
        { path = "${3rd}/xmake-luals-addon/library", files = { "xmake.lua" } },
      },
    },
  },

  { -- neovim/nvim-lspconfig, mason-org/mason.nvim
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { "mason-org/mason.nvim", opts = {} }, -- NOTE: Must be loaded before dependants
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
      "saghen/blink.cmp",
    },
    config = function()
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

      ---@diagnostic disable-next-line: duplicate-set-field
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "rounded"
        opts.max_width = opts.max_width or 80

        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          map("K", vim.lsp.buf.hover, "LSP Hover Reference")

          map("<leader>lD", require("telescope.builtin").lsp_type_definitions, "[L]SP Type [D]efinition")
          map("<leader>lds", require("telescope.builtin").lsp_document_symbols, "[L]SP [D]ocument [S]ymbols")
          map("<leader>lws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[L]SP [W]orkspace [S]ymbols")
          map("<leader>lr", vim.lsp.buf.rename, "[L]SP [R]ename")
          map("<leader>la", vim.lsp.buf.code_action, "[L]SP [A]ction", { "n", "x" })

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          if client and client.supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd("LspDetach", {
              group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event2.buf })
              end,
            })
          end

          if client and client.supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map("<leader>lth", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "[T]oggle Inlay [H]ints")
          end

          -- if client and client.supports_method(client, vim.lsp.protocol.Methods.ClangdSwitchSourceHeader, event.buf) then
          --   map("gh", "<cmd>ClangdSwitchSourceHeader<cr>", "[T]oggle Inlay [H]ints")
          -- end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local servers = {
        glsl_analyzer = {},
        clangd = {
          cmd = { "clangd", "--offset-encoding=utf-16" },
        },
        pyright = {},
        rust_analyzer = {},
        ts_ls = {},
        jdtls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua",
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            if server_name == "jdtls" then
              return
            end

            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
        automatic_enable = {
          exclude = {
            "jdtls",
          },
        },
      })
    end,
  },

  { -- conform.nvim, autoformat
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>lf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[L]SP [F]ormat",
      },
    },
    --- @type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.

        local disable_filetypes = {
          lua = true,
          c = true,
          cpp = true,
          markdown = true,
          sh = true,
          zsh = true,
          toml = true,
          java = true,
        }

        local filetype = vim.bo[bufnr].filetype
        if disable_filetypes[filetype] then
          return nil
        end

        return {
          timeout_ms = 500,
          lsp_format = "fallback",
        }
      end,

      formatters = {
        prettier = {
          append_args = function(self, ctx)
            if string.match(ctx.filename, "%.json[c]?$") then
              return { "--parser", "json" }
            end
            return {}
          end,
        },
      },

      formatters_by_ft = {
        lua = { "stylua" },
        cpp = { "clang-format" },
        markdown = { "prettier" },
        -- Conform can also run multiple formatters sequentially
        python = { "isort", "black" },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettier" },
        jsonc = { "prettier" },
        sh = { "shfmt" },
        zsh = { "shfmt" },
      },
    },
  },

  { -- saghen/blink.cmp, autocompletion
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
        opts = {},
      },
      "folke/lazydev.nvim",
    },
    --- @module 'blink.cmp'
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        preset = "default",
        ["<C-CR>"] = { "select_and_accept" },
        ["<C-l>"] = { "snippet_forward", "fallback" },
        ["<C-h>"] = { "snippet_backward", "fallback" },
      },

      appearance = {
        nerd_font_variant = "mono",
      },

      completion = {
        menu = {
          border = "rounded",
          winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
        },
        documentation = {
          auto_show = true,
          window = {
            border = "rounded",
          },
        },
      },

      signature = {
        enabled = true,
        window = {
          border = "rounded",
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "lazydev" },
        providers = {
          lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },

      snippets = { preset = "luasnip" },

      fuzzy = { implementation = "lua" },
    },
  },

  { -- jdtls
    require("plugins.lang.jdtls"),
  },
}
