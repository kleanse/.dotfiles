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
        signs = { add = "+", change = "~", delete = "-" },
      },
    },
  },

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

      nmap("<Leader>gbl", function()
        vim.cmd("Git blame --date=relative")
      end, "blame --date=relative")

      nmap("<Leader>G", function()
        local window_ids = vim.fn.win_findbuf(vim.g.git_status_bufnr)
        if #window_ids ~= 0 then
          vim.fn.win_gotoid(window_ids[1])
          vim.cmd.edit()
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
}
