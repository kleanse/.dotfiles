return {
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    cmd = "Telescope",
    dependencies = {
      { -- Fuzzy Finder Algorithm which requires local dependencies to be
        -- built. Only load if `make` is available. Make sure you have the
        -- system requirements installed.
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<Leader><Space>", "<Cmd>Telescope resume<CR>", desc = "Telescope: resume search" },
      { "<Leader>sb", "<Cmd>Telescope buffers<CR>", desc = "Telescope: search buffers" },
      { "<Leader>sc", "<Cmd>Telescope command_history<CR>", desc = "Telescope: search command history" },
      { "<Leader>sd", "<Cmd>Telescope diagnostics<CR>", desc = "Telescope: search diagnostics" },
      { "<Leader>sf", "<Cmd>Telescope find_files<CR>", desc = "Telescope: search files" },
      { "<Leader>sg", "<Cmd>Telescope live_grep<CR>", desc = "Telescope: search by grep" },
      { "<Leader>sh", "<Cmd>Telescope help_tags<CR>", desc = "Telescope: search help tags" },
      { "<Leader>sk", "<Cmd>Telescope keymaps<CR>", desc = "Telescope: search keymaps" },
      { "<Leader>sm", "<Cmd>Telescope man_pages<CR>", desc = "Telescope: search manpages" },
      { "<Leader>sr", "<Cmd>Telescope oldfiles<CR>", desc = "Telescope: search recently opened files" },
      { "<Leader>ss", "<Cmd>Telescope builtin<CR>", desc = "Telescope: search builtin pickers" },
      { "<Leader>sw", "<Cmd>Telescope grep_string<CR>", desc = "Telescope: search current word" },
      {
        "<Leader>/",
        function()
          require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
          }))
        end,
        desc = "Telescope: fuzzily search in current buffer",
      },
      {
        "<Leader>s/",
        function()
          require("telescope.builtin").live_grep({
            grep_open_files = true,
            prompt_title = "Live Grep in Open Files",
          })
        end,
        desc = "Telescope: search in open files",
      },
      {
        "<Leader>sn",
        function()
          require("telescope.builtin").find_files({
            cwd = "~/.dotfiles/dot-config/nvim",
            prompt_title = "Find Neovim Configuration Files",
          })
        end,
        desc = "Telescope: search Nvim-config files",
      },
      -- Search tracked files and list objects in the Git repository of the
      -- current working directory
      {
        "<Leader>gc",
        function()
          require("telescope.builtin").git_commits(require("telescope.themes").get_ivy({
            layout_config = { height = 0.8 },
          }))
        end,
        desc = "Telescope: Git commits",
      },
      { "<Leader>gf", "<Cmd>Telescope git_files<CR>", desc = "Telescope: search Git files" },
      {
        "<Leader>gr",
        function()
          require("telescope.builtin").git_branches({
            layout_strategy = "vertical",
            layout_config = {
              mirror = true,
              prompt_position = "top",
              preview_cutoff = 30,
            },
          })
        end,
        desc = "Telescope: Git branches",
      },
    },
    opts = function()
      -- Function to scroll the previewer of the open picker one page at a time
      local full_page_scroll = function(prompt_bufnr, direction)
        local previewer = require("telescope.actions.state").get_current_picker(prompt_bufnr).previewer
        local status = require("telescope.state").get_status(prompt_bufnr)
        -- Check if we actually have a previewer and a preview window
        if type(previewer) ~= "table" or previewer.scroll_fn == nil or status.preview_win == nil then
          return
        end
        local speed = vim.api.nvim_win_get_height(status.preview_win)
        previewer:scroll_fn(speed * direction)
      end

      return {
        defaults = {
          -- Format path as "file.txt (relative/path/to/parent)"
          path_display = function(_, path)
            local parent = require("plenary.path"):new(path):parent()
            local relpath = require("telescope.utils").transform_path({
              path_display = {},
            }, parent.filename)
            local tail = require("telescope.utils").path_tail(path)
            return string.format("%s (%s)", tail, relpath)
          end,
          mappings = {
            i = {
              ["<C-U>"] = false,
              ["<C-D>"] = false,
              ["<C-B>"] = function(bufnr)
                full_page_scroll(bufnr, -1)
              end,
              ["<C-F>"] = function(bufnr)
                full_page_scroll(bufnr, 1)
              end,
              ["<C-S>"] = "select_horizontal",
              ["<Down>"] = "cycle_history_next",
              ["<Up>"] = "cycle_history_prev",
            },
            n = {
              ["q"] = "close",
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
      pcall(telescope.load_extension, "ui-select")
    end,
  },
}
