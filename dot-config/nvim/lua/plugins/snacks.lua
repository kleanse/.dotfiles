return {
  { -- Collection of quality-of-life plugins for Neovim
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    -- stylua: ignore
    keys = {
      { "<C-_>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Toggle terminal" },
      { "<Leader>Rn", function() Snacks.rename.rename_file() end, desc = "Rename file" },
      { "<Leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
      { "<Leader>o",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
    },
    opts = {
      bigfile = { enabled = true }, -- Disable LSP and Treesitter for big files (default: > 1.5 MB)
      quickfile = { enabled = true }, -- Running `nvim file` will render `file` quickly by deferring loading plugins
      zen = {
        toggles = {
          dim = true,
          git_signs = false,
          mini_diff_signs = false,
          diagnostics = false,
          inlay_hints = false,
        },
        on_open = function()
          vim.g.format_on_write = false
          vim.opt.ruler = false
          vim.opt.showcmd = false
          -- Run `tmux set status on` in the shell if the status line does not
          -- return, e.g., when exiting Zen Mode with ":qall"
          vim.system({ "tmux", "set", "status", "off" })
        end,
        on_close = function()
          vim.g.format_on_write = true
          vim.opt.ruler = true
          vim.opt.showcmd = true
          vim.system({ "tmux", "set", "status", "on" })
        end,
        zoom = {
          toggles = { dim = false, diagnostics = true },
          show = { statusline = true, tabline = false },
        },
      },
      styles = {
        terminal = {
          wo = { winbar = "" },
          keys = {
            term_normal = false,
          },
        },
        zen = {
          width = 80,
          backdrop = { transparent = false },
          wo = {
            colorcolumn = "",
            list = false,
            signcolumn = "no",
            spell = false,
          },
        },
      },
    },
  },
}
