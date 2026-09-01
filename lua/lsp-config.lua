local lsp_servers = {
    "lua_ls",
    "basedpyright",
    "ruff",
    "svelte",
    "vtsls",
    -- "tsgo",
    "wc_ls",
    "oxlint",
    "oxfmt",
    "biome",
    "cssls",
    "emmet_language_server",
    "html",
    "clangd",
    "sqls",
}

local load_lsp = LoadOnce(function()
    vim.pack.add({
        "https://github.com/mason-org/mason.nvim",
        "https://github.com/mason-org/mason-lspconfig.nvim",
        "https://github.com/neovim/nvim-lspconfig",
    })

    require("mason").setup()
    require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = lsp_servers,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })
    vim.lsp.enable(lsp_servers)
end)
Defer(load_lsp())

vim.keymap.set("n", "grd", function()
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.supports_method and client:supports_method("workspace/diagnostic") then
            vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
        end
    end
    vim.defer_fn(function()
        vim.diagnostic.setqflist({
            open = true,
            title = "Workspace diagnostics",
        })
        vim.cmd("wincmd p")
    end, 500)
end, { silent = true, desc = "LSP: workspace diagnostics" })

vim.diagnostic.config({
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end,
    },
    signs = false,
    underline = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspOnAttach", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        vim.lsp.semantic_tokens.enable(false, { bufnr = args.buf })
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = vim.g.autotrigger })
        end
    end,
})

vim.api.nvim_create_autocmd("LspProgress", {
    callback = function(ev)
        local value = ev.data.params.value
        vim.api.nvim_echo({
            {
                value.message or value.title or "",
                nil,
            },
        }, false, {
            id = "lsp." .. ev.data.params.token,
            kind = "progress",
            source = "vim.lsp",
            title = value.title,
            status = value.kind ~= "end" and "running" or "success",
            percent = value.percentage,
        })
    end,
})

