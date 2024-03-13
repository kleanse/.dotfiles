return {
  { -- Solarized colorscheme
    'shaunsingh/solarized.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'solarized'
    end,
  },
}

-- vim:sw=2:et:
