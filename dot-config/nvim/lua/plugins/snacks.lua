return {
  { -- Collection of quality-of-life plugins for Neovim
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- stylua: ignore
      { "<C-_>", function() Snacks.terminal() end, mode = { "n", "t" }, desc = "Toggle terminal" },
    },
    opts = {
      bigfile = { enabled = true }, -- Disable LSP and Treesitter for big files (default: > 1.5 MB)
      quickfile = { enabled = true }, -- Running `nvim file` will render `file` quickly by deferring loading plugins
      styles = {
        terminal = {
          wo = { winbar = "" },
          keys = {
            term_normal = false,
          },
        },
      },
    },
  },
}
