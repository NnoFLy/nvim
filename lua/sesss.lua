local load_sess = LoadOnce(function ()
    local sess_path = {
        dir = "/home/nnofly/code/personal/sess.nvim",
        url = "https://github.com/I0I-I0I/sess.nvim"
    }

    if vim.fn.isdirectory(sess_path.dir) == 1 then
        vim.opt.runtimepath:append(sess_path.dir)
    else
        vim.pack.add({ sess_path.url })
    end

    require("sess").setup({
        paths = {
            "~/code/personal/*",
            "~/code/work/*",
            "~/SYNC/notes/",
            "~/.config/nvim/",
            "~/.dotfiles/*",
        },
        smart_auto_load = false,
    })

    vim.keymap.set("n", "<C-s>", "<cmd>Sess list<cr>",
        { desc = "List sessions" })
    vim.keymap.set("n", "<M-s>s", "<cmd>Sess save<cr>",
        { desc = "Save session" })
    vim.keymap.set("n", "<M-s>p", "<cmd>Sess pin<cr>",
        { desc = "Pin session" })
    vim.keymap.set("n", "<M-s>l", "<cmd>Sess load<cr>",
        { desc = "Load session" })
    vim.keymap.set("n", "<M-s>u", "<cmd>Sess unload<cr>",
        { desc = "Unload session" })
    vim.keymap.set("n", "<leader><C-^>", "<cmd>Sess last<cr>",
        { desc = "Load the previous session" })
end)

load_sess()
