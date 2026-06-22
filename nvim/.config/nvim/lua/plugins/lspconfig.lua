return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local keymap = vim.keymap
    local wk = require("which-key")

    -- Enable keybinds only for when LSP server is available
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        -- Enable inlay hints if supported
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.server_capabilities.inlayHintProvider then
          vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
        end

        -- Register which-key groups for LSP
        wk.add({
          { "g", group = "Goto", buffer = ev.buf },
          { "[", group = "Previous", buffer = ev.buf },
          { "]", group = "Next", buffer = ev.buf },
          { "<leader>c", group = "Code", buffer = ev.buf },
          { "<leader>r", group = "Rename/Restart", buffer = ev.buf },
          { "<leader>d", group = "Diagnostics", buffer = ev.buf },
        })

        -- Set keybinds
        opts.desc = "Show LSP references"
        keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Go to declaration"
        keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

        opts.desc = "Show LSP definitions"
        keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

        opts.desc = "Show LSP implementations"
        keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

        opts.desc = "See available code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "K", vim.lsp.buf.hover, opts)

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    -- Used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- Configure LSP servers using new vim.lsp.config API
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })
    vim.lsp.enable("lua_ls")

    vim.lsp.config("rust_analyzer", {
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")

    vim.lsp.config("gopls", {
      cmd = { "gopls" },
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      capabilities = capabilities,
      settings = {
        gopls = {
          hints = {
            compositeLiteralFields = true,
            constantValues = true,
            parameterNames = true,
            functionTypeParameters = true,
          },
          usePlaceholders = true,
          analyses = {
            unusedparams = true,
            unreachable = true,
          },
          staticcheck = true,
          gofumpt = true,
        },
      },
    })
    -- Work-specific gopls overrides,
    -- loaded only when work dotfiles are present
    pcall(require, "work.gopls")
    vim.lsp.enable("gopls")

    vim.lsp.config("pyright", {
      capabilities = capabilities,
    })
    vim.lsp.enable("pyright")

    vim.lsp.config("ts_ls", {
      capabilities = capabilities,
    })
    vim.lsp.enable("ts_ls")

    vim.lsp.config("html", {
      capabilities = capabilities,
    })
    vim.lsp.enable("html")

    vim.lsp.config("cssls", {
      capabilities = capabilities,
    })
    vim.lsp.enable("cssls")

    vim.lsp.config("tailwindcss", {
      capabilities = capabilities,
    })
    vim.lsp.enable("tailwindcss")

    vim.lsp.config("jsonls", {
      capabilities = capabilities,
    })
    vim.lsp.enable("jsonls")

    vim.lsp.config("yamlls", {
      capabilities = capabilities,
    })
    vim.lsp.enable("yamlls")
  end,
}
