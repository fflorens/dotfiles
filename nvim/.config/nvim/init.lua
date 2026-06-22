-- Set leader keys BEFORE loading lazy
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Bootstrap lazy.nvim
require("config.lazy")

-- Load core configuration
require("config.options")
require("config.keymaps")
