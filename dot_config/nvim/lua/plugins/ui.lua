return {
  -- Theme
  {
    "catppuccin/nvim",
    opts = {
      auto_integrations = true,
      flavor = "mocha",
      transparent_background = true,
    },
  },

  -- LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },

  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        mode = { "n", "x" },
        { "<leader>o", name = "+opencode", icon = "󰚩" },
      },
    },
  },
}
