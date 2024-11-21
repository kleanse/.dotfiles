-- Module containing general-purpose functions

---@class util.fn
local M = {}

---@class util.fn.bufdelete.Opts
---@field force? boolean Delete the buffer even if it is modified
---@field filter? fun(buf: number): boolean Filter for buffers to delete
---@field wipe? boolean Wipe the buffer instead of deleting it (see `:h :bwipeout`)

-- Function obtained from folke/snacks.nvim

--- Deletes the current buffer if `{buffer}` is `nil`, the buffer whose handle
--- is `{buffer}`, or every buffer from which the predicate `{opts.filter}`
--- returns `true`, if specified. This function is similar to
--- |nvim_buf_delete()| but keeps windows open.
---@param buffer? number
---@param opts? number|util.fn.bufdelete.Opts
function M.bufdelete(buffer, opts)
  opts = opts or {}
  opts = type(opts) == "function" and { filter = opts } or opts
  ---@cast opts util.fn.bufdelete.Opts
  if type(opts.filter) == "function" then
    for _, buf in ipairs(vim.tbl_filter(opts.filter, vim.api.nvim_list_bufs())) do
      if vim.bo[buf].buflisted then
        M.bufdelete(buf, vim.tbl_extend("force", {}, opts, { filter = false }))
      end
    end
    return
  end
  local buf = buffer or 0
  buf = buf == 0 and vim.api.nvim_get_current_buf() or buf
  vim.api.nvim_buf_call(buf, function()
    if vim.bo.modified and not opts.force then
      local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
      if choice == 0 or choice == 3 then -- 0 for <Esc> or <C-C> and 3 for Cancel
        return
      end
      if choice == 1 then -- Yes
        vim.cmd.write()
      end
    end
    -- Keep the windows viewing the buffer to be deleted open by populating
    -- them with a different buffer
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_call(win, function()
        if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
          return
        end
        -- Try using alternate buffer
        local alt = vim.fn.bufnr("#")
        if alt ~= buf and vim.fn.buflisted(alt) == 1 then
          vim.api.nvim_win_set_buf(win, alt)
          return
        end
        -- Try using previous buffer
        local has_previous = pcall(vim.cmd, "bprevious")
        if has_previous and buf ~= vim.api.nvim_win_get_buf(win) then
          return
        end
        -- Create new listed buffer
        local new_buf = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_win_set_buf(win, new_buf)
      end)
    end
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.cmd, (opts.wipe and "bwipeout! " or "bdelete! ") .. buf)
    end
  end)
end

--- Deletes all buffers.
---@param opts? util.fn.bufdelete.Opts
function M.bufdeleteall(opts)
  return M.bufdelete(
    nil,
    vim.tbl_extend("force", {}, opts or {}, {
      filter = function()
        return true
      end,
    })
  )
end

--- Deletes all buffers except the current one.
---@param opts? util.fn.bufdelete.Opts
function M.bufonly(opts)
  return M.bufdelete(
    nil,
    vim.tbl_extend("force", {}, opts or {}, {
      filter = function(b)
        return b ~= vim.api.nvim_get_current_buf()
      end,
    })
  )
end

--- Returns an array of symbol kinds with which to filter the results of LSP
--- document symbols listed in the builtin pickers of
--- `nvim-telescope/telescope.nvim`. The filter array to return is based on the
--- file type of `{buffer}` or is a default filter array if no matching filter
--- array was found or `nil` if the filter for the file type is `false`.
---@param buffer? number Buffer handle; 0 or `nil` for current buffer
---@return string[]?
function M.get_kind_filter(buffer)
  buffer = (buffer == nil or buffer == 0) and vim.api.nvim_get_current_buf() or buffer
  local ft = vim.bo[buffer].filetype
  local kind_filter = require("util.tbl").kind_filter
  if kind_filter == nil or kind_filter[ft] == false then
    return nil
  end
  if type(kind_filter[ft]) == "table" then
    return kind_filter[ft] --[=[@as string[]]=]
  end
  if type(kind_filter.default) == "table" then
    return kind_filter.default --[=[@as string[]]=]
  end
  return nil
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
--- new date may be specified (see `strftime()` for valid formats).
---@param format? string (default: `"%Y %b %d"`) Format of the new date
function M.update_last_change(format)
  format = format or "%Y %b %d"

  local pat = "[Ll]ast [Cc]hange:"
  local lines = vim.api.nvim_buf_get_lines(0, 0, 20, false)
  local date = os.date(format)
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
