local load_sess = LoadOnce(function()
    local sess_path = {
        dir = vim.fn.expand("~/code/personal/sess.nvim"),
        url = "https://github.com/NnoFLy/sess.nvim",
    }

    if vim.fn.isdirectory(sess_path.dir) == 1 then
        vim.opt.runtimepath:prepend(sess_path.dir)
    else
        vim.pack.add({ sess_path.url })
    end

    local statusline = vim.o.statusline

    local sess = require("sess")

    local ok, err = sess.setup({
        paths = {
            "~/code/personal/*",
            "~/code/work/*",
            "~/SYNC/notes/",
            "~/.config/nvim/",
            "~/.dotfiles/*",
        },
        smart_auto_load = false,
        hooks = {
            after_operation = function(context)
                local current = context.current
                -- Session names are literal text, not statusline format strings.
                local session = current and ("[" .. current.metadata.name:gsub("%%", "%%%%") .. "] ") or ""
                vim.o.statusline = session .. statusline
            end,
        },
    })

    if not ok then
        error(err)
    end

    require("telescope").load_extension("sess")

    vim.keymap.set({ "n", "t", "i" }, "<C-M-s>", "<cmd>Sess list<cr>",
        { desc = "List sessions" })
    vim.keymap.set({ "n", "t", "i" }, "<C-s>", "<cmd>Sess active<cr>",
        { desc = "List active sessions and agents" })
    vim.keymap.set("n", "<M-s>s", "<cmd>Sess save<cr>",
        { desc = "Save session" })
    vim.keymap.set("n", "<M-s>p", "<cmd>Sess pin<cr>",
        { desc = "Pin session" })
    vim.keymap.set("n", "<M-s>l", "<cmd>Sess load<cr>",
        { desc = "Load session" })
    vim.keymap.set("n", "<M-s>u", "<cmd>Sess unload<cr>",
        { desc = "Unload session" })
    vim.keymap.set({ "n", "t", "i" }, "<M-q>", "<cmd>Sess last<cr>",
        { desc = "Load the previous session" })
end)

load_sess()
