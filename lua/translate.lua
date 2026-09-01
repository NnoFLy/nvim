local pantran

local load_pantran = LoadOnce(function()
    vim.pack.add({ "https://github.com/potamides/pantran.nvim" })

    pantran = require("pantran")

    pantran.setup({
        default_engine = "yandex",

        engines = {
            yandex = { default_source = "auto", default_target = "ru" },
            google = { default_source = "auto", default_target = "ru" },
        },

        ui = {
            width_percentage = 0.9,
            height_percentage = 0.9,
        },
    })
end)

vim.keymap.set("n", "<C-S-y>", function()
    load_pantran()

    vim.ui.select({ "ru", "en" }, {
        prompt = "Select translation target:",
    }, function(choice)
        if not choice then
            return
        end

        vim.cmd(
            ("Pantran mode=interactive source=auto target=%s"):format(choice)
        )
    end)
end, { noremap = true, silent = true, desc = "Translate: interactively" })

vim.keymap.set("n", "<C-S-r>", function()
    load_pantran()
    vim.cmd("Pantran mode=interactive source=auto target=ru")
end, { noremap = true, silent = true, desc = "Translate: to Russian" })

vim.keymap.set("x", "<C-S-r>", function()
    load_pantran()
    return pantran.motion_translate({ target = "ru", mode = "hover" })
end, { noremap = true, silent = true, expr = true, desc = "Translate selection: to Russian" })

vim.keymap.set("n", "<C-S-e>", function()
    load_pantran()
    vim.cmd("Pantran mode=interactive source=auto target=en")
end, { noremap = true, silent = true, desc = "Translate: to English" })

vim.keymap.set("x", "<C-S-e>", function()
    load_pantran()
    return pantran.motion_translate({ target = "en", mode = "hover" })
end, { noremap = true, silent = true, expr = true, desc = "Translate selection: to English" })
