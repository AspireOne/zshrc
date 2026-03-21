local M = {}

M.is_windows = vim.fn.has("win32") == 1
M.is_linux = vim.fn.has("linux") == 1
M.has_clipboard = vim.fn.has("clipboard") == 1
M.clipboard_register = M.has_clipboard and "+" or nil

return M
