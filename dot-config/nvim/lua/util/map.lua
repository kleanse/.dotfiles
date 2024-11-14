---@class util.map
local M = {}

M.jump = {}
M.toggle = {}

---@class util.map.jump.set.Opts
---@field name? string
---@field next_desc? string
---@field prev_desc? string
---@field mode? string|string[]

---@param char string
---@param rhs { next: string|function, prev: string|function }
---@param opts? util.map.jump.set.Opts
---@param keymap_opts? vim.keymap.set.Opts
---@return { mode: string|string[], lhs: string, rhs: string|function, opts: vim.keymap.set.Opts } next_keymap_args
---@return { mode: string|string[], lhs: string, rhs: string|function, opts: vim.keymap.set.Opts } prev_keymap_args
local function parse_jump(char, rhs, opts, keymap_opts)
  opts = opts or {}
  keymap_opts = keymap_opts or {}

  local mode = opts.mode or "n"
  local name = opts.name or "??"
  local next_desc = opts.next_desc or ("Jump to the next " .. name)
  local prev_desc = opts.prev_desc or ("Jump to the previous " .. name)
  local next_lhs = "]" .. char
  local prev_lhs = "[" .. char
  local next_opts = vim.deepcopy(keymap_opts)
  local prev_opts = vim.deepcopy(keymap_opts)
  next_opts.desc = next_desc
  prev_opts.desc = prev_desc

  local next = { mode, next_lhs, rhs.next, next_opts }
  local prev = { mode, prev_lhs, rhs.prev, prev_opts }
  return next, prev
end

--- Like `util.map.jump.set()` but returns two tables in the format of
--- `LazyKeysSpec` to be used in `LazySpec.keys` of `lazy.nvim`.
---@param char string
---@param rhs { next: string|function, prev: string|function }
---@param opts? util.map.jump.set.Opts
---@param keymap_opts? vim.keymap.set.Opts
---@return table next_lazy_keys_spec
---@return table prev_lazy_keys_spec
function M.jump.lazy_keys(char, rhs, opts, keymap_opts)
  local next, prev = parse_jump(char, rhs, opts, keymap_opts)
  local next_lazy_keys_spec = vim.tbl_extend("force", { mode = next[1], next[2], next[3] }, next[4])
  local prev_lazy_keys_spec = vim.tbl_extend("force", { mode = prev[1], prev[2], prev[3] }, prev[4])
  return next_lazy_keys_spec, prev_lazy_keys_spec
end

--- Defines two mappings `next` and `prev` that jump to the next or
--- previous occurrence of an object. Both `next` and `prev` use `{char}` in
--- their left-hand sides, which are differentiated by a prefix: ']' for `next`
--- and '[' for `prev`. `{keymap_opts}` is the same as `opts` of
--- `vim.keymap.set()`.
---@param char string Suffix for left-hand sides `lhs` of jump mappings
---@param rhs { next: string|function, prev: string|function } See |vim.keymap.set()|
---@param opts? util.map.jump.set.Opts Options:
---             • "name" name of the jump object.
---             • "next_desc" mapping description for next.
---             • "prev_desc" mapping description for prev.
---             • "mode" (default: "n") mode.
---@param keymap_opts? vim.keymap.set.Opts See |vim.keymap.set()|
function M.jump.set(char, rhs, opts, keymap_opts)
  local next, prev = parse_jump(char, rhs, opts, keymap_opts)
  vim.keymap.set(unpack(next))
  vim.keymap.set(unpack(prev))
end

---@class util.map.toggle.set.Opts
---@field name? string
---@field desc_name? string
---@field echo? boolean
---@field states? { on: any, off: any }
---@field mode? string|string[]

---@class util.Toggle
---@field get fun(): boolean
---@field set fun(state: boolean)

---@class util.Toggle.wrap: util.Toggle
---@operator call:boolean

---@param toggle util.Toggle
local function wrap(toggle)
  return setmetatable(toggle, {
    __call = function()
      toggle.set(not toggle.get())
      return toggle.get()
    end,
  }) --[[@as util.Toggle.wrap]]
end

---@param name string
---@return util.Toggle.wrap?
local function toggle_variable(name)
  local indices = { name:find("^vim%.([gbwtv])%.") }
  if #indices > 0 then
    local c = indices[3]
    name = name:sub(indices[2] + 1)
    return wrap({
      get = function()
        return vim[c][name]
      end,
      set = function(state)
        vim[c][name] = state
      end,
    })
  end
  return nil
end

---@param name string
---@param opts? util.map.toggle.set.Opts
---@return util.Toggle.wrap?
local function toggle_option(name, opts)
  opts = opts or {}
  local on = opts.states and opts.states.on or true
  local off = opts.states and opts.states.off or false
  if vim.opt_local[name] then
    return wrap({
      get = function()
        return vim.opt_local[name]._value == on
      end,
      set = function(state)
        vim.opt_local[name] = state and on or off
      end,
    })
  end
  return nil
end

---@param funcs { (get: fun(): boolean), (set: fun(state: boolean)) }
---@return util.Toggle.wrap?
local function toggle_custom(funcs)
  if funcs.get and funcs.set then
    return wrap({
      get = funcs.get,
      set = funcs.set,
    })
  end
  return nil
end

---@param lhs string
---@param rhs string|{ (get: fun(): boolean), (set: fun(state: boolean)) }
---@param opts? util.map.toggle.set.Opts
---@param keymap_opts? vim.keymap.set.Opts
---@return string|string[] mode
---@return string lhs
---@return string|function parsed_rhs
---@return vim.keymap.set.Opts parsed_opts
local function parse_toggle(lhs, rhs, opts, keymap_opts)
  opts = opts or {}
  keymap_opts = keymap_opts and vim.deepcopy(keymap_opts) or {}

  local desc_name = opts.desc_name or opts.name or "??"
  local mode = opts.mode or "n"
  local is_option = false
  local t
  if type(rhs) == "string" then
    rhs = vim.trim(rhs)
    t = toggle_variable(rhs)
    if t == nil then
      t = toggle_option(rhs, opts)
      if t == nil then
        keymap_opts.desc = keymap_opts.desc or ("Toggle " .. desc_name)
        return mode, lhs, rhs, keymap_opts
      end
      is_option = true
    end
  else
    t = toggle_custom(rhs)
  end

  if t == nil then
    error("unrecognized rhs for " .. lhs)
  end

  local option_name = ""
  if is_option then
    option_name = vim.opt_local[rhs]._info.name
    if desc_name == "??" then
      desc_name = "'" .. option_name .. "'"
    end
    keymap_opts.desc = keymap_opts.desc or ("Toggle " .. desc_name)
  else
    keymap_opts.desc = keymap_opts.desc or ("Toggle " .. desc_name)
  end

  local f
  if opts.echo then
    if is_option then
      f = function()
        t()
        vim.cmd.set(option_name .. "?")
      end
    else
      f = function()
        local prefix = t() and "  " or "no"
        vim.api.nvim_echo({ { prefix .. (opts.name or ("[NO NAME: " .. lhs .. "]")) } }, false, {})
      end
    end
  else
    f = function()
      t()
    end
  end

  return mode, lhs, f, keymap_opts
end

--- Like `util.map.toggle.set()` but returns a table in the format of
--- `LazyKeysSpec` to be used in `LazySpec.keys` of `lazy.nvim`.
---@param lhs string
---@param rhs string|{ (get: fun(): boolean), (set: fun(state: boolean)) }
---@param opts? util.map.toggle.set.Opts
---@param keymap_opts? vim.keymap.set.Opts
---@return table lazy_keys_spec
function M.toggle.lazy_keys(lhs, rhs, opts, keymap_opts)
  local p_mode, p_lhs, p_rhs, p_keymap_opts = parse_toggle(lhs, rhs, opts, keymap_opts)
  local lazy_keys_spec = vim.tbl_extend("force", { mode = p_mode, p_lhs, p_rhs }, p_keymap_opts)
  return lazy_keys_spec
end

--- Defines a mapping that toggles `{rhs}`.
---@param lhs string Left-hand side {lhs} of the mapping.
---@param rhs string|{ (get: fun(): boolean), (set: fun(state: boolean)) } State to toggle or custom toggle behavior, i.e., an option name, Vim variable, or table that defines the `get` and `set` keys.
---     Example:
--- ```lua
---     {
---       get = function()
---         return vim.diagnostic.is_enabled()
---       end,
---       set = function(state)
---         vim.diagnostic.enable(state)
---       end,
---     }
--- ```
---@param opts? util.map.toggle.set.Opts Options:
---             • "name" name to show if {echo} is true.
---             • "desc_name" name to show in mapping description.
---             • "echo" (boolean) if true, echo current state after toggling.
---             • "states" table for defining "on" and "off" states of toggle;
---               only used when toggling |options|.
---             • "mode" (default: "n") mode.
---@param keymap_opts? vim.keymap.set.Opts See |vim.keymap.set()|
function M.toggle.set(lhs, rhs, opts, keymap_opts)
  vim.keymap.set(parse_toggle(lhs, rhs, opts, keymap_opts))
end

return M
