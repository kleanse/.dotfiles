return {
  { -- Read or write files with `sudo`
    "lambdalisue/suda.vim",
  },

  { -- Library of various small independent plugins and modules
    "echasnovski/mini.nvim",
    config = function()
      -- Better Around/Inside textobjects
      --  See `:help text-objects` and `:help mini.ai`
      -- - va)     - visually select (`v`) around (`a`) parenthesis (`)`)
      -- - yinq    - yank (`y`) inside (`i`) next (`n`) quote (`q` = ["'`])
      -- - 2calf   - change (`c`) around (`a`) second (`2`) last (`l`) function
      --             call (`f`)
      -- - vanbilb - visually select around (`va`) next (`n`) block
      --             (`b` = [)]}]) then inside last block (`ilb`)
      -- - g[a     - go to (`g`) left edge (`[`) argument (`a`)
      -- - g]>     - go to (`g`) right edge (`]`) angle bracket (`>`)
      require("mini.ai").setup({ n_lines = 500 })

      -- Add/delete/replace/find/highlight surroundings (brackets, quotes,
      -- etc.)
      --  See `:help mini.surround`
      -- - saiw)       - add (`sa` [think "[S]urround [A]dd"]) for inner word
      --                 (`iw`) parenthesis (`)`) (compare `saiw(`)
      -- - sd'         - delete (`sd`) surrounding single quotes (`'`)
      -- - sr)tdiv<CR> - replace (`sr`) surrounding parenthesis (`)`) with tag
      --                 (`t`) and the identifier 'div' (`div<CR>` in command
      --                 line prompt)
      -- - shl}        - highlight (`sh`) last (`l`) brace (`}`)
      -- - 2sfnt       - find (`sf`) second (`2`) next (`n`) tag (`t`)
      require("mini.surround").setup({ respect_selection_type = true })

      -- Automatically insert and delete adjacent pairs (brackets, quotes,
      -- etc.) in Insert mode
      require("mini.pairs").setup()

      -- Register i_CTRL-H as a MiniPairs backspacing key so it can delete
      -- adjacent pairs
      vim.keymap.set("i", "<C-h>", "v:lua.MiniPairs.bs()", { expr = true, replace_keycodes = false })

      -- Evaluate, exchange, multiply, replace, and sort text
      require("mini.operators").setup()

      require("mini.statusline").setup({
        content = {
          active = function()
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
      })

      -- Split and join arguments between bracket delimiters under the cursor
      require("mini.splitjoin").setup()
    end,
  },
}
