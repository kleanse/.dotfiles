return {
  { -- gruvbox color scheme
    'ellisonleao/gruvbox.nvim',
    priority = 1000,
    config = function()
      require('gruvbox').setup {
        overrides = {
          GruvboxAquaUnderline   = { fg='#427b58' },
          GruvboxBlueUnderline   = { fg='#076678' },
          GruvboxGreenUnderline  = { fg='#79740e' },
          GruvboxOrangeUnderline = { fg='#af3a03' },
          GruvboxPurpleUnderline = { fg='#8f3f71' },
          GruvboxRedUnderline    = { fg='#9d0006' },
          GruvboxYellowUnderline = { fg='#b57614' },

          GruvboxAquaUnderlineItalic   = { undercurl=true, italic=true, fg='#427b58', sp='#427b58' },
          GruvboxBlueUnderlineItalic   = { undercurl=true, italic=true, fg='#076678', sp='#076678' },
          GruvboxGreenUnderlineItalic  = { undercurl=true, italic=true, fg='#79740e', sp='#79740e' },
          GruvboxOrangeUnderlineItalic = { undercurl=true, italic=true, fg='#af3a03', sp='#af3a03' },
          GruvboxPurpleUnderlineItalic = { undercurl=true, italic=true, fg='#8f3f71', sp='#8f3f71' },
          GruvboxRedUnderlineItalic    = { undercurl=true, italic=true, fg='#9d0006', sp='#9d0006' },
          GruvboxYellowUnderlineItalic = { undercurl=true, italic=true, fg='#b57614', sp='#b57614' },

          SpellBad   = { link='GruvboxRedUnderlineItalic' },
          SpellCap   = { link='GruvboxBlueUnderlineItalic' },
          SpellRare  = { link='GruvboxPurpleUnderlineItalic' },
          SpellLocal = { link='GruvboxAquaUnderlineItalic' },
        },
      }

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('highlight-colorscheme', { clear = true }),
        pattern = 'gruvbox',
        callback = function()
          -- mini.statusline highlight groups
          vim.cmd.highlight('MiniStatuslineModeNormal  gui=bold guifg=#fbf1c7 guibg=#928374')
          vim.cmd.highlight('MiniStatuslineModeInsert  gui=bold guifg=#fbf1c7 guibg=#076678')
          vim.cmd.highlight('MiniStatuslineModeVisual  gui=bold guifg=#fbf1c7 guibg=#8f3f71')
          vim.cmd.highlight('MiniStatuslineModeReplace gui=bold guifg=#fbf1c7 guibg=#9d0006')
          vim.cmd.highlight('MiniStatuslineModeCommand gui=bold guifg=#fbf1c7 guibg=#b57614')
          vim.cmd.highlight('MiniStatuslineModeOther   gui=bold guifg=#fbf1c7 guibg=#79740e')
        end,
      })

      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}

-- vim:sw=2:et:
