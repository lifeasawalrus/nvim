-- LSP installation: https://github.com/williamboman/mason-lspconfig.nvim#default-configuration
-- Source: https://www.youtube.com/watch?v=ppMX4LHIuy4
require('plugins')
require('config')

require("mason").setup()

require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "clangd", "omnisharp", "rust_analyzer", "jdtls",
  "ltex", "texlab", "marksman", "pyright", "r_language_server", "html",
  "ts_ls", "cssls"
},
}

--bracey settings

vim.g.bracey_auto_reload_css = 1
vim.g.bracey_refresh_on_save = 1

--enable vim colors
vim.opt.termguicolors = true

-- Set up nvim-cmp.
local cmp = require 'cmp'

require('nvim-treesitter.configs').setup {
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "java",
  "c_sharp", "bash", "cmake", "cpp", "css", "luadoc",
  "markdown", "python", "r", "rust", "javascript", "html", "vimdoc",
  },
  highlight = {
    enable = true,
  },
  indent = {
    enable = false,
  },
  modules = {},
  sync_install = false,
  ignore_install = {},
  auto_install = true,
}

vim.lsp.set_log_level("debug")

-- autoclose options
require("autoclose").setup({
  keys = {
    ["<"] = { escape = true, close = true, pair = "<>", enabled_filetypes = {"html",}, },
    ["'"] = { escape = true, close = true, pair = "''", disabled_filetypes = {"latex"}, },
    ["["] = { escape = true, close = true, pair = "[]", disabled_filetypes = {"lua",} }
  }
})

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users.
    { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
  }, {
    { name = 'buffer' },
  })
})


-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


require('lspconfig').util.default_config.capabilities = vim.tbl_deep_extend(
'force',
require('lspconfig').util.default_config.capabilities,
require('cmp_nvim_lsp').default_capabilities()
)

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }, -- Define 'vim' as a global variable
      },
      runtime = {
        version = 'LuaJIT', -- Inform the LSP that Neovim uses LuaJIT
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true), -- Include Neovim runtime files
      },
    },
  },
}
lspconfig.clangd.setup {}
lspconfig.omnisharp.setup {}
lspconfig.rust_analyzer.setup {}
lspconfig.jdtls.setup {}
lspconfig.ltex.setup {
  filetypes = {
    "bib", "gitcommit", "markdown", "org", "plaintex", "rst", "rnoweb", "tex",
    "pandoc", "quarto", "rmd", "context", "xhtml", "mail", "text"
  }
}
lspconfig.texlab.setup {}
lspconfig.marksman.setup {}
lspconfig.pyright.setup {}
lspconfig.r_language_server.setup {}
lspconfig.cssls.setup {
  filetypes = {
    "html", "css", "js", "scss",
  }
}
lspconfig.ts_ls.setup {}
lspconfig.html.setup {}


--transparent.nvim
 -- Optional, you don't have to run setup.
require("transparent").setup({
})


--[[
--Override Filetype-Specific Settings
vim.api.nvim_create_autocmd("Filetype", {
  pattern = "*",
  command = "setlocal shiftwidth=4 tabstop=4 expandtab"
})
--]]

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})


--uncomment to enable folding
--[[
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
--]]
