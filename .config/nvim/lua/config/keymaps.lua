local platform = require("config.platform")

vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("i", "ds", "<Esc>", { desc = "Exit Insert Mode" })
vim.keymap.set("n", "<leader>?", function()
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.show({ global = true })
  end
end, { desc = "Show Keymaps" })

if platform.clipboard_register then
  vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy To System Clipboard" })
end

-- Delete/change without yanking (discard to the black-hole register)
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map({ "n", "x" }, "d", '"_d', opts)
map({ "n", "x" }, "D", '"_D', opts)

map({ "n", "x" }, "c", '"_c', opts)
map({ "n", "x" }, "C", '"_C', opts)

map({ "n", "x" }, "x", '"_x', opts)
map({ "n", "x" }, "X", '"_X', opts)

map({ "n", "x" }, "s", '"_s', opts)
map({ "n", "x" }, "S", '"_S', opts)

map("n", "]h", function()
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then
    gitsigns.nav_hunk("next")
  end
end, { desc = "Next Git Hunk" })

map("n", "[h", function()
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then
    gitsigns.nav_hunk("prev")
  end
end, { desc = "Previous Git Hunk" })

map("n", "<leader>hs", function()
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then
    gitsigns.stage_hunk()
  end
end, { desc = "Stage Hunk" })

map("n", "<leader>hr", function()
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then
    gitsigns.reset_hunk()
  end
end, { desc = "Reset Hunk" })

map("n", "<leader>hp", function()
  local ok, gitsigns = pcall(require, "gitsigns")
  if ok then
    gitsigns.preview_hunk()
  end
end, { desc = "Preview Hunk" })
