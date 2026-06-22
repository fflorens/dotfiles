local keymap = vim.keymap
local wk = require("which-key")

-- General keymaps

-- Clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Window management
--wk.add({ "<leader>s", group = "Split" })
--keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
--keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
--keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
--keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })

-- Tab management
wk.add({ "<leader>t", group = "Tab" })
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Navigation between windows with arrow keys (won't interfere with macOS Mission Control)
keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Navigate to left window" })
keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Navigate to bottom window" })
keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Navigate to top window" })
keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Navigate to right window" })

-- Resize windows (using Meta/Alt + arrow keys to avoid macOS conflicts)
keymap.set("n", "<S-M-Up>", ":resize +2<CR>", { desc = "Increase window height" })
keymap.set("n", "<S-M-Down>", ":resize -2<CR>", { desc = "Decrease window height" })
keymap.set("n", "<S-M-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width" })
keymap.set("n", "<S-M-Right>", ":vertical resize +2<CR>", { desc = "Increase window width" })

-- Terminal mode: Navigation and resizing
-- Alternative navigation with arrow keys in terminal mode
keymap.set("t", "<C-Left>", "<C-\\><C-n><C-w>h", { desc = "Navigate to left window" })
keymap.set("t", "<C-Down>", "<C-\\><C-n><C-w>j", { desc = "Navigate to bottom window" })
keymap.set("t", "<C-Up>", "<C-\\><C-n><C-w>k", { desc = "Navigate to top window" })
keymap.set("t", "<C-Right>", "<C-\\><C-n><C-w>l", { desc = "Navigate to right window" })

-- Better indenting
keymap.set("v", "<", "<gv", { desc = "Indent left" })
keymap.set("v", ">", ">gv", { desc = "Indent right" })

-- Move text up and down
keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move text down" })
keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move text up" })

-- Keep cursor centered when scrolling
keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })

-- Better paste
keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- Save and quit shortcuts
keymap.set("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>x", "<cmd>wq<CR>", { desc = "Save and quit" })

-- Test
keymap.set("n", "<leader>t=", "<cmd>NERDTreeToggle<cr> <bar> <C-w>=", {desc = "Equal split width"})

wk.add({ "<leader>a", group = "AI/Claude" })

vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    local opts = { buffer = true, silent = true }
    -- Navigation keymaps
    vim.keymap.set("t", "<C-Left>", "<C-\\><C-n><C-w>h", vim.tbl_extend("force", opts, { desc = "Navigate to left window" }))
    vim.keymap.set("t", "<C-Down>", "<C-\\><C-n><C-w>j", vim.tbl_extend("force", opts, { desc = "Navigate to bottom window" }))
    vim.keymap.set("t", "<C-Up>", "<C-\\><C-n><C-w>k", vim.tbl_extend("force", opts, { desc = "Navigate to top window" }))
    vim.keymap.set("t", "<C-Right>", "<C-\\><C-n><C-w>l", vim.tbl_extend("force", opts, { desc = "Navigate to right window" }))
    -- Resize keymaps
    vim.keymap.set("t", "<S-M-Up>", "<C-\\><C-n>:resize +2<CR>i", vim.tbl_extend("force", opts, { desc = "Increase window height" }))
    vim.keymap.set("t", "<S-M-Down>", "<C-\\><C-n>:resize -2<CR>i", vim.tbl_extend("force", opts, { desc = "Decrease window height" }))
    vim.keymap.set("t", "<S-M-Left>", "<C-\\><C-n>:vertical resize -2<CR>i", vim.tbl_extend("force", opts, { desc = "Decrease window width" }))
    vim.keymap.set("t", "<S-M-Right>", "<C-\\><C-n>:vertical resize +2<CR>i", vim.tbl_extend("force", opts, { desc = "Increase window width" }))
  end,
})
