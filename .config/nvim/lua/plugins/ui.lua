return {
  { -- Set lualine as status line
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

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
