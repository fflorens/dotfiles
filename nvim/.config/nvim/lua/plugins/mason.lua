return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      -- List of servers for mason to install
      ensure_installed = {
        "lua_ls",        -- Lua
        "rust_analyzer", -- Rust
        "gopls",         -- Go
        "pyright",       -- Python
        "ts_ls",         -- TypeScript/JavaScript
        "html",          -- HTML
        "cssls",         -- CSS
        "tailwindcss",   -- Tailwind CSS
        "jsonls",        -- JSON
        "yamlls",        -- YAML
      },
      -- Auto-install configured servers (with lspconfig)
      automatic_installation = true,
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- Formatter
        "stylua",   -- Lua formatter
        "eslint_d", -- JS linter
        "rustfmt",  -- Rust formatter
        "gofumpt",  -- Go formatter
        "goimports", -- Go imports formatter
      },
    })
  end,
}
