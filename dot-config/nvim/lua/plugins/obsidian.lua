return {
  { -- Write notes and navigate in Obsidian vaults
    "epwalsh/obsidian.nvim",
    version = "*",
    event = {
      -- If you want to use the home shortcut '~' here you need to call
      -- 'vim.fn.expand', e.g.,
      --     "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
      --  See `:h file-pattern` for more examples
      -- stylua: ignore
      "BufReadPre " .. vim.fn.expand("$PKM_REPO") .. "/*.md",
      "BufNewFile " .. vim.fn.expand("$PKM_REPO") .. "/*.md",
    },
    keys = {
      { -- Open picker to select a note from defined workspaces
        "<leader>sp",
        function()
          return "<Cmd>ObsidianQuickSwitch<CR>"
        end,
        desc = "Obsidian: quick switch",
        expr = true,
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = { { name = "notes", path = "$PKM_REPO" } },
      mappings = {
        -- Follow link
        ["<C-]>"] = {
          action = function()
            return require("obsidian").util.cursor_on_markdown_link() and "<Cmd>ObsidianFollowLink<CR>" or "<C-]>"
          end,
          opts = { desc = "Obsidian: follow link", buffer = true, expr = true },
        },
        -- Toggle check-boxes
        ["<leader>u"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { desc = "Obsidian: toggle checkbox", buffer = true },
        },
        -- Smart action depending on context: follow link or toggle checkbox
        ["<CR>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { desc = "Obsidian: smart action", buffer = true, expr = true },
        },
        -- Open picker with list of references to the current buffer
        ["<leader>ob"] = {
          action = function()
            return "<Cmd>ObsidianBacklinks<CR>"
          end,
          opts = { desc = "[O]bsidian [B]acklinks", buffer = true, expr = true },
        },
      },
      -- Disable special syntax highlighting using 'conceallevel'
      ui = {
        enable = false,
        -- Use only two types of checkboxes
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "󰄲", hl_group = "ObsidianDone" },
        },
      },
    },
  },
}
