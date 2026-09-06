vim.o.autocomplete = false
vim.o.pumheight = 5
vim.o.pummaxwidth = 40
vim.o.pumblend = 5

vim.g.autotrigger = false

vim.o.complete = {
    "o^20",  -- 'o' omnifunc, which becomes LSP completion when an LSP attaches
    ".^10",  -- '.' current buffer
    "w^10",  -- 'w' buffers in other windows
    "b^10",  -- 'b' loaded buffers
    "u^10",  -- 'u' unloaded buffers
}

vim.o.completeopt = {
    "menu",
    "menuone",
    "noinsert",
    "fuzzy",
    "popup",
}

local load_snippets = LoadOnce(function()
    vim.pack.add({
        { src = "https://github.com/nvim-mini/mini.snippets" },
        { src = "https://github.com/rafamadriz/friendly-snippets" },
    })
    local snippets = require("mini.snippets")

    snippets.setup({
        snippets = {
            snippets.gen_loader.from_lang(),
        },

        mappings = {
            expand = "",
            jump_next = "<tab>",
            jump_prev = "<S-tab>",
            stop = "<C-c>",
        },

        expand = {
            match = function(snips)
                return snippets.default_match(snips, {
                    pattern_fuzzy = "%S+",
                })
            end,
        },
    })

    snippets.start_lsp_server({
        match = false,
    })
end)

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = load_snippets
})
