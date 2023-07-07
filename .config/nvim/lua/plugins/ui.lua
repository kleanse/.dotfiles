return {
  { -- Adds git releated signs to the gutter, as well as utilities for managing
    -- changes
    'lewis6991/gitsigns.nvim',
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function nbmap(lhs, rhs, opts)
          opts.buffer = bufnr
          vim.keymap.set('n', lhs, rhs, opts)
        end
        nbmap('<Leader>hb', gs.blame_line, { desc = '`gitsigns` blame line' })
        nbmap('<Leader>hn', gs.next_hunk, { desc = '`gitsigns` next hunk' })
        nbmap('<Leader>hp', gs.prev_hunk, { desc = '`gitsigns` prev hunk' })
        nbmap('<Leader>hv', gs.preview_hunk, { desc = '`gitsigns` preview hunk' })
        nbmap('<Leader>hr', gs.reset_hunk, { desc = '`gitsigns` reset hunk' })
        nbmap('<Leader>hs', gs.stage_hunk, { desc = '`gitsigns` stage hunk' })
        nbmap('<Leader>hu', gs.undo_stage_hunk, { desc = '`gitsigns` undo stage hunk' })
      end
    },
  },

  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help indent_blankline.txt`
    opts = {
      char = '┊',
      show_trailing_blankline_indent = false,
    },
  },
}