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
}

-- vim:sw=2:et:
