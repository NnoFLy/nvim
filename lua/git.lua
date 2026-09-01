local gitsigns

local load_git = LoadOnce(function()
    vim.pack.add({
        "https://github.com/MunifTanjim/nui.nvim",
        "https://github.com/NeogitOrg/neogit",
        "https://github.com/lewis6991/gitsigns.nvim",
        "https://github.com/esmuellert/codediff.nvim",
        "https://github.com/dallagi/git-timemachine.nvim",
    })

    require("neogit").setup({
        graph_style = "kitty",
        process_spinner = true,
    })

    gitsigns = require("gitsigns")
    gitsigns.setup({
        sign_priority = 100,
        signcolumn = true,
    })

    require("codediff").setup({
        diff = {
            compute_moves = true,
            jump_to_first_change = false
        },
        explorer = {
            initial_focus = "modified",
            view_mode = "tree"
        }
    })
end)

Defer(load_git())

vim.keymap.set({ "n", "t", "i" }, { "<M-S-g>", "<M-g><M-g>", "<M-g>g" }, function()
    load_git()
    vim.cmd("Neogit")
end, { desc = "Git: open Neogit" })
vim.keymap.set("n", "]c", function()
    load_git()
    gitsigns.next_hunk()
end, { desc = "Git: next hunk" })
vim.keymap.set("n", "[c", function()
    load_git()
    gitsigns.prev_hunk()
end, { desc = "Git: previous hunk" })
vim.keymap.set({ "n" }, "<M-g>p", function()
    load_git()
    gitsigns.preview_hunk()
end, { desc = "Git: preview hunk" })
vim.keymap.set({ "n" }, "<M-g>Q", function()
    load_git()
    gitsigns.setqflist("all")
end, { desc = "Git: quickfix all hunks" })
vim.keymap.set({ "n" }, "<M-g>q", function()
    load_git()
    gitsigns.setqflist()
end, { desc = "Git: quickfix buffer hunks" })
vim.keymap.set({ "n" }, "<M-g>r", function()
    load_git()
    gitsigns.reset_hunk()
end, { desc = "Git: reset hunk" })
vim.keymap.set("n", "<M-g>S", function()
    load_git()
    vim.cmd("Gitsigns stage_buffer")
end, { desc = "Git: stage current file" })
vim.keymap.set("n", "<M-g>s", function()
    load_git()
    vim.cmd("Gitsigns stage_hunk")
end, { desc = "Git: stage current hunk" })
vim.keymap.set("n", "<M-g>U", function()
    load_git()
    vim.cmd("Gitsigns reset_buffer_index")
end, { desc = "Git: unstage current file" })
vim.keymap.set("n", "<M-g>u", function()
    load_git()
    vim.cmd("Gitsigns undo_stage_hunk")
end, { desc = "Git: unstage current hunk" })
vim.keymap.set({ "n" }, "<M-g>b", function()
    load_git()
    gitsigns.blame()
end, { desc = "Git: blame current line" })
vim.keymap.set({ "n" }, "<M-g>d", function()
    load_git()
    vim.cmd("CodeDiff")
end, { desc = "Git: explorer (git status)" })
vim.keymap.set({ "n", "v" }, "<M-g>h", function()
    load_git()
    vim.cmd("CodeDiff history")
end, { desc = "Git: history" })
vim.keymap.set({ "n" }, "<M-g>H", function()
    load_git()
    vim.cmd("GitTimeMachine")
end, { desc = "Git: history" })
