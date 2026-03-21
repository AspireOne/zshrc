local platform = require("config.platform")

if platform.clipboard_register then
  local clipboard_group = vim.api.nvim_create_augroup("system_clipboard_yank", { clear = true })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = clipboard_group,
    callback = function()
      if vim.v.event.operator ~= "y" then
        return
      end

      local regname = vim.v.event.regname
      if regname == "" then
        regname = '"'
      end

      vim.fn.setreg(platform.clipboard_register, vim.fn.getreg(regname), vim.fn.getregtype(regname))
    end,
  })
end
