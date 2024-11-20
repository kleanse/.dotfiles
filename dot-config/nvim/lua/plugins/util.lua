return {
  { -- Snippet engine for creating, expanding, and jumping to the dynamic
    -- fields of short, reusable pieces of source code
    "L3MON4D3/LuaSnip",
    lazy = true,
    build = (function()
      -- This build step is needed for regex support in snippets, which is not
      -- supported in many Windows environments
      -- Remove the below condition to re-enable on Windows
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
        return nil
      end
      return "make install_jsregexp"
    end)(),
  },

  -- Extra functionalities for mini.ai, mini.hipatterns, and mini.pick
  { "echasnovski/mini.extra", lazy = true, opts = {} },

  -- Library used by other plugins
  { "nvim-lua/plenary.nvim", lazy = true },
}
