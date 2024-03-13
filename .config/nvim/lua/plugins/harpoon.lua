return {
  -- Harpoon: rapid file navigation
  {
    'ThePrimeagen/harpoon',
    config = function()
      local harpmark = require('harpoon.mark')
      local harpui = require('harpoon.ui')

      vim.keymap.set('n', '<M-m>', function() harpmark.add_file() end, { desc = '`harpoon` mark current file' })
      vim.keymap.set('n', '<M-l>', function() harpui.toggle_quick_menu() end, { desc = '`harpoon` toggle quick menu' })

      vim.keymap.set('n', '<M-h>', function() harpui.nav_file(1) end, { desc = '`harpoon` edit file 1' })
      vim.keymap.set('n', '<M-t>', function() harpui.nav_file(2) end, { desc = '`harpoon` edit file 2' })
      vim.keymap.set('n', '<M-n>', function() harpui.nav_file(3) end, { desc = '`harpoon` edit file 3' })
      vim.keymap.set('n', '<M-s>', function() harpui.nav_file(4) end, { desc = '`harpoon` edit file 4' })
    end
  },
}

-- vim:sw=2:et:
