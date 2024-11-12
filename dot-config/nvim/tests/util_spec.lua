local map = require("util.map")

describe("util.map", function()
  describe("jump.lazy_keys()", function()
    local char = "q"
    local next_desc = "Jump to the next "
    local prev_desc = "Jump to the previous "

    it("should return a LazyKeysSpec", function()
      local name = "error"
      local expected_next_lazy_keys_spec = { "]" .. char, desc = next_desc .. name }
      local expected_prev_lazy_keys_spec = { "[" .. char, desc = prev_desc .. name }
      local next_lazy_keys_spec, prev_lazy_keys_spec = map.jump.lazy_keys(
        char,
        { next = "<Cmd>cnext<CR>", prev = "<Cmd>cprevious<CR>" },
        { name = name }
      )
      assert.is_not_nil(next_lazy_keys_spec)
      assert.is_not_nil(prev_lazy_keys_spec)
      expected_next_lazy_keys_spec[2] = next_lazy_keys_spec[2]
      expected_prev_lazy_keys_spec[2] = prev_lazy_keys_spec[2]
      assert.is.same(expected_next_lazy_keys_spec, next_lazy_keys_spec)
      assert.is.same(expected_prev_lazy_keys_spec, prev_lazy_keys_spec)
    end)
  end)

  describe("jump.set()", function()
    local char = "q"
    local next_desc = "Jump to the next "
    local prev_desc = "Jump to the previous "

    it("should create a jump mapping", function()
      local name = "error"
      local expected_next_desc = next_desc .. name
      local expected_prev_desc = prev_desc .. name
      map.jump.set(char, { next = "<Cmd>cnext<CR>", prev = "<Cmd>cprevious<CR>" }, { name = name })
      assert.is.equal(expected_next_desc, vim.fn.maparg("]" .. char, "n", false, true).desc)
      assert.is.equal(expected_prev_desc, vim.fn.maparg("[" .. char, "n", false, true).desc)
    end)
    it("should error on an invalid rhs", function()
      local expected_error = "rhs: expected string|function, got nil"
      assert.has_error(function()
        map.jump.set(char, {})
      end, expected_error)
    end)
  end)

  describe("toggle.lazy_keys()", function()
    local lhs = "foo"

    it("should return a LazyKeysSpec", function()
      local desc_name = "some variable"
      local expected_lazy_keys_spec = { lhs, desc = "Toggle " .. desc_name }
      local lazy_keys_spec = map.toggle.lazy_keys(lhs, "vim.g.some_var", { desc_name = "some variable" })
      assert.is_not_nil(lazy_keys_spec)
      expected_lazy_keys_spec[2] = lazy_keys_spec[2]
      assert.is.same(expected_lazy_keys_spec, lazy_keys_spec)
    end)
  end)

  describe("toggle.set()", function()
    local lhs = "foo"

    it("should create a toggle mapping", function()
      local expected_desc = "Toggle ??"
      map.toggle.set(lhs, "vim.g.some_var")
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    it("should create a named toggle mapping", function()
      local desc_name = "some variable"
      local expected_desc = "Toggle " .. desc_name
      map.toggle.set(lhs, "vim.g.some_var", { desc_name = desc_name })
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    it("should create a named toggle mapping using `opts.name` if `opts.desc_name` is omitted", function()
      local desc_name = "some variable named by opts.name"
      local expected_desc = "Toggle " .. desc_name
      map.toggle.set(lhs, "vim.g.some_var", { name = desc_name })
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    it("should error on an invalid rhs", function()
      local expected_error = "unrecognized rhs for " .. lhs
      assert.has_error(function()
        map.toggle.set(lhs, {})
      end, expected_error)
    end)
    -- Variables
    it("should create a toggle mapping for a variable", function()
      local expected_desc = "Toggle ??"
      map.toggle.set(lhs, "vim.g.test")
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    -- Options
    it("should create a toggle mapping for an option", function()
      local expected_desc = "Toggle 'list'"
      map.toggle.set(lhs, "list")
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    it("should create a toggle mapping for an abbreviated option", function()
      local expected_desc = "Toggle 'colorcolumn'"
      map.toggle.set(lhs, "cc")
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    it("should create a named toggle mapping for an option", function()
      local desc_name = "myoption"
      local expected_desc = "Toggle " .. desc_name
      map.toggle.set(lhs, "spell", { desc_name = desc_name })
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
    -- Custom functions
    it("should create a toggle mapping for custom functions", function()
      local expected_desc = "Toggle ??"
      map.toggle.set(lhs, {
        get = function()
          return vim.g.foobar
        end,
        set = function(state)
          vim.g.foobar = state
        end,
      })
      assert.is.equal(expected_desc, vim.fn.maparg(lhs, "n", false, true).desc)
    end)
  end)
end)
