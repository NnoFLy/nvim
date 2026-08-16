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
        backend = "kitty",
        processor = "magick_cli",
        hijack_file_patterns = {
            "*.png",
            "*.jpg",
            "*.jpeg",
            "*.gif",
            "*.webp",
            "*.avif",
        },
    })
end)
load_image_preview()

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

-- Fidget
local load_fidget = LoadOnce(function()
    vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
    require("fidget").setup({})
end)
Defer(load_fidget)

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
local load_spearmint = LoadOnce(function ()
    vim.pack.add({ "https://github.com/adithyasource/spearmint.nvim" })
    require("spearmint").setup()
    vim.keymap.set("n", "m", function() Spearmint.set_mark() end)
    vim.keymap.set("n", "'", function() Spearmint.jump() end)
    vim.keymap.set("i", "<M-'>", function()
        Spearmint.jump()
    end)
end)
Defer(load_spearmint)

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

-- Colorizer
local load_colorizer = LoadOnce(function()
    vim.pack.add({ "https://github.com/catgoose/nvim-colorizer.lua" })
    require("colorizer").setup({})
end)
Defer(load_colorizer)
