return {
  -- LSP Plugins
  { -- `lazydev` configures Lua LSP for your Neovim config, runtime, and
    -- plugins used for completion, annotations, and signatures of Neovim
    -- APIs
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "busted-types/library", words = { "describe" } },
        { path = "luassert-types/library", words = { "assert" } },
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
        -- Load the wezterm types when the `wezterm` module is required
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },

  { "LuaCATS/busted", name = "busted-types", lazy = true },
  { "LuaCATS/luassert", name = "luassert-types", lazy = true },
  { "Bilal2453/luvit-meta", lazy = true }, -- Optional `vim.uv` typings
  { "justinsgithub/wezterm-types", lazy = true },

  { -- Package manager for Neovim to install and manage external editor tools
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    keys = {
      { "<leader>m", vim.cmd.Mason, desc = "Open Mason" },
    },
    opts = {
      ensure_installed = {
        "cmakelang",
        "cmakelint",
        "markdown-toc",
        "markdownlint-cli2",
        "prettierd",
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)

      local mr = require("mason-registry")
      mr.refresh(function()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end)
    end,
  },

  { -- LSP Configuration
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp", -- Allows extra capabilities provided by nvim-cmp
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        ---@type vim.diagnostic.Opts
        diagnostics = {
          severity_sort = true,
          signs = {
            text = {
              [vim.diagnostic.severity.ERROR] = Config.tbl.icons.diagnostics.Error,
              [vim.diagnostic.severity.HINT] = Config.tbl.icons.diagnostics.Hint,
              [vim.diagnostic.severity.INFO] = Config.tbl.icons.diagnostics.Info,
              [vim.diagnostic.severity.WARN] = Config.tbl.icons.diagnostics.Warn,
            },
          },
          virtual_text = {
            spacing = 4,
            source = "if_many",
            prefix = function(diagnostic)
              local icons = Config.tbl.icons.diagnostics
              local prefix
              for name, icon in pairs(icons) do
                if diagnostic.severity == vim.diagnostic.severity[name:upper()] then
                  prefix = icon
                  break
                end
              end
              return prefix
            end,
          },
        },
        inlay_hints = {
          exclude = { "vue" }, -- no inlay hints for these filetypes
        },
        -- LSP Server Settings
        servers = {
          clangd = {},
          lua_ls = {
            settings = {
              Lua = {
                completion = {
                  callSnippet = "Replace",
                },
                diagnostics = {
                  globals = { "vim" },
                },
                doc = {
                  privateName = { "^_" },
                },
                hint = {
                  enable = true,
                  arrayIndex = "Disable",
                  paramName = "Disable",
                  paramType = true,
                  semicolon = "Disable",
                  setType = false,
                },
                workspace = {
                  checkThirdParty = false,
                },
              },
            },
          },
          marksman = {},
          neocmake = {},
          ts_ls = {},
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      -- This function runs when a language server connects to a particular
      -- buffer, i.e., when a file is opened and is associated with a server
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local nmap = function(keys, func, desc, mode)
            desc = desc and "LSP: " .. desc
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
          end
          local builtin = require("telescope.builtin")

          nmap("gd", builtin.lsp_definitions, "go to definition")
          nmap("gR", builtin.lsp_references, "go to references")
          nmap("gI", builtin.lsp_implementations, "go to implementation")
          nmap("<Leader>D", builtin.lsp_type_definitions, "type definition")
          nmap("<Leader>ds", function()
            builtin.lsp_document_symbols({
              symbols = Config.fn.get_kind_filter(),
            })
          end, "document symbols")
          nmap("<Leader>ws", function()
            builtin.lsp_dynamic_workspace_symbols({
              symbols = Config.fn.get_kind_filter(),
            })
          end, "workspace symbols")

          nmap("<Leader>rn", vim.lsp.buf.rename, "rename")
          nmap("<Leader>ca", vim.lsp.buf.code_action, "code action", { "n", "x" })
          nmap("<C-K>", vim.lsp.buf.signature_help, "signature help")
          nmap("gD", vim.lsp.buf.declaration, "go to declaration")

          -- Inlay hints
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            if not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[event.buf].filetype) then
              vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
            end
            Config.map.toggle.set("<leader>th", {
              get = function()
                return vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf })
              end,
              set = function(state)
                vim.lsp.inlay_hint.enable(state)
              end,
            }, { name = "inlayhints", desc_name = "inlay hints", echo = true }, { buffer = event.buf })
          end
        end,
      })

      vim.diagnostic.config(opts.diagnostics)

      local servers = opts.servers
      local capabilities = vim.tbl_deep_extend(
        "force",
        vim.lsp.protocol.make_client_capabilities(),
        require("cmp_nvim_lsp").default_capabilities()
      )
      local ensure_installed = vim.tbl_keys(servers or {})
      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
        handlers = {
          -- Overrides capabilities specified by the server configuration;
          -- useful for disabling certain features of a language server (e.g.,
          -- turning off formatting for ts_ls)
          function(server_name)
            local server_opts = vim.tbl_deep_extend("force", capabilities, servers[server_name] or {})
            require("lspconfig")[server_name].setup(server_opts)
          end,
        },
      })
    end,
  },
}
