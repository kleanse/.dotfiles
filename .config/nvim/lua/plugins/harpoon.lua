return {
  { -- Harpoon: rapid file navigation
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      local nmap = function(keys, func, desc)
        desc = desc and 'Harpoon: ' .. desc
        vim.keymap.set('n', keys, func, { desc = desc })
      end

      nmap('<M-m>', function() harpoon:list():add() end, 'mark current file')
      nmap('<M-h>', function() harpoon:list():select(1) end, 'edit file 1')
      nmap('<M-t>', function() harpoon:list():select(2) end, 'edit file 2')
      nmap('<M-n>', function() harpoon:list():select(3) end, 'edit file 3')
      nmap('<M-s>', function() harpoon:list():select(4) end, 'edit file 4')

      local toggle_opts = {
        border = 'rounded',
        title_pos = 'center',
      }
      nmap('<M-l>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list(), toggle_opts)
      end, 'toggle quick menu')
    end
  },
}

-- vim:sw=2:et:
