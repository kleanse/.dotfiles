-- Highlight yanked text briefly
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Update the date following a "Last change:" string in the first 20 lines of
-- the current buffer
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("update-last-change", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.g.format_on_write then
      Config.fn.update_last_change()
    end
  end,
})

-- Trim trailing whitespace and peripheral blank lines
vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("trim-blanks", { clear = true }),
  pattern = "*",
  callback = function()
    if vim.g.format_on_write then
      Config.fn.trim_peripheral_blank_lines()
      Config.fn.trim_trailing_whitespace()
    end
  end,
})

-- Use a template file when editing new files of a specific type
local template_group = vim.api.nvim_create_augroup("edit-with-template", { clear = true })
vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.c",
  callback = function()
    Config.fn.read_template_file(".c", { 5, 0 })
    vim.cmd.startinsert({ bang = true })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.cpp",
  callback = function()
    Config.fn.read_template_file(".cpp", { 5, 0 })
    vim.cmd.startinsert({ bang = true })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.h",
  callback = function()
    Config.fn.read_template_file(".h", { 4, 0 })
    Config.fn.set_header_macros()
    vim.cmd.startinsert({ bang = true })
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "*.html",
  callback = function()
    Config.fn.read_template_file(".html", { 6, 11 })
    vim.cmd.startinsert()
  end,
})

vim.api.nvim_create_autocmd("BufNewFile", {
  group = template_group,
  pattern = "Makefile",
  callback = function()
    Config.fn.read_template_file(".mk", { 2, 0 })
    vim.api.nvim_set_current_line(vim.api.nvim_get_current_line() .. " ")
    vim.cmd.startinsert({ bang = true })
  end,
})
