return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    opts = {
      -- [[ Configure Treesitter ]]
      --  See `:help nvim-treesitter`
      -- Add languages to be installed here that you want installed for
      -- treesitter
      ensure_installed = { "bash", "c", "cpp", "lua", "markdown", "vim", "vimdoc" },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<c-space>",
          node_incremental = "<c-space>",
          scope_incremental = "<c-s>",
          node_decremental = "<M-space>",
        },
      },
    },
  },
}
