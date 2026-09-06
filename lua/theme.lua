local load_theme = LoadOnce(function ()
    local stille_path = {
        dir = "/home/nnofly/code/personal/stille.nvim",
        url = "https://github.com/NnoFLy/stille.nvim"
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

    local gnome_track_path = {
        dir = "/home/nnofly/code/personal/gnome-track",
        url = "https://github.com/NnoFLy/gnome-track.nvim"
    }

    if vim.fn.isdirectory(gnome_track_path.dir) == 1 then
        vim.opt.runtimepath:append(gnome_track_path.dir)
    else
        vim.pack.add({ gnome_track_path.url })
    end

    ---@param scheme "prefer-dark" | "prefer-light" | "default"
    require("gnome-track").track(function(scheme)
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
            vim.g.neovide_opacity = 0.7

            vim.cmd.colo("stille-leere")
            vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" })
        else
            require("stille").setup({ transparent = false, terminal_colors = false })
            vim.g.neovide_opacity = 1

            vim.cmd.colo("stille-hell")
        end
    end)
end)

load_theme()
