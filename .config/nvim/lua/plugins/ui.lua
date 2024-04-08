return {
  { -- Highlight todo, notes, etc in comments
    'folke/todo-comments.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    opts = {
      signs = false,
    },
  },

  { -- Add pretty icons to plugins supporting them
    'nvim-tree/nvim-web-devicons',
    enabled = vim.g.have_nerd_font, -- requires a Nerd Font
  },
}

-- vim:sw=2:et:
