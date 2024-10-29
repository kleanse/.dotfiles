return {
  { -- gruvbox color scheme
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    opts = {
      overrides = {
        GruvboxAquaUnderline = { fg = "#427b58" },
        GruvboxBlueUnderline = { fg = "#076678" },
        GruvboxGreenUnderline = { fg = "#79740e" },
        GruvboxOrangeUnderline = { fg = "#af3a03" },
        GruvboxPurpleUnderline = { fg = "#8f3f71" },
        GruvboxRedUnderline = { fg = "#9d0006" },
        GruvboxYellowUnderline = { fg = "#b57614" },

        GruvboxAquaUnderlineItalic = { fg = "#427b58", sp = "#427b58", undercurl = true, italic = true },
        GruvboxBlueUnderlineItalic = { fg = "#076678", sp = "#076678", undercurl = true, italic = true },
        GruvboxGreenUnderlineItalic = { fg = "#79740e", sp = "#79740e", undercurl = true, italic = true },
        GruvboxOrangeUnderlineItalic = { fg = "#af3a03", sp = "#af3a03", undercurl = true, italic = true },
        GruvboxPurpleUnderlineItalic = { fg = "#8f3f71", sp = "#8f3f71", undercurl = true, italic = true },
        GruvboxRedUnderlineItalic = { fg = "#9d0006", sp = "#9d0006", undercurl = true, italic = true },
        GruvboxYellowUnderlineItalic = { fg = "#b57614", sp = "#b57614", undercurl = true, italic = true },

        SpellBad = { link = "GruvboxRedUnderlineItalic" },
        SpellCap = { link = "GruvboxBlueUnderlineItalic" },
        SpellRare = { link = "GruvboxPurpleUnderlineItalic" },
        SpellLocal = { link = "GruvboxAquaUnderlineItalic" },
      },
    },
    config = function(_, opts)
      require("gruvbox").setup(opts)

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("highlight-colorscheme", { clear = true }),
        pattern = "gruvbox",
        callback = function()
          -- mini.statusline highlight groups
          vim.api.nvim_set_hl(0, "MiniStatuslineModeNormal", { fg = "bg", bg = "#928374", bold = true })
          vim.api.nvim_set_hl(0, "MiniStatuslineModeInsert", { fg = "bg", bg = "#076678", bold = true })
          vim.api.nvim_set_hl(0, "MiniStatuslineModeVisual", { fg = "bg", bg = "#8f3f71", bold = true })
          vim.api.nvim_set_hl(0, "MiniStatuslineModeReplace", { fg = "bg", bg = "#9d0006", bold = true })
          vim.api.nvim_set_hl(0, "MiniStatuslineModeCommand", { fg = "bg", bg = "#b57614", bold = true })
          vim.api.nvim_set_hl(0, "MiniStatuslineModeOther", { fg = "bg", bg = "#79740e", bold = true })
        end,
      })

      vim.cmd.colorscheme("gruvbox")
    end,
  },
}
