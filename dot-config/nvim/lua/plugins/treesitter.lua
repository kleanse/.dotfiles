return {
  { -- Highlight, edit, and navigate code
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs",
    event = "VeryLazy",
    opts = {
      -- [[ Configure Treesitter ]]
      --  See `:help nvim-treesitter`
      -- Add languages to be installed here that you want installed for
      -- treesitter
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "html",
        "javascript",
        "lua",
        "markdown",
        "python",
        "vim",
        "vimdoc",
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-Space>",
          node_incremental = "<C-Space>",
          scope_incremental = "<C-S>",
          node_decremental = "<M-Space>",
        },
      },
    },
  },

  { -- Select textobjects using treesitter
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
  },
}
