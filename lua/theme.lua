local stille_path = {
    dir = "/home/nnofly/code/personal/stille.nvim",
    url = "https://github.com/I0I-I0I/stille.nvim"
}

if vim.fn.isdirectory(stille_path.dir) == 1 then
    vim.opt.runtimepath:append(stille_path.dir)
else
    vim.pack.add({ stille_path.url })
end

vim.pack.add({
    "https://github.com/vague-theme/vague.nvim",
    "https://github.com/neanias/everforest-nvim",
    "https://github.com/craftzdog/solarized-osaka.nvim",
})

require("gnome-track").setup(function(scheme)
    require("vague").setup({ transparent = true })
    require("solarized-osaka").setup({ transparent = true })
    require("everforest").setup({
        ui_contrast = "high",
        background = "hard",
        italics = true,
        transparent_background_level = 2,
        diagnostic_text_highlight = true,
        spell_foreground = true,
    })

    if scheme == "prefer-dark" then
        require("stille").setup({ transparent = true, terminal_colors = false })

        vim.cmd.colo("stille-leere")
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
    else
        require("stille").setup({ transparent = false, terminal_colors = false })

        vim.cmd.colo("stille-hell")
    end
end)
