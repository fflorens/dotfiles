return {
  "folke/which-key.nvim",
  event = "VimEnter",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300
  end,
  config = function()
    require("which-key").setup({
      preset = "modern",
      icons = {
        mappings = true,
        keys = {},
      },
      win = {
        border = "rounded",
      },
    })
  end,
}
