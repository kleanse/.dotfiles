return {
  { -- Autoformat
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<Leader>f",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        desc = "[F]ormat buffer",
      },
      {
        "<Leader>tf",
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
        markdown = { "prettierd", "markdownlint-cli2", "markdown-toc", "trim_newlines" },
        python = { "isort", "black" }, -- Run multiple formatters sequentially
        tex = { "latexindent" },
      },
      format_on_save = function(bufnr)
        -- Disable autoformatting with LSP for languages that do not have a
        -- well standardized coding style
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt = disable_filetypes[vim.bo[bufnr].filetype] and "never" or "fallback"
        if vim.g.format_on_save then
          return { timeout_ms = 3000, lsp_format = lsp_format_opt }
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
        ["markdown-toc"] = {
          condition = function(_, ctx)
            for _, line in ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find("<!-- toc -->", nil, true) then
                return true
              end
            end
          end,
        },
        ["markdownlint-cli2"] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(function(d)
              return d.source == "markdownlint"
            end, vim.diagnostic.get(ctx.buf))
            return #diag > 0
          end,
        },
      },
    },
  },
}
