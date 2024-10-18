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
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = { { name = "notes", path = "$PKM_REPO" } },
      mappings = {
        -- Toggle check-boxes.
        ["<leader>u"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { desc = "Obsidian: toggle checkbox", buffer = true },
        },
        -- Smart action depending on context: follow link or toggle checkbox
        ["<cr>"] = {
          action = function()
            return require("obsidian").util.smart_action()
          end,
          opts = { desc = "Obsidian: smart action", buffer = true, expr = true },
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
    config = function(_, opts)
      local obsidian = require("obsidian")
      obsidian.setup(opts)

      vim.api.nvim_create_autocmd("BufEnter", {
        group = "obsidian_setup",
        pattern = "*.md",
        callback = function(ev)
          -- Check if we're in *any* workspace.
          if not obsidian.Workspace.get_workspace_for_dir(vim.fs.dirname(ev.match), opts.workspaces) then
            return
          end

          vim.keymap.set("n", "<C-]>", function()
            return obsidian.util.cursor_on_markdown_link() and "<Cmd>ObsidianFollowLink<CR>" or "<C-]>"
          end, { desc = "Obsidian: follow link", buffer = true, expr = true })
        end,
      })
    end,
  },
}
