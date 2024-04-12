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

          -- mini.statusline highlight groups
          vim.cmd.highlight('MiniStatuslineModeNormal gui=bold guifg=#282c34 guibg=#98c379')
          vim.cmd.highlight('MiniStatuslineModeInsert gui=bold guifg=#282c34 guibg=#61afef')
          vim.cmd.highlight('MiniStatuslineModeVisual gui=bold guifg=#282c34 guibg=#c678dd')
          vim.cmd.highlight('MiniStatuslineModeReplace gui=bold guifg=#282c34 guibg=#e06c75')
          vim.cmd.highlight('MiniStatuslineModeCommand gui=bold guifg=#282c34 guibg=#e5c07b')
          vim.cmd.highlight('MiniStatuslineModeOther gui=bold guifg=#282c34 guibg=#56b6c2')
        end,
      })
      vim.cmd.colorscheme 'solarized'
    end,
  },
}

-- vim:sw=2:et:
