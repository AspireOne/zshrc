return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("config.plugins").which_key()
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("config.plugins").gitsigns()
    end,
  },
  {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      require("config.plugins").mini()
    end,
  },
}
