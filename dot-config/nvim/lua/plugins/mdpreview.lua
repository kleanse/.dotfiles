return {
  { -- Preview Markdown files in your browser
    "iamcco/markdown-preview.nvim",
    build = function()
      -- Load the plugin first to use the subsequent autoload function
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
    keys = {
      {
        "<Leader>tp",
        "<Plug>MarkdownPreviewToggle",
        ft = "markdown",
        desc = "MarkdownPreview: [T]oggle [P]review",
      },
    },
  },
}
