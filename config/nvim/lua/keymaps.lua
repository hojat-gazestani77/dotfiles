vim.keymap.set("n", "<leader><space>", ":nohlsearch<CR>")

-- file explorer
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")

-- telescope
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>")
vim.keymap.set("n", "<leader>rg", ":Telescope live_grep<CR>")

-- git
vim.keymap.set("n", "<leader>gs", ":Telescope git_status<CR>")

-- diagnostics
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
