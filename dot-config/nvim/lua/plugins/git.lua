return {
  { -- Seamless Git interface in Vim
    "tpope/vim-fugitive",
    dependencies = {
      "tpope/vim-rhubarb",
    },
    init = function()
      vim.g.git_status_bufnr = -1
    end,
    config = function()
      -- [[ Configure Fugitive ]]
      --  See `:help fugitive`
      local nmap = function(keys, func, desc)
        desc = desc and "Git " .. desc
        vim.keymap.set("n", keys, func, { desc = desc })
      end

      nmap("<Leader>glg", function()
        vim.cmd("Git log --stat")
      end, "log --stat")

      nmap("<Leader>glo", function()
        vim.cmd("Git log --oneline --decorate")
      end, "log --oneline")

      nmap("<Leader>G", function()
        local window_ids = vim.fn.win_findbuf(vim.g.git_status_bufnr)
        if #window_ids ~= 0 then
          vim.fn.win_gotoid(window_ids[1])
        else
          vim.cmd("0tab Git")
          vim.g.git_status_bufnr = vim.fn.bufnr()
        end
      end, "status")

      -- Pretty print the relative author dates and author names alongside
      -- commits
      --  See `:Man git-log` under format:<format-string> in the "PRETTY
      --  FORMATS" section for details about these placeholders
      nmap("<Leader>glp", function()
        vim.cmd('Git log --graph --pretty="%Cred%h%Creset%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"')
      end, "log --pretty")
    end,
  },

  { -- Add Git-related signs to 'signcolumn' and utilities for working with
    -- hunks in buffers
    "lewis6991/gitsigns.nvim",
    opts = {
      -- See `:help gitsigns.txt`
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      signs_staged_enable = false,
      current_line_blame_opts = { delay = 0 },
      on_attach = function(bufnr)
        local function map(mode, lhs, rhs, desc)
          desc = desc and "Gitsigns: " .. desc
          vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = bufnr })
        end
        local gs = require("gitsigns")

        map("n", "<Leader>hD", function()
          gs.diffthis("@")
        end, "diff against HEAD")
        map("n", "<Leader>hR", gs.reset_buffer, "reset buffer")
        map("n", "<Leader>hS", gs.stage_buffer, "stage buffer")
        map("n", "<Leader>hb", gs.blame_line, "blame line")
        map("n", "<Leader>hd", gs.diffthis, "diff against index")
        map("n", "<Leader>hr", gs.reset_hunk, "reset hunk")
        map("n", "<Leader>hs", gs.stage_hunk, "stage hunk")
        map("n", "<Leader>hu", gs.undo_stage_hunk, "undo last stage hunk")
        map("n", "<Leader>hv", gs.preview_hunk, "preview hunk")

        map("n", "<Leader>tD", gs.toggle_deleted, "toggle show_deleted")
        map("n", "<Leader>tb", gs.toggle_current_line_blame, "toggle current_line_blame")

        -- Center the cursor in the window after jumping to a hunk in Normal
        -- mode
        Config.map.jump.set("c", {
          next = function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
              vim.cmd.normal("zz")
            end
          end,
          prev = function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
              vim.cmd.normal("zz")
            end
          end,
        }, { name = "hunk" })

        Config.map.jump.set("c", {
          next = function()
            if vim.wo.diff then
              vim.cmd.normal({ "]c", bang = true })
            else
              gs.nav_hunk("next")
            end
          end,
          prev = function()
            if vim.wo.diff then
              vim.cmd.normal({ "[c", bang = true })
            else
              gs.nav_hunk("prev")
            end
          end,
        }, { name = "hunk", mode = "x" })

        -- Mappings to stage and reset hunks in Visual mode
        map("x", "<Leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "reset hunk in selected range")

        map("x", "<Leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "stage hunk in selected range")
      end,
    },
  },
}
