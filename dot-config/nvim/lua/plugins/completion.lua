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
      "saadparwaiz1/cmp_luasnip", -- L3MON4D3/LuaSnip completion source for nvim-cmp
    },
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
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
          format = function(_, vim_item)
            local icons = Config.tbl.icons.kinds
            if icons[vim_item.kind] then
              vim_item.kind = icons[vim_item.kind] .. vim_item.kind
            end
            local widths = {
              abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
              menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
            }
            for key, width in pairs(widths) do
              if vim_item[key] and vim.fn.strdisplaywidth(vim_item[key]) > width then
                vim_item[key] = vim.fn.strcharpart(vim_item[key], 0, width - 1) .. "…"
              end
            end
            return vim_item
          end,
        },
      }
    end,
  },
}
