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
    opts = {},
  },

  { -- LSP Configuration
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Allows extra capabilities provided by nvim-cmp
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      -- [[ Configure LSP ]]
      -- This function gets run when an LSP connects to a particular buffer;
      -- that is, when a file is opened and is associated with an LSP, this
      -- function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- NOTE: Remember that lua is a real programming language, and as
          -- such it is possible to define small helper and utility functions
          -- so you don't have to repeat yourself many times.
          --
          -- In this case, we create a function that lets us more easily define
          -- mappings specific for LSP related items. It sets the mode, buffer,
          -- and description for us each time.
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
        end,
      })

      -- nvim-cmp supports additional completion capabilities, so broadcast
      -- that to servers
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
      -- Feel free to add/remove any LSPs that you want here. They will
      -- automatically be installed.
      --
      -- Add any additional override configuration in the following tables.
      -- They will be passed to the `settings` field of the server config.
      -- You must look up that documentation yourself.
      local servers = {
        -- gopls = {},
        -- pyright = {},
        -- rust_analyzer = {},

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
            },
          },
        },
        marksman = {},
        ts_ls = {},
      }

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "markdown-toc",
        "markdownlint-cli2",
        "prettierd",
        "stylua", -- Used to format lua code
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting
            -- for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
}
