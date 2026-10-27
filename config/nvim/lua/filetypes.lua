-- Filetypes
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.h",
  command = "set filetype=c"
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = "*.bash",
  command = "set filetype=sh"
})

-- ruff auto format
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    if vim.fn.executable("ruff") == 1 then
      local path = vim.fn.expand("%")
      local formatted = vim.fn.system(
        { "ruff", "format", "--stdin-filename", path, "-" },
        table.concat(vim.fn.getline(1, "$"), "\n")
      )
      if vim.v.shell_error == 0 then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(formatted, "\n", { plain = true }))
      end
    end
  end,
})

-- Default indentation: 4 spaces
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Show whitespace characters
vim.opt.list = true
vim.opt.listchars = {
  tab = "»·",
  space = "·",
  trail = "-",
}
