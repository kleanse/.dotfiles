return {
  { -- Autoformat
    "stevearc/conform.nvim",
    config = function()
      vim.g.format_on_save = true

      require("conform").setup({
        formatters_by_ft = {
          lua = { "stylua" },
          -- Conform will run multiple formatters sequentially
          python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          javascript = { { "prettierd", "prettier" } },
        },
        format_on_save = function(bufnr)
          -- Disable autoformat on certain filetypes
          local ignore_filetypes = { "c", "cpp" }
          if vim.g.format_on_save and not vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
            return { timeout_ms = 500, lsp_fallback = true }
          end
        end,
      })

      local nmap = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = desc })
      end

      nmap("<leader>f", function()
        require("conform").format({ async = true, lsp_fallback = true })
      end, "[F]ormat buffer")

      nmap("<leader>tf", function()
        vim.g.format_on_save = not vim.g.format_on_save
        local prefix = vim.g.format_on_save and string.rep(" ", 2) or "no"
        vim.api.nvim_echo({ { prefix .. "format" } }, false, {})
      end, "[T]oggle [F]ormat on save")
    end,
  },
}

-- vim:sw=2:et:
