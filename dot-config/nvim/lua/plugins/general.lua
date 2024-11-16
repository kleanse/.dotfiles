return {
  { -- "gc" to comment visual regions/lines
    "numToStr/Comment.nvim",
    opts = {},
  },

  { -- Navigate to tagged files quickly
    "cbochs/grapple.nvim",
    keys = {
      { "<M-m>", "<Cmd>Grapple toggle<CR>", desc = "Grapple: tag current file" },
      { "<M-l>", "<Cmd>Grapple toggle_tags<CR>", desc = "Grapple: toggle tag menu" },
      { "<M-h>", "<Cmd>Grapple select index=1<CR>", desc = "Grapple: select first tag" },
      { "<M-t>", "<Cmd>Grapple select index=2<CR>", desc = "Grapple: select second tag" },
      { "<M-n>", "<Cmd>Grapple select index=3<CR>", desc = "Grapple: select third tag" },
      { "<M-s>", "<Cmd>Grapple select index=4<CR>", desc = "Grapple: select fourth tag" },
      Config.map.jump.lazy_keys(
        "g",
        { next = "<Cmd>Grapple cycle_scopes next<CR>", prev = "<Cmd>Grapple cycle_scopes prev<CR>" },
        { next_desc = "Grapple: cycle to the next scope", prev_desc = "Grapple: cycle to the previous scope" }
      ),
    },
  },

  { -- Better Around/Inside textobjects
    --  See `:help text-objects` and `:help mini.ai`
    -- - va)     - visually select (`v`) around (`a`) parenthesis (`)`)
    -- - yinq    - yank (`y`) inside (`i`) next (`n`) quote (`q` = ["'`])
    -- - 2calf   - change (`c`) around (`a`) second (`2`) last (`l`) function
    --             call (`f`)
    -- - vanbilb - visually select around (`va`) next (`n`) block
    --             (`b` = [)]}]) then inside last block (`ilb`)
    -- - g[a     - go to (`g`) left edge (`[`) argument (`a`)
    -- - g]>     - go to (`g`) right edge (`]`) angle bracket (`>`)
    "echasnovski/mini.ai",
    opts = function()
      local gen_ai_spec = require("mini.extra").gen_ai_spec
      local gen_spec = require("mini.ai").gen_spec
      return {
        n_lines = 500,
        custom_textobjects = {
          o = gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          d = gen_ai_spec.number(), -- number
          e = { -- word with camel case support
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          i = gen_ai_spec.indent(), -- indent
          G = gen_ai_spec.buffer(), -- buffer
          u = gen_spec.function_call(), -- function call
          U = gen_spec.function_call({ name_pattern = "[%w_]" }), -- function call but no dot in function name (for `a`)
        },
      }
    end,
  },

  -- Extra functionalities for mini.ai, mini.hipatterns, and mini.pick
  { "echasnovski/mini.extra", lazy = true, opts = {} },

  { -- Evaluate, exchange, multiply, replace, and sort text
    "echasnovski/mini.operators",
    opts = {},
  },

  { -- Automatically insert and delete adjacent pairs (brackets, quotes,
    -- etc.) in Insert mode
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    keys = {
      -- Register i_CTRL-H as a MiniPairs backspacing key so it can delete
      -- adjacent pairs
      { "<C-H>", "v:lua.MiniPairs.bs()", mode = "!", expr = true, replace_keycodes = false },
    },
    opts = {
      modes = { insert = true, command = true, terminal = false },
    },
  },

  { -- Split and join arguments between bracket delimiters under the cursor
    "echasnovski/mini.splitjoin",
    opts = {},
  },

  { -- Add/delete/replace/find/highlight surroundings (brackets, quotes,
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
    "echasnovski/mini.surround",
    opts = { respect_selection_type = true },
  },

  { -- Read or write files with `sudo`
    "lambdalisue/suda.vim",
  },

  { -- Edit buffers in a minimal window to maintain focus
    "folke/zen-mode.nvim",
    keys = { { "<Leader>z", "<Cmd>ZenMode<CR>", desc = "Toggle Zen Mode" } },
    opts = {
      window = {
        width = 80,
        options = {
          colorcolumn = "",
          list = false,
          signcolumn = "no",
          spell = false,
        },
      },
      plugins = {
        -- Enable Zen-Mode plugins to disable their corresponding plugins in
        -- Zen Mode
        gitsigns = { enabled = true },
        -- Run `tmux set status on` in the shell if the status line does not
        -- return, e.g., when exiting Zen Mode with ":qall"
        tmux = { enabled = true }, -- tmux status line
      },
      on_open = function()
        vim.g.format_on_save = false
        vim.diagnostic.enable(false)
      end,
      on_close = function()
        vim.g.format_on_save = true
        vim.diagnostic.enable(true)
      end,
    },
  },
}
