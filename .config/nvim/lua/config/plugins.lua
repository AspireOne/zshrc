local M = {}

function M.which_key()
  local which_key = require("which-key")
  which_key.setup({})
  which_key.add({
    { "<leader>h", group = "git hunk" },
  })
end

function M.gitsigns()
  local gitsigns = require("gitsigns")
  gitsigns.setup({
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
    },
  })
end

function M.mini()
  require("mini.surround").setup()
end

return M
