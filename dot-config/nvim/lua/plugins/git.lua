return {
  { -- Add Git-related signs to 'signcolumn' and utilities for working with
    -- hunks in buffers
    "echasnovski/mini.diff",
    event = "VeryLazy",
    keys = {
      {
        "<leader>ty",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
    opts = {
      view = {
        style = "sign",
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniDiffUpdated",
        callback = function(data)
          local summary = vim.b[data.buf].minidiff_summary
          if summary == nil then
            return
          end
          local t = {}
          if summary.add > 0 then
            t[#t + 1] = Config.tbl.icons.git.add .. summary.add
          end
          if summary.change > 0 then
            t[#t + 1] = Config.tbl.icons.git.change .. summary.change
          end
          if summary.delete > 0 then
            t[#t + 1] = Config.tbl.icons.git.delete .. summary.delete
          end
          vim.b[data.buf].minidiff_summary_string = table.concat(t, " ")
        end,
      })
    end,
  },

  { -- Seamless Git interface in Vim
    "tpope/vim-fugitive",
    dependencies = {
      "tpope/vim-rhubarb",
    },
    cmd = "Git",
    keys = {
      {
        "<Leader>G",
        function()
          local window_ids = vim.fn.win_findbuf(vim.g.git_status_bufnr)
          if #window_ids ~= 0 then
            vim.fn.win_gotoid(window_ids[1])
            vim.cmd.edit()
          else
            vim.cmd("0tab Git")
            vim.g.git_status_bufnr = vim.fn.bufnr()
          end
        end,
        desc = "Fugitive: Git status",
      },
      -- stylua: ignore start
      { "<Leader>gbl", function() vim.cmd("Git blame --date=relative") end, desc = "Fugitive: Git blame" },
      { "<Leader>glg", function() vim.cmd("Git log --stat") end, desc = "Fugitive: Git log --stat" },
      { "<Leader>glo", function() vim.cmd("Git log --oneline --decorate") end, desc = "Fugitive: Git log --oneline" },
      -- stylua: ignore end
      { -- Pretty print the relative author dates and author names alongside
        -- commits
        --  See `:Man git-log` under format:<format-string> in the "PRETTY
        --  FORMATS" section for details about these placeholders
        "<Leader>glp",
        function()
          vim.cmd(
            'Git log --graph --pretty="%Cred%h%Creset%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset"'
          )
        end,
        desc = "Fugitive: log --pretty",
      },
    },
    init = function()
      vim.g.git_status_bufnr = -1
    end,
  },
}
