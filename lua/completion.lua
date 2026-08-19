vim.o.autocomplete = false
vim.o.pumheight = 5
vim.o.pummaxwidth = 40
vim.o.pumblend = 20
vim.g.autotrigger = false

vim.opt.complete = {
    "o^20",  -- 'o' omnifunc, which becomes LSP completion when an LSP attaches
    ".^10",  -- '.' current buffer
    "w^10",  -- 'w' buffers in other windows
    "b^10",  -- 'b' loaded buffers
    "u^10",  -- 'u' unloaded buffers
}

vim.opt.completeopt = {
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
            jump_next = "",
            jump_prev = "",
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

    local expand_or_jump = function()
        local can_expand = #snippets.expand({ insert = false }) > 0

        if can_expand then
            vim.schedule(snippets.expand)
            return ""
        end

        if snippets.session.get() ~= nil then
            snippets.session.jump("next")
            return ""
        end

        return "\t"
    end

    local jump_prev = function()
        if snippets.session.get() ~= nil then
            snippets.session.jump("prev")
            return ""
        end

        return "<S-Tab>"
    end

    vim.keymap.set("i", "<Tab>", expand_or_jump, {
        expr = true,
        noremap = true,
        silent = true,
        desc = "Expand snippet / jump next",
    })

    vim.keymap.set("i", "<S-Tab>", jump_prev, {
        expr = true,
        noremap = true,
        silent = true,
        desc = "Jump previous snippet",
    })
end)

vim.api.nvim_create_autocmd("InsertEnter", {
    callback = load_snippets
})
