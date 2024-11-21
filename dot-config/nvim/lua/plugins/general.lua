return {
  { -- "gc" to comment visual regions/lines
    "numToStr/Comment.nvim",
    event = "VeryLazy",
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
    event = "VeryLazy",
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

  { -- Evaluate, exchange, multiply, replace, and sort text
    "echasnovski/mini.operators",
    event = "VeryLazy",
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
      Config.map.toggle.lazy_keys("<Leader>tp", {
        get = function()
          return not vim.g.minipairs_disable
        end,
        set = function(state)
          vim.g.minipairs_disable = not state
        end,
      }, { name = "minipairs", desc_name = "mini.pairs", echo = true }),
    },
    opts = {
      modes = { insert = true, command = true, terminal = false },
      -- skip autopair when the next character is in this character class
      skip_next = [=[[%w%"%$%%%'%.%[%`]]=],
      -- skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },
      -- skip autopair when the next character is the closing character of a
      -- pair and there are more closing characters of that pair than opening
      -- characters
      skip_unbalanced = true,
      -- support for Markdown code blocks
      markdown = true,
    },
    config = function(_, opts)
      Config.mini.pairs(opts)
    end,
  },

  { -- Read, write, and delete global and local sessions
    "echasnovski/mini.sessions",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local ms = require("mini.sessions")
      ms.setup(opts)

      -- Commands to interact with mini.sessions functions conveniently
      local complete = Config.mini.complete_session_names
      vim.api.nvim_create_user_command("SessionRead", function(cmd)
        local force = cmd.bang or nil -- fall back to config.force.read
        local session_name = cmd.args ~= "" and cmd.args or nil
        ms.read(session_name, { force = force })
      end, {
        bang = true,
        desc = "MiniSessions.read()",
        nargs = "?",
        complete = complete,
      })
      vim.api.nvim_create_user_command("SessionWrite", function(cmd)
        local force = cmd.bang or nil -- fall back to config.force.write
        local session_name = cmd.args ~= "" and cmd.args or nil
        ms.write(session_name, { force = force })
      end, {
        bang = true,
        desc = "MiniSessions.write()",
        nargs = "?",
        complete = complete,
      })
      vim.api.nvim_create_user_command("SessionDelete", function(cmd)
        local force = cmd.bang or nil -- fall back to config.force.delete
        if cmd.args == "" then
          Config.mini.delete_session(nil, { force = force })
          return
        end
        local session_names ---@type string[]
        if cmd.args == "*" then
          ---@param v table
          session_names = vim.tbl_map(function(v)
            return v.name
          end, vim.tbl_values(ms.detected))
        else
          session_names = cmd.fargs
        end
        for _, name in ipairs(session_names) do
          Config.mini.delete_session(name, { force = force })
        end
      end, {
        bang = true,
        desc = "MiniSessions.delete()",
        nargs = "*",
        complete = function(ArgLead)
          local results ---@type string[]
          if ArgLead == "*" then
            ---@param v table
            local session_names = vim.tbl_map(function(v)
              return vim.fn.escape(v.name, " ")
            end, vim.tbl_values(ms.detected))
            results = { table.concat(session_names, " ") }
          else
            results = complete(vim.fn.expandcmd(ArgLead))
            ---@param name string
            results = vim.tbl_map(function(name)
              return vim.fn.escape(name, " ")
            end, results)
          end
          return results
        end,
      })
    end,
  },

  { -- Split and join arguments between bracket delimiters under the cursor
    "echasnovski/mini.splitjoin",
    event = "VeryLazy",
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
    event = "VeryLazy",
    opts = { respect_selection_type = true },
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
