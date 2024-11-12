-- Set "," as the leader key
--  See `:help mapleader`
-- NOTE: Must happen before plugins are required (otherwise, wrong leader will
-- be used)
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Use a dark color scheme
vim.g.dark_mode = false

-- Set to true if you have installed and are using a Nerd Font
vim.g.have_nerd_font = true

-- Directory containing template files
vim.g.template_path = "~/.templates"

-- Remove trailing whitespace and blank lines at the start and end when writing
-- the current buffer
vim.g.trim_blanks_on_write = true

-- Enable dark mode if operating system's appearance is dark mode
if
  vim.uv.os_uname().sysname == "Darwin"
  and vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }):wait().stdout == "Dark\n"
then
  vim.g.dark_mode = true
end

-- [[ Set options, key mappings, and autocommands ]]
require("config.autocmds")
require("config.keymaps")
require("config.options")

-- [[ Install `lazy.nvim` plugin manager ]]
-- https://github.com/folke/lazy.nvim
--  See `:help lazy.nvim.txt` for more info
require("config.lazy")

-- [[ Functions ]]

-- Pretty prints a Lua object.
function P(object)
  print(vim.inspect(object))
  return object
end

local get_icon
if _G.MiniIcons then
  -- Prefer 'mini.icons'
  get_icon = function(name)
    return (_G.MiniIcons.get("file", name))
  end
else
  -- Try falling back to 'nvim-web-devicons'
  local has_devicons, devicons = pcall(require, "nvim-web-devicons")
  if has_devicons then
    -- Use basename because it makes exact file name matching work
    get_icon = function(name)
      return (devicons.get_icon(vim.fn.fnamemodify(name, ":t"), nil, { default = true }))
    end
  end
end

-- Builds a custom format for 'tabline' that is based on the default format
-- produced by `draw_tabline()` in the Nvim source code.
function Tabline()
  local s = ""
  local col = 0
  local columns = vim.api.nvim_get_option_value("columns", {})
  local tabpages = vim.api.nvim_list_tabpages()

  for tabnr, tabpage in ipairs(tabpages) do
    if col >= columns - 4 then
      break
    end

    local startcol = col

    local bufnrlist = vim.fn.tabpagebuflist(tabnr)
    local winnr = vim.api.nvim_win_get_number(vim.api.nvim_tabpage_get_win(tabpage))
    local bufname = vim.api.nvim_buf_get_name(bufnrlist[winnr])

    -- Highlight current tab page
    local hlgroup = "%#TabLine#"
    if tabpage == vim.api.nvim_get_current_tabpage() then
      hlgroup = "%#TabLineSel#"
    end
    s = s .. hlgroup

    -- Set tab page number (for mouse clicks)
    s = s .. "%" .. tabnr .. "T"

    s = s .. " "
    col = col + 1

    local modified = false
    for _, bufnr in ipairs(bufnrlist) do
      if vim.api.nvim_get_option_value("modified", { buf = bufnr }) then
        modified = true
        break
      end
    end

    local wincount = #vim.api.nvim_tabpage_list_wins(tabpage)
    if modified or wincount > 1 then
      if wincount > 1 then
        local len = #string.format("%d", wincount)
        if col + len >= columns - 3 then
          break
        end
        s = s .. "%#GruvboxTabLineTitle#" .. wincount .. hlgroup
        col = col + len
      end
      if modified then
        s = s .. "+"
        col = col + 1
      end
      s = s .. " "
      col = col + 1
    end

    if get_icon then
      s = s .. get_icon(bufname)
      s = s .. " "
      col = col + 2
    end

    -- Set tab page label
    local tabwidth = math.max(#tabpages > 0 and math.floor((columns - 1 + #tabpages / 2) / #tabpages) or 0, 6)
    local room = startcol - col + tabwidth - 1
    if room > 0 then
      local trbufname = bufname ~= "" and vim.fn.fnamemodify(bufname, ":t") or "[No Name]"
      if trbufname == "" then
        trbufname = "[Temp]"
      end
      trbufname = string.sub(trbufname, -room)
      s = s .. trbufname
      col = col + #trbufname
    end
    s = s .. " "
    col = col + 1
  end

  s = s .. "%#TabLineFill#%T"

  local showcmd = vim.api.nvim_get_option_value("showcmd", {})
  local showcmdloc = vim.api.nvim_get_option_value("showcmdloc", {})
  if showcmd and showcmdloc == "tabline" then
    local sc_width = math.min(10, columns - col - (#tabpages > 1 and 3 or 0))
    if sc_width > 0 then
      s = s .. string.rep(" ", columns - sc_width - (#tabpages > 1 and 2 or 0) - col)
      s = s .. "%#TabLine#%S%#TabLineFill#"
    end
  end

  -- Right-align the label to close the current tab page
  if #tabpages > 1 then
    s = s .. "%=%#TabLine#%999XX"
  end

  return s
end

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim:ts=2:sts=2:sw=2:et:
