return {
  { -- Harpoon: rapid file navigation
    'ThePrimeagen/harpoon',
    config = function()
      local nmap = function(keys, func, desc)
        desc = desc and 'Harpoon: ' .. desc
        vim.keymap.set('n', keys, func, { desc = desc })
      end
      local mark = require('harpoon.mark')
      local ui = require('harpoon.ui')

      nmap('<M-m>', function() mark.add_file() end, 'mark current file')
      nmap('<M-l>', function() ui.toggle_quick_menu() end, 'toggle quick menu')
      nmap('<M-h>', function() ui.nav_file(1) end, 'edit file 1')
      nmap('<M-t>', function() ui.nav_file(2) end, 'edit file 2')
      nmap('<M-n>', function() ui.nav_file(3) end, 'edit file 3')
      nmap('<M-s>', function() ui.nav_file(4) end, 'edit file 4')
    end
  },
}

-- vim:sw=2:et:
