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
        c = { "clang-format" },
        cpp = { "clang-format" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
        python = { "isort", "black" }, -- Run multiple formatters sequentially
        tex = { "latexindent" },
      },
      format_on_save = function(bufnr)
        -- Disable autoformatting with LSP for languages that do not have a
        -- well standardized coding style
        local disable_filetypes = { "c", "cpp" }
        local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback"
        if vim.g.format_on_save then
          return { timeout_ms = 500, lsp_format = lsp_format_opt }
        end
      end,
      -- Custom formatters and changes to built-in formatters
      formatters = {
        ["clang-format"] = {
          args = { "--style=file" },
        },
        latexindent = {
          args = { "-m" },
        },
      },
    },
  },
}
