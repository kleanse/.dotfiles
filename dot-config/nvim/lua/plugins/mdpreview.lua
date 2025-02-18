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
        "<Leader>tm",
        "<Plug>MarkdownPreviewToggle",
        ft = "markdown",
        desc = "Toggle MarkdownPreview",
      },
    },
    init = function()
      vim.g.mkdp_auto_close = 0
    end,
    config = function()
      vim.cmd.doautocmd("FileType")
    end,
  },
}
