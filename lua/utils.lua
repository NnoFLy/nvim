-- WhichKey
local load_which_key = LoadOnce(function()
    vim.pack.add({ "https://github.com/folke/which-key.nvim" })
    require("which-key").setup()
end)
Defer(load_which_key)

-- Undotree
local load_undotree = LoadOnce(function()
    vim.cmd.packadd("nvim.undotree")
end)

vim.keymap.set("n", "<leader>u", function()
    load_undotree()
    require("undotree").open()
end, { silent = true, noremap = true, desc = "Undotree: open" })

vim.api.nvim_create_autocmd("FileType", {
    pattern = "nvim-undotree",
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, desc = "Undotree: close" })
        vim.opt_local.rnu = false
        vim.opt_local.nu = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
    end,
})

-- Paste image
local load_img_clip = LoadOnce(function()
    vim.pack.add({ "https://github.com/HakonHarnes/img-clip.nvim" })
    require("img-clip").setup({})
end)

vim.keymap.set({ "n", "i" }, "<M-S-y>", function()
    load_img_clip()
    vim.cmd("PasteImage")
end, { noremap = true, silent = true, desc = "Img-clip: paste image from clipboard" })

local load_image_preview = LoadOnce(function ()
    vim.pack.add({ "https://github.com/3rd/image.nvim" })

    require("image").setup({
        hijack_file_patterns = {
            "*.png",
            "*.jpg",
            "*.jpeg",
            "*.gif",
            "*.webp",
            "*.avif",
        },
        backend = "kitty",
        processor = "magick_cli",

        integrations = {
            org = {
                enabled = true,
                filetypes = { "org" },
                only_render_image_at_cursor = false,
                only_render_image_at_cursor_mode = "inline",
            },
        },

        max_height_window_percentage = 50,
        max_width_window_percentage = 50,
    })
end)
if not vim.g.neovide then
    load_image_preview()
end

-- Local buffer
local load_scope = LoadOnce(function ()
    vim.pack.add({ "https://github.com/tiagovla/scope.nvim" })
    require("scope").setup({})
end)
Defer(load_scope)

-- Tree-sitter
local load_treesitter = LoadOnce(function()
    vim.pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })
    require("tree-sitter-manager").setup({
        auto_install = true,
        highlight = true,
        ensure_installed = { "markdown", "markdown_inline", "latex", "svelte", "html", "css", "javascript", "typescript" },
    })
end)
load_treesitter()

-- Surround
local load_surround = LoadOnce(function()
    vim.pack.add({
        {
            src = "https://github.com/kylechui/nvim-surround",
            version = vim.version.range("4.x")
        }
    })
end)
Defer(load_surround)

-- QuickFix
local load_qf = LoadOnce(function()
    vim.pack.add({ "https://github.com/stevearc/quicker.nvim" })
    require("quicker").setup({
        keys = {
            {
                ">",
                function() require("quicker").expand({ before = 2, after = 2, add_to_existing = true }) end,
                desc = "Expand quickfix context",
            },
            {
                "<",
                function() require("quicker").collapse() end,
                desc = "Collapse quickfix context",
            },
        },
    })
end)
Defer(load_qf)

-- Marks
local load_gm = LoadOnce(function()
    local gm_path = {
        dir = "/home/nnofly/code/personal/gm.nvim",
        url = "https://github.com/NnoFLy/gm.nvim"
    }

    if vim.fn.isdirectory(gm_path.dir) == 1 then
        vim.opt.runtimepath:append(gm_path.dir)
    else
        vim.pack.add({ gm_path.url })
    end

    local gm = require("gm")
    gm.setup()

    vim.keymap.set("n", "m", gm.set_mark, { desc = "Set mark" })
    vim.keymap.set("n", "'", gm.jump_to_mark, { desc = "Jump to mark" })
    vim.keymap.set("n", "<M-e>", gm.edit_marks)
end)
Defer(load_gm)

-- Cloak
local load_cloak = LoadOnce(function()
    vim.pack.add({ "https://github.com/laytan/cloak.nvim" })
    require("cloak").setup({
        cloak_on_leave = true,
        cloak_length = 8,
        patterns = {
            {
                file_pattern = {
                    ".env",
                    ".env.*",
                },
                cloak_pattern = "=.+",
            },
            {
                file_pattern = {
                    "*.yaml",
                    "*.yml",
                },
                cloak_pattern = {
                    "password:.+",
                    "PASSWORD:.+",
                    "token:.+",
                    "TOKEN:.+",
                    "secret:.+",
                    "SECRET:.+",
                },
            },
        },
    })
end)
load_cloak()

-- Screenkey
local load_screenkey = LoadOnce(function()
    vim.pack.add({ "https://github.com/NStefan002/screenkey.nvim" })
    require("screenkey").setup()
end)

vim.keymap.set("n", "<leader>s", function()
    load_screenkey()
    vim.cmd.Screenkey()
end, { desc = "Screenkey: Toggle" })

-- Colorizer
local load_colorizer = LoadOnce(function()
    vim.pack.add({ "https://github.com/catgoose/nvim-colorizer.lua" })
    require("colorizer").setup({})
end)
Defer(load_colorizer)
