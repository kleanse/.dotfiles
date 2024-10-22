return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "[F]ormat buffer",
      },
      {
        "<leader>tf",
        function()
          vim.g.format_on_save = not vim.g.format_on_save
          local prefix = vim.g.format_on_save and string.rep(" ", 2) or "no"
          vim.api.nvim_echo({ { prefix .. "format" } }, false, {})
        end,
        desc = "[T]oggle [F]ormat on save",
      },
    },
    init = function()
      vim.g.format_on_save = true
    end,
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- Conform will run multiple formatters sequentially
        python = { "isort", "black" },
        -- Conform will run the first available formatter
        javascript = { "prettierd", "prettier", stop_after_first = true },
        tex = { "latexindent" },
      },
      format_on_save = function(bufnr)
        -- Disable autoformat on certain filetypes
        local ignore_filetypes = { "c", "cpp" }
        if vim.g.format_on_save and not vim.tbl_contains(ignore_filetypes, vim.bo[bufnr].filetype) then
          return { timeout_ms = 500, lsp_format = "fallback" }
        end
      end,
      -- Custom formatters and changes to built-in formatters
      formatters = {
        latexindent = {
          args = { "-m" },
        },
      },
    },
  },
}
