return {
  { -- Highlight todo, notes, etc., in comments
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    keys = {
      { "<Leader>st", "<Cmd>TodoTelescope<CR>", desc = "Search todos" },
      { "<Leader>sT", "<Cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>", desc = "Search todos that need doing" },
      Config.map.jump.lazy_keys("t", {
        next = function()
          require("todo-comments").jump_next()
        end,
        prev = function()
          require("todo-comments").jump_prev()
        end,
      }, { name = "todo comment" }),
    },
    opts = { signs = false },
  },

  { -- Add pretty icons to plugins that support them
    "echasnovski/mini.icons",
    lazy = true,
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
    opts = {
      style = vim.g.have_nerd_font and "glyph" or "ascii",
    },
  },

  { -- Status-line plugin
    "echasnovski/mini.statusline",
    opts = {
      content = {
        active = function()
          local MiniStatusline = require("mini.statusline")
          local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
          local git = MiniStatusline.section_git({ trunc_width = 75 })
          local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
          local filename = MiniStatusline.section_filename({ trunc_width = 140 })
          local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
          local location = MiniStatusline.section_location({ trunc_width = 75 })
          local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
          mode = string.upper(mode)

          return MiniStatusline.combine_groups({
            { hl = mode_hl, strings = { mode } },
            { hl = "MiniStatuslineDevinfo", strings = { git, diagnostics } },
            "%<", -- Mark general truncate point
            { hl = "MiniStatuslineFilename", strings = { filename } },
            "%=", -- End left alignment
            { hl = "MiniStatuslineFileinfo", strings = { fileinfo } },
            { hl = mode_hl, strings = { search, location } },
          })
        end,
      },
    },
  },
}
