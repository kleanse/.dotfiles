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
              ["<C-U>"] = false,
              ["<C-D>"] = false,
              ["<C-B>"] = function(bufnr)
                full_page_scroll(bufnr, -1)
              end,
              ["<C-F>"] = function(bufnr)
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
        desc = desc and "Telescope: " .. desc
        vim.keymap.set("n", keys, func, { desc = desc })
      end
      local builtin = require("telescope.builtin")
      local themes = require("telescope.themes")

      nmap("<Leader><Space>", builtin.resume, "resume search")
      nmap("<Leader>sb", builtin.buffers, "search buffers")
      nmap("<Leader>sc", builtin.command_history, "search command history")
      nmap("<Leader>sd", builtin.diagnostics, "search diagnostics")
      nmap("<Leader>sf", builtin.find_files, "search files")
      nmap("<Leader>sg", builtin.live_grep, "search by grep")
      nmap("<Leader>sh", builtin.help_tags, "search help tags")
      nmap("<Leader>sk", builtin.keymaps, "search keymaps")
      nmap("<Leader>sm", builtin.man_pages, "search manpages")
      nmap("<Leader>sr", builtin.oldfiles, "search recently opened files")
      nmap("<Leader>ss", builtin.builtin, "search builtin pickers")
      nmap("<Leader>sw", builtin.grep_string, "search current word")

      nmap("<Leader>/", function()
        -- You can pass additional configuration to telescope to change theme,
        -- layout, etc.
        builtin.current_buffer_fuzzy_find(themes.get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, "fuzzily search in current buffer")

      -- Shortcut for searching your Neovim configuration files
      nmap("<Leader>sn", function()
        builtin.find_files({
          cwd = "~/.dotfiles/dot-config/nvim",
          prompt_title = "Find Neovim Configuration Files",
        })
      end, "search Nvim-config files")

      nmap("<Leader>s/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, "search in open files")

      -- Search tracked files and list objects in the Git repository of the
      -- current working directory
      nmap("<Leader>gf", builtin.git_files, "search Git files")

      nmap("<Leader>gc", function()
        builtin.git_commits(themes.get_ivy({
          layout_config = { height = 0.8 },
        }))
      end, "Git commits")

      nmap("<Leader>gb", function()
        builtin.git_branches({
          layout_strategy = "vertical",
          layout_config = {
            mirror = true,
            prompt_position = "top",
            preview_cutoff = 30,
          },
        })
      end, "Git branches")
    end,
  },
}
