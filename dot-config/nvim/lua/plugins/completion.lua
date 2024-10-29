return {
  { -- Autocompletion
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      -- Plugins that extend the pool of sources for nvim-cmp to use for
      -- completion
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",

      { -- Snippet engine for creating, expanding, and jumping to the dynamic
        -- fields of short, reusable pieces of source code
        "L3MON4D3/LuaSnip",
        build = (function()
          -- This build step is needed for regex support in snippets, which is
          -- not supported in many Windows environments
          -- Remove the below condition to re-enable on Windows
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
      },

      -- L3MON4D3/LuaSnip completion source for nvim-cmp
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      luasnip.config.setup({})

      return {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        preselect = cmp.PreselectMode.Item,
        mapping = cmp.mapping.preset.insert({
          ["<C-B>"] = cmp.mapping.scroll_docs(-4),
          ["<C-E>"] = cmp.mapping.abort(),
          ["<C-F>"] = cmp.mapping.scroll_docs(4),
          ["<C-N>"] = cmp.mapping.select_next_item(),
          ["<C-P>"] = cmp.mapping.select_prev_item(),
          ["<C-Y>"] = cmp.mapping.confirm({ select = true }),

          -- Mnemonic: ":rightbelow" (j), ":leftabove" (k)
          ["<M-j>"] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { "i", "s" }),
          ["<M-k>"] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "lazydev" },
        }, {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "path" },
          { name = "buffer", keyword_length = 5 },
        }),
        formatting = {
          expandable_indicator = true,
          fields = { "abbr", "kind", "menu" },
          format = function(entry, vim_item)
            vim_item.menu = ({
              buffer = "[buf]",
              lazydev = "[lazydev]",
              luasnip = "[snip]",
              nvim_lsp = "[LSP]",
              path = "[path]",
            })[entry.source.name]
            return vim_item
          end,
        },
      }
    end,
  },
}
