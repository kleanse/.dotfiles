return {
  { -- Fuzzy Finder (files, lsp, etc)
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",

      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more
        --       instructions.
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },

      "nvim-telescope/telescope-ui-select.nvim",
    },
    config = function()
      -- [[ Configure Telescope ]]
      --  See `:help telescope` and `:help telescope.setup()`
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

      require("telescope").setup({
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
              ["<C-u>"] = false,
              ["<C-d>"] = false,
              ["<C-b>"] = function(bufnr)
                full_page_scroll(bufnr, -1)
              end,
              ["<C-f>"] = function(bufnr)
                full_page_scroll(bufnr, 1)
              end,
            },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
      })

      -- Enable telescope extensions, if they are installed
      pcall(require("telescope").load_extension, "fzf")
      pcall(require("telescope").load_extension, "ui-select")

      local nmap = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { desc = desc })
      end
      local builtin = require("telescope.builtin")
      local themes = require("telescope.themes")

      nmap("<leader><space>", builtin.resume, "[ ] Search resume")
      nmap("<leader>sb", builtin.buffers, "[S]earch [B]uffers")
      nmap("<leader>sc", builtin.command_history, "[S]earch [C]ommand history")
      nmap("<leader>sd", builtin.diagnostics, "[S]earch [D]iagnostics")
      nmap("<leader>sf", builtin.find_files, "[S]earch [F]iles")
      nmap("<leader>sg", builtin.live_grep, "[S]earch by [G]rep")
      nmap("<leader>sh", builtin.help_tags, "[S]earch [H]elp")
      nmap("<leader>sk", builtin.keymaps, "[S]earch [K]eymaps")
      nmap("<leader>sm", builtin.man_pages, "[S]earch [M]anpages")
      nmap("<leader>sr", builtin.oldfiles, "[S]earch [R]ecently opened files")
      nmap("<leader>ss", builtin.builtin, "[S]earch [S]elect Telescope")
      nmap("<leader>sw", builtin.grep_string, "[S]earch current [W]ord")

      nmap("<leader>/", function()
        -- You can pass additional configuration to telescope to change theme,
        -- layout, etc.
        builtin.current_buffer_fuzzy_find(themes.get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, "[/] Fuzzily search in current buffer")

      -- Shortcut for searching your Neovim configuration files
      nmap("<leader>sn", function()
        builtin.find_files({
          cwd = vim.fn.stdpath("config"),
          prompt_title = "Find Neovim Configuration Files",
        })
      end, "[S]earch [N]eovim files")

      nmap("<leader>so", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, "[S]earch in [O]pen files")

      -- Search tracked files and list objects in the Git repository of the
      -- current working directory
      nmap("<leader>gf", builtin.git_files, "Search [G]it [F]iles")

      nmap("<leader>gc", function()
        builtin.git_commits(themes.get_ivy({
          layout_config = { height = 0.8 },
        }))
      end, "[G]it [C]ommits")

      nmap("<leader>gb", function()
        builtin.git_branches({
          layout_strategy = "vertical",
          layout_config = {
            mirror = true,
            prompt_position = "top",
            preview_cutoff = 30,
          },
        })
      end, "[G]it [B]ranches")
    end,
  },
}
