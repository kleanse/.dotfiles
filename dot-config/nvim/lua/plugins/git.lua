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
        desc = desc and "[G]it " .. desc
        vim.keymap.set("n", keys, func, { desc = desc })
      end

      nmap("<leader>glg", function()
        vim.cmd("Git log --stat")
      end, "[L]o[g]")

      nmap("<leader>glo", function()
        vim.cmd("Git log --oneline --decorate")
      end, "[L]og --[o]neline")

      nmap("<leader>G", function()
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
      nmap("<leader>glp", function()
        vim.cmd('Git log --graph --pretty="%Cred%h%Creset%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"')
      end, "[L]og --[p]retty")
    end,
  },

  { -- Adds git related signs to the gutter, as well as utilities for managing
    -- changes
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

        map("n", "<leader>hD", function()
          gs.diffthis("@")
        end, "[H]unk [D]iff against HEAD")
        map("n", "<leader>hR", gs.reset_buffer, "[H]unk [R]eset buffer")
        map("n", "<leader>hS", gs.stage_buffer, "[H]unk [S]tage buffer")
        map("n", "<leader>hb", gs.blame_line, "[H]unk [B]lame line")
        map("n", "<leader>hd", gs.diffthis, "[H]unk [D]iff against index")
        map("n", "<leader>hr", gs.reset_hunk, "[H]unk [R]eset")
        map("n", "<leader>hs", gs.stage_hunk, "[H]unk [S]tage")
        map("n", "<leader>hu", gs.undo_stage_hunk, "[H]unk [U]ndo stage")
        map("n", "<leader>hv", gs.preview_hunk, "[H]unk [V]iew")

        map("n", "<leader>t_", gs.toggle_deleted, "[T]oggle show [D]eleted")
        map("n", "<leader>tb", gs.toggle_current_line_blame, "[T]oggle current line [B]lame")

        -- Center the cursor in the window after jumping to a hunk in Normal
        -- mode
        map("n", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
            vim.cmd.normal("zz")
          end
        end, "[H]unk [N]ext")

        map("n", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
            vim.cmd.normal("zz")
          end
        end, "[H]unk [P]rev")

        map("x", "]c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "[H]unk [N]ext")

        map("x", "[c", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "[H]unk [P]rev")

        -- Mappings to stage and reset hunks in Visual mode
        map("x", "<leader>hr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "[H]unk [R]eset selected range")

        map("x", "<leader>hs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "[H]unk [S]tage selected range")
      end,
    },
  },
}
