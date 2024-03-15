return {
  { -- Solarized colorscheme
    'shaunsingh/solarized.nvim',
    priority = 1000,
    config = function()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('highlight-colorscheme', { clear = true }),
        pattern = 'solarized',
        callback = function()
          vim.cmd.highlight('clear IncSearch')
          vim.cmd.highlight('clear Search')
          vim.cmd.highlight('IncSearch cterm=standout gui=standout guifg=#cb4b16')
          vim.cmd.highlight('Search cterm=reverse gui=reverse guifg=#b58900')
        end,
      })
      vim.cmd.colorscheme 'solarized'
    end,
  },
}

-- vim:sw=2:et:
