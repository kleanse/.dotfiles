return {
  { -- Seamless Git interface in Vim
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-rhubarb',
    },
    config = function()
      -- [[ Configure Fugitive ]]
      -- See `:help fugitive`
      local nmap = function(keys, func, desc)
        desc = desc and '[G]it ' .. desc
        vim.keymap.set('n', keys, func, { desc = desc })
      end

      nmap('<leader>glg', function() vim.cmd('Git log') end, '[L]o[g]')
      nmap('<leader>glo', function() vim.cmd('Git log --oneline --decorate') end, '[L]og --[o]neline')

      -- Pretty print the relative author dates and author names alongside
      -- commits
      -- See `:Man git-log` under format:<format-string> in the "PRETTY
      -- FORMATS" section for details about these placeholders
      nmap('<leader>glp', function()
        vim.cmd('Git log --graph --pretty="%Cred%h%Creset%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"')
      end, '[L]og --[p]retty')
    end
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing
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
}

-- vim:sw=2:et:
