-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs and indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Line wrapping
vim.opt.wrap = false

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.grepprg = "rg --vimgrep -uu"
vim.opt.grepformat = "%f:%l:%c:%m"

-- Cursor line
vim.opt.cursorline = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"

-- Backspace
vim.opt.backspace = "indent,eol,start"

-- Clipboard
vim.opt.clipboard:append("unnamedplus")

-- Split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Auto change directory to current file's directory
vim.opt.autochdir = true

-- Swap and backup
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Update time
vim.opt.updatetime = 250

-- Completion
vim.opt.completeopt = "menuone,noselect"

-- Scroll offset
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Diff settings
vim.opt.diffopt:append("vertical")    -- Open diffs in vertical splits
vim.opt.diffopt:append("algorithm:histogram")  -- Better diff algorithm
vim.opt.diffopt:append("indent-heuristic")     -- Better diff alignment
