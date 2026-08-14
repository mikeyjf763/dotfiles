-- lua/plugins/lsp.lua
-- Full LSP stack:
--   mason          → installs servers / formatters / linters
--   mason-lspconfig → bridges mason with lspconfig
--   nvim-lspconfig  → configures the servers
--   nvim-cmp + sources → completion engine
--   LuaSnip        → snippet engine (required by cmp)
return {
  -- ── Mason: server installer ──────────────────────────────────────────────
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  -- ── mason-lspconfig: auto-install & activate servers ─────────────────────
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        -- Add any servers you want auto-installed here.
        ensure_installed = {
          "lua_ls",        -- Lua
          "ts_ls",         -- TypeScript / JavaScript
          "pyright",       -- Python
          "bashls",        -- Bash
          "jsonls",        -- JSON
          "cssls",         -- CSS
          "html",          -- HTML
        },
        automatic_installation = true,
      })
    end,
  },

  -- ── nvim-lspconfig: server setup ─────────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      local map = vim.keymap.set

      -- Shared on_attach: keymaps that are only useful when an LSP is active.
      local on_attach = function(_, bufnr)
        local opts = function(desc)
          return { buffer = bufnr, desc = desc }
        end
        map("n", "<leader>ld", vim.lsp.buf.definition,        opts("Go to definition"))
        map("n", "<leader>lD", vim.lsp.buf.declaration,       opts("Go to declaration"))
        map("n", "<leader>lr", vim.lsp.buf.references,        opts("References"))
        map("n", "<leader>li", vim.lsp.buf.implementation,    opts("Go to implementation"))
        map("n", "<leader>lt", vim.lsp.buf.type_definition,   opts("Type definition"))
        map("n", "<leader>ln", vim.lsp.buf.rename,            opts("Rename symbol"))
        map("n", "<leader>la", vim.lsp.buf.code_action,       opts("Code action"))
        map("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, opts("Format buffer"))
        map("n", "K",          vim.lsp.buf.hover,             opts("Hover docs"))
        map("n", "<leader>ls", vim.lsp.buf.signature_help,    opts("Signature help"))
        -- Diagnostics
        map("n", "<leader>le", vim.diagnostic.open_float,     opts("Show diagnostic"))
        map("n", "[d",         vim.diagnostic.goto_prev,      opts("Prev diagnostic"))
        map("n", "]d",         vim.diagnostic.goto_next,      opts("Next diagnostic"))
        map("n", "<leader>lq", vim.diagnostic.setloclist,     opts("Diagnostics to loclist"))
      end

      -- Shared capabilities: advertise nvim-cmp's extra completion features.
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Apply shared config to every server via the wildcard entry.
      vim.lsp.config("*", {
        on_attach = on_attach,
        capabilities = capabilities,
      })

      -- Per-server overrides using the new vim.lsp.config API.
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable all servers (mason-lspconfig ensures they are installed).
      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "pyright",
        "bashls",
        "jsonls",
        "cssls",
        "html",
      })

      -- Diagnostic UI tweaks.
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      })
    end,
  },

  -- ── Completion engine ─────────────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",     -- LSP completions
      "hrsh7th/cmp-buffer",        -- words from the current buffer
      "hrsh7th/cmp-path",          -- file-system paths
      "hrsh7th/cmp-cmdline",       -- completions in : command line
      "saadparwaiz1/cmp_luasnip",  -- snippet completions
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp", -- optional: regex support in snippets
        dependencies = { "rafamadriz/friendly-snippets" }, -- big snippet collection
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load() -- load friendly-snippets
        end,
      },
      "onsails/lspkind.nvim", -- VSCode-style icons in the completion menu
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          format = lspkind.cmp_format({
            mode = "symbol_text",
            maxwidth = 50,
            ellipsis_char = "…",
          }),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]   = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]   = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]   = cmp.mapping.abort(),
          -- Confirm with Enter; only confirm an explicit selection.
          ["<CR>"]    = cmp.mapping.confirm({ select = false }),
          -- Tab: cycle through items OR expand / jump through snippets.
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000 },
          { name = "luasnip",  priority = 750 },
          { name = "buffer",   priority = 500 },
          { name = "path",     priority = 250 },
        }),
      })

      -- Completions in / search bar (buffer words only).
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- Completions in : command line (path + cmdline sources).
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },


}
