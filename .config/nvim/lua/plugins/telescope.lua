return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',

      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more
        --       instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },

      'nvim-telescope/telescope-ui-select.nvim',
    },
    config = function()
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
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

      require('telescope').setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
              ['<C-b>'] = function(bufnr) full_page_scroll(bufnr, -1) end,
              ['<C-f>'] = function(bufnr) full_page_scroll(bufnr, 1) end,
            },
          },
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable telescope extensions, if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local nmap = function(keys, func, desc)
        vim.keymap.set('n', keys, func, { desc = desc })
      end
      local builtin = require 'telescope.builtin'

      nmap('<leader><space>', builtin.buffers, '[ ] Find existing buffers')
      nmap('<leader>?', builtin.oldfiles, '[?] Find recently opened files')
      nmap('<leader>sd', builtin.diagnostics, '[S]earch [D]iagnostics')
      nmap('<leader>sf', builtin.find_files, '[S]earch [F]iles')
      nmap('<leader>sg', builtin.live_grep, '[S]earch by [G]rep')
      nmap('<leader>sh', builtin.help_tags, '[S]earch [H]elp')
      nmap('<leader>sk', builtin.keymaps, '[S]earch [K]eymaps')
      nmap('<leader>sr', builtin.resume, '[S]earch [R]esume')
      nmap('<leader>sw', builtin.grep_string, '[S]earch current [W]ord')

      nmap('<leader>/', function()
        -- You can pass additional configuration to telescope to change theme,
        -- layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, '[/] Fuzzily search in current buffer')

      -- Shortcut for searching your Neovim configuration files
      nmap('<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, '[S]earch [N]eovim files')
    end
  },
}

-- vim:sw=2:et:
