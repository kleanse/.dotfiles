-- Module containing general-purpose functions

---@class util.fn
local M = {}

---@return string|osdate date Today's date in "yyyy Jan dd" format
function M.date()
  return os.date("%Y %b %d")
end

--- Reads the template file with the extension `ext` into the current buffer
--- and sets the cursor's position to `curpos`, which uses (1,0) indexing
--- |api-indexing|. By default, template files are searched for in
--- `stdpath("config")/templates`; set `vim.g.template_path` to change this
--- search path.
---@param ext string Extension of template file, e.g., ".c" or ".mk"
---@param curpos number[] (row, col) tuple indicating the new position
function M.read_template_file(ext, curpos)
  local filename = "template" .. ext
  local path = vim.g.template_path or vim.fs.joinpath(vim.fn.stdpath("config") --[[@as string]], "templates")
  path = vim.fs.normalize(vim.fs.joinpath(path, filename))

  vim.cmd.read(path)
  vim.api.nvim_buf_set_lines(0, 0, 1, false, {})
  vim.api.nvim_win_set_cursor(0, curpos)
end

--- Sets the values for the "ifndef" guard in the current file based on the
--- file's name and current date (yyyymmdd).
function M.set_header_macros()
  local macro_name = " " .. string.gsub(string.upper(vim.fn.expand("%:t")), "%.", "_" .. os.date("%Y%m%d") .. "_")
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.api.nvim_buf_set_lines(0, 0, 1, false, { lines[1] .. macro_name })
  vim.api.nvim_buf_set_lines(0, 1, 2, false, { lines[2] .. macro_name })
  vim.api.nvim_buf_set_lines(0, -2, -1, false, { lines[#lines] .. " //" .. macro_name })
end

--- Deletes starting and ending blank lines in the current buffer. For example,
--- for the following buffer,
--- ```
---1
---2 A line containing non-space characters.
---3
---4 Another line.
---5
---6
---7
--- ```
--- `util.fn.trim_peripheral_blank_lines()` will delete four lines: one at the
--- start (line 1) and three at the end (lines 5, 6, and 7).
function M.trim_peripheral_blank_lines()
  local total_lines = vim.fn.line("$")
  local n_starting_blank_lines = 0

  for i = 1, total_lines do
    if string.match(vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1], "%S") then
      break
    end
    n_starting_blank_lines = n_starting_blank_lines + 1
  end

  local n_ending_blank_lines = 0

  if n_starting_blank_lines ~= total_lines then
    for i = total_lines, 1, -1 do
      if string.match(vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1], "%S") then
        break
      end
      n_ending_blank_lines = n_ending_blank_lines + 1
    end
  end

  local total_blank_lines = n_starting_blank_lines + n_ending_blank_lines

  -- Do not add an empty change to the undo tree
  if total_blank_lines == 0 then
    return
  end

  -- Delete ending lines first; doing the reverse messes the line count
  -- for the ending lines.
  vim.api.nvim_buf_set_lines(0, -1 - n_ending_blank_lines, -1, false, {})
  vim.api.nvim_buf_set_lines(0, 0, n_starting_blank_lines, false, {})

  if total_blank_lines == total_lines then
    vim.api.nvim_echo({ { "--No lines in buffer--" } }, false, {})
  elseif total_blank_lines > vim.o.report then
    local msg = total_blank_lines == 1 and total_blank_lines .. " line less" or total_blank_lines .. " fewer lines"
    print(msg)
  end
end

--- Deletes trailing whitespace in the current buffer.
function M.trim_trailing_whitespace()
  local save_view = vim.fn.winsaveview()
  local save_search = vim.fn.getreg("/")
  vim.cmd([[%substitute/\v\s+$//e]])
  vim.fn.winrestview(save_view)
  vim.fn.setreg("/", save_search)
end

--- Updates the date found after the first occurrence of the string
--- "Last change:" in the first 20 lines of the current file. The format of the
--- new date may be specified (see `strftime()` for valid formats). If no
--- format is given, the date returned by `util.fn.date()` is used.
---@param format? string Format of the new date
function M.update_last_change(format)
  local pat = "[Ll]ast [Cc]hange:"
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local date = format and os.date(format) or M.date()
  ---@cast date string

  for i, line in ipairs(lines) do
    if line:match(pat) then
      -- Do not add an empty change to the undo tree
      if line:match(date) then
        break
      end
      local space = ""
      if not line:match(pat .. "%s") then
        space = "\t"
      end
      local updated_line = line:gsub("(" .. pat .. "%s*).*$", "%1" .. space .. date)
      vim.api.nvim_buf_set_lines(0, i - 1, i, false, { updated_line })
      break
    end
  end
end

return M
