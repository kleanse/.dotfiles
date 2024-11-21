---@class util.mini
local M = {}

---@param ArgLead string
function M.complete_session_names(ArgLead)
  local ms = require("mini.sessions")
  ---@param v table
  local session_names = vim.tbl_map(function(v)
    return v.name
  end, vim.tbl_values(ms.detected))
  ---@param name string
  local results = vim.tbl_filter(function(name)
    return vim.startswith(name, ArgLead)
  end, session_names)
  if #results == 0 then
    -- Try finding matches by ignoring case
    ---@param name string
    results = vim.tbl_filter(function(name)
      return vim.startswith(name:lower(), ArgLead:lower())
    end, session_names)
  end
  return results
end

---@param session_name? string `mini.sessions` session name; `nil` for active session
---@param opts? table Options for `MiniSessions.delete()`
function M.delete_session(session_name, opts)
  opts = opts or {}
  opts.verbose = opts.verbose or false
  local ms = require("mini.sessions")
  local fname = session_name or vim.fn.fnamemodify(vim.fs.normalize(vim.v.this_session), ":t")
  local ok, errmsg = pcall(ms.delete, session_name, opts)
  if opts.verbose then
    return
  end
  local info
  if ok then
    info = "deleting"
  else
    errmsg = errmsg or ""
    errmsg = errmsg:sub(({ errmsg:find("%(mini%.sessions%) .") })[2] or 1)
    if errmsg:find("is not a name for detected session", 1, true) then
      info = "ignoring; session not found:"
    elseif vim.startswith(errmsg, "Can't delete current session") then
      info = "ignoring; can't delete current session (no '!'):"
    else
      info = errmsg ~= "" and errmsg or "Delete failed but received no error message."
    end
  end
  vim.api.nvim_echo({ { string.format("%s   %s", info, fname) } }, false, {})
end

-- Function provided by LazyVim.

---@param opts { skip_next: string, skip_ts: string[], skip_unbalanced: boolean, markdown: boolean }
function M.pairs(opts)
  local pairs = require("mini.pairs")
  pairs.setup(opts)
  local open = pairs.open
  pairs.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= "" then
      return open(pair, neigh_pattern)
    end
    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and line:match("^%s*``$") then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<Up>", true, true, true)
    end
    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
      return o
    end
    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then
          return o
        end
      end
    end
    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then
        return o
      end
    end
    return open(pair, neigh_pattern)
  end
end

return M
