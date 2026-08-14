vim.loader.enable()

-- Settings
vim.g.mapleader = " "

vim.o.lazyredraw = true
vim.o.swapfile = false
vim.o.wildmode = "longest:list,full"
vim.o.wildmenu = true
vim.o.showtabline = 1
vim.o.laststatus = 0
vim.o.cmdheight = 1
vim.o.cursorline = true
vim.o.colorcolumn = "120"
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.undofile = true
vim.o.undolevels = 10000000
vim.o.undoreload = 10000000
vim.o.inccommand = "split"
vim.o.termguicolors = true
vim.o.grepprg = "rg --vimgrep --no-heading"
vim.o.path = "**"
vim.o.wildignore =
"**/node_modules/**,**/.git/**,**/__pycache__/**,**/.mypy_cache/**,**/.venv/**,**/.pytest_cache/**,**/.ruff_cache/**"
vim.o.langmap =
"ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯЖ;ABCDEFGHIJKLMNOPQRSTUVWXYZ:,фисвуапршолдьтщзйкыегмцчняжб;abcdefghijklmnopqrstuvwxyz\\;\\,"
vim.o.spell = true
vim.o.spelllang = "en,ru"
vim.o.mousescroll = "ver:1,hor:1"
vim.o.linebreak = true

vim.o.autocomplete = false
vim.o.pumheight = 5
vim.o.winborder = "rounded"

vim.opt.complete = {
  "o^20", -- 'o' omnifunc, which becomes LSP completion when an LSP attaches
  ".^10", -- '.' current buffer
  "w^10", -- 'w' buffers in other windows
  "b^10", -- 'b' loaded buffers
  "u^10", -- 'u' unloaded buffers
}

vim.opt.completeopt = {
    "menu",
    "menuone",
    "noinsert",
    "fuzzy",
    "popup",
}

vim.o.signcolumn = "yes:1"
vim.o.number = true
vim.o.relativenumber = true
vim.o.statuscolumn = "%C%l%s"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 2

vim.opt.foldcolumn = "auto:2"
vim.opt.foldtext = ""

vim.opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
}

local startup_group = vim.api.nvim_create_augroup("StartupLazyLoad", { clear = true })

local function defer(fn)
    vim.api.nvim_create_autocmd("VimEnter", {
        group = startup_group,
        once = true,
        callback = function()
            vim.schedule(fn)
        end,
    })
end

local function load_once(fn)
    local loaded = false
    return function()
        if loaded then
            return
        end
        loaded = true
        local ok, err = pcall(fn)
        if not ok then
            loaded = false
            error(err)
        end
    end
end

local ok_ui, ui2 = pcall(require, "vim._core.ui2")
if ok_ui then
    ui2.enable({ enable = true, msg = { target = "msg" } })
end

-- Abbreviations
vim.cmd.cabbrev("W w")
vim.cmd.cabbrev("Wa wa")
vim.cmd.cabbrev("n norm")

-- Keymaps
local opts = { silent = true, noremap = true }

vim.keymap.set("i", "<C-c>", "<Esc>", vim.tbl_extend("force", opts, { desc = "Escape" }))
vim.keymap.set({ "n", "x" }, "j", function()
    if vim.v.count == 0 then
        return "gj"
    else
        return "j"
    end
end, vim.tbl_extend("force", opts, { expr = true, remap = true, desc = "Move down by display line" }))
vim.keymap.set({ "n", "x" }, "k", function()
    if vim.v.count == 0 then
        return "gk"
    else
        return "k"
    end
end, vim.tbl_extend("force", opts, { expr = true, remap = true, desc = "Move up by display line" }))
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "J", "mzJ`z", vim.tbl_extend("force", opts, { desc = "Join line and keep cursor" }))
vim.keymap.set("n", "n", "nzzzv", vim.tbl_extend("force", opts, { desc = "Next search result centered" }))
vim.keymap.set("n", "N", "Nzzzv", vim.tbl_extend("force", opts, { desc = "Previous search result centered" }))
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", vim.tbl_extend("force", opts, { desc = "Move selection up" }))
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", vim.tbl_extend("force", opts, { desc = "Move selection down" }))
vim.keymap.set("v", "L", ">gv", { noremap = true, silent = true, desc = "Indent selection and keep active" })
vim.keymap.set("v", "H", "<gv", { noremap = true, silent = true, desc = "Unindent selection and keep active" })
vim.keymap.set("n", "\\", "za", { noremap = true, silent = true, desc = "Toggle fold" })
vim.keymap.set("n", "<leader>\\", "zA", { noremap = true, silent = true, desc = "Toggle fold" })

vim.keymap.set("n", "<leader>O", function()
    local file = vim.fn.expand("%:h")
    local os = vim.loop.os_uname().sysname
    local cmd
    if os == "Linux" then
        cmd = "xdg-open"
    elseif os == "Darwin" then
        cmd = "open"
    elseif os == "Windows" then
        cmd = "explorer"
    end
    vim.fn.system(cmd .. " " .. file)
end, vim.tbl_extend("force", opts, { desc = "Open explorer from current file" }))

vim.keymap.set("n", "<C-s>", "<cmd>sp term://tmux-sessionizer<cr><cmd>startinsert<cr>", opts)

vim.keymap.set("v", "<M-w>", function()
    vim.cmd([[norm! "+y]])
end, vim.tbl_extend("force", opts, { desc = "Copy" }))
vim.keymap.set({ "n" }, "<M-w>", "\"+y", vim.tbl_extend("force", opts, { desc = "Copy" }))
vim.keymap.set({ "n", "v", "i", "c", "t" }, "<M-y>", function()
    vim.api.nvim_paste(vim.fn.getreg("+"), true, -1)
end, vim.tbl_extend("force", opts, { desc = "Paste" }))

vim.keymap.set("n", "gw", "<cmd>bp|bd #<cr>", vim.tbl_extend("force", opts, { desc = "Close current buffer" }))
vim.keymap.set("n", "gW", "<cmd>bp|bd! #<cr>", vim.tbl_extend("force", opts, { desc = "Force close current buffer" }))

vim.keymap.set({ "n", "v" }, "<C-e>", "4<C-e>", vim.tbl_extend("force", opts, { desc = "Scroll down 4 lines" }))
vim.keymap.set({ "n", "v" }, "<C-y>", "4<C-y>", vim.tbl_extend("force", opts, { desc = "Scroll up 4 lines" }))
vim.keymap.set("n", "<M-p>", "<cmd>cprev<CR>zz", vim.tbl_extend("force", opts, { desc = "Previous quickfix item" }))
vim.keymap.set("n", "<M-n>", "<cmd>cnext<CR>zz", vim.tbl_extend("force", opts, { desc = "Next quickfix item" }))

vim.keymap.set({ "n", "i" }, "<M-l>", "<cmd>t.<cr>",
    vim.tbl_extend("force", opts, { desc = "Duplicate current line" }))
vim.keymap.set("x", "<M-l>", ":t'><cr>gv", vim.tbl_extend("force", opts, { desc = "Duplicate selection" }))

vim.keymap.set({ "n", "t", "i" }, "<M-i>", "<cmd>tabprevious<cr>",
    vim.tbl_extend("force", opts, { desc = "Previous tab" }))
vim.keymap.set({ "n", "t", "i" }, "<M-o>", "<cmd>tabnext<cr>",
    vim.tbl_extend("force", opts, { desc = "Next tab" }))
vim.keymap.set({ "n", "t", "i" }, "<M-S-o>", "<cmd>tabmove +<cr>",
    vim.tbl_extend("force", opts, { desc = "Move tab right" }))
vim.keymap.set({ "n", "t", "i" }, "<M-S-i>", "<cmd>tabmove -<cr>",
    vim.tbl_extend("force", opts, { desc = "Move tab left" }))

vim.keymap.set({ "c", "i" }, "<C-a>", "<Home>", opts)
vim.keymap.set({ "c", "i" }, "<C-e>", "<End>", opts)
vim.keymap.set({ "c", "i" }, "<C-b>", "<Left>", opts)
vim.keymap.set({ "c", "i" }, "<C-f>", "<Right>", opts)
vim.keymap.set("i", "<C-p>", "<Up>", opts)
vim.keymap.set("i", "<C-n>", "<Down>", opts)

vim.keymap.set("i", "<M-u>", "<C-o>gUw<C-o>w", opts)
-- vim.keymap.set("i", "<M-l>", "<C-o>guw<C-o>w", opts)
vim.keymap.set("i", "<M-c>", "<C-o>guw<C-o>~<C-o>w", opts)

vim.keymap.set({ "c", "i" }, "<M-b>", "<C-Left>", opts)
vim.keymap.set({ "c", "i" }, "<M-f>", "<C-Right>", opts)

vim.keymap.set("i", "<C-k>", "<C-o>D", opts)
vim.keymap.set({ "c", "i" }, "<M-BS>", "<C-w>", opts)
vim.keymap.set("i", "<M-d>", "<C-o>dw", opts)

vim.keymap.set("i", "", "<cmd>undo<cr>", opts)
vim.keymap.set("i", "<M-/>", "<cmd>redo<cr>", opts)

_G.cmdline_kill_to_end = function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    return line:sub(1, pos - 1)
end

vim.keymap.set( "c", "<C-k>", [[<C-\>e v:lua.cmdline_kill_to_end()<CR>]], { noremap = true })

-- Auto commands
local main_group = vim.api.nvim_create_augroup("MainGroup", { clear = true })

vim.api.nvim_create_autocmd("BufWritePre", {
    group = main_group,
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = main_group,
    callback = function()
        vim.hl.hl_op({ higroup = "IncSearch", timeout = 150 })
    end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
    group = main_group,
    callback = function(event)
        if event.match:match("^%w%w+:[\\/][\\/]") then
            return
        end
        local file = vim.uv.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Plugins
local load_plenary = load_once(function()
    vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
end)
defer(load_plenary)

-- WhichKey
local load_which_key = load_once(function()
    vim.pack.add({ "https://github.com/folke/which-key.nvim" })
    require("which-key").setup()
end)
defer(load_which_key)

-- Undotree
local load_undotree = load_once(function()
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
local load_img_clip = load_once(function()
    vim.pack.add({ "https://github.com/HakonHarnes/img-clip.nvim" })
    require("img-clip").setup({})
end)

vim.keymap.set({ "n", "i" }, "<M-S-y>", function()
    load_img_clip()
    vim.cmd("PasteImage")
end, { noremap = true, silent = true, desc = "Img-clip: paste image from clipboard" })

-- Tree-sitter
local load_treesitter = load_once(function()
    vim.pack.add({ "https://github.com/romus204/tree-sitter-manager.nvim" })
    require("tree-sitter-manager").setup({
        auto_install = true,
        highlight = true,
        ensure_installed = { "markdown", "markdown_inline", "latex", "svelte", "html", "css", "javascript", "typescript" },
    })
end)
defer(load_treesitter)

-- File explorer
local load_fyler = load_once(function()
    vim.pack.add({ "https://github.com/A7Lavinraj/fyler.nvim" })
    require("fyler").setup({
        use_as_default_explorer = true,
        auto_confirm_simple_mutation = true,
        win_opts = {
            spell = false,
            nu = true,
            rnu = true,
            statuscolumn = "",
            foldcolumn = "0",
        },
        extensions = {
            git = { enabled = true, inline = false },
            trash = { enabled = true },
            watcher = { enabled = true }
        },
        ui = { hidden_items = { switches = {} } },
        mappings = {
            n = { ["<Tab>"] = { action = "select" } },
        },
    })

    vim.keymap.set("n", "-", vim.cmd.Fyler, { desc = "Fyler: open" })
end)
load_fyler()

-- Surround
local load_surround = load_once(function()
    vim.pack.add({
        {
            src = "https://github.com/kylechui/nvim-surround",
            version = vim.version.range("4.x")
        }
    })
end)
defer(load_surround)

-- Telescope
local telescope
local themes
local actions
local builtin

local load_telescope = load_once(function()
    vim.pack.add({
        "https://github.com/nvim-telescope/telescope.nvim",
        "https://github.com/nvim-telescope/telescope-file-browser.nvim",
    })

    telescope = require("telescope")
    themes = require("telescope.themes")
    actions = require("telescope.actions")
    builtin = require("telescope.builtin")

    local fb_actions = require("telescope._extensions.file_browser.actions")

    local action_state = require("telescope.actions.state")
    local Path = require("plenary.path")
    local fb_utils = require("telescope._extensions.file_browser.utils")

    local function open_in_fyler(prompt_bufnr)
        local entry = action_state.get_selected_entry()
        if not entry then
            return
        end

        local path = entry.Path:parent():absolute()

        actions.close(prompt_bufnr)

        vim.schedule(function()
            require("fyler").open({
                root_path = path,
            })
        end)
    end

    fb_utils.relative_path_prefix = function(finder)
        if not finder.prompt_path then
            return nil
        end

        local path = finder.path
        local sep = Path.path.sep

        if path:sub(-1) ~= sep then
            path = path .. sep
        end

        return path
    end

    telescope.setup({
        defaults = {
            mappings = {
                i = {
                    ["<Esc>"] = actions.close,
                    ["<C-x>"] = actions.delete_buffer,
                },
            },
        },
        extensions = {
            file_browser = {
                theme = "ivy",

                previewer = false,
                sorting_strategy = "descending",

                layout_config = {
                    prompt_position = "bottom",
                },

                path = vim.loop.cwd(),
                cwd = vim.loop.cwd(),

                hidden = true,
                prompt_path = true,
                cwd_to_path = true,
                hide_parent_dir = true,
                grouped = true,

                mappings = {
                    ["i"] = {
                        ["<Tab>"] = actions.select_default,
                        ["<C-o>"] = open_in_fyler,
                        ["<C-z>"] = fb_actions.open,
                        ["<C-j>"] = fb_actions.create_from_prompt,
                    },
                    ["n"] = {
                        ["<Tab>"] = actions.select_default,
                        ["o"] = open_in_fyler,
                        ["z"] = fb_actions.open,
                        ["<C-j>"] = fb_actions.create_from_prompt,
                    },
                },
            },
        },
    })

    pcall(telescope.load_extension, "file_browser")
end)
defer(load_telescope)

local function ivy_full(telescope_opts)
    load_telescope()
    return themes.get_ivy(vim.tbl_deep_extend("force", {
        sorting_strategy = "descending",
        layout_config = {
            height = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus > 0 and 1 or 0),
            width = 0.999,
            -- prompt_position = "top",
            preview_cutoff = 5,
            preview_width = 0.65,
            prompt_position = "bottom",
        },
        borderchars = {
            prompt  = { " ", " ", " ", " ", " ", " ", " ", " " },
            results = { " ", " ", " ", " ", " ", " ", " ", " " },
            preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        },
        results_title = false,
        preview_title = false,
        mappings = { i = { ["<Esc>"] = actions.close } },
    }, telescope_opts or {}))
end

local function T(picker, telescope_opts)
    return function()
        builtin[picker](ivy_full(telescope_opts))
    end
end

vim.keymap.set("n", "<C-f>", ":Telescope file_browser path=%:p:h select_buffer=true<CR>")
vim.keymap.set({ "n" }, "<C-p>", T("fd"), { desc = "Telescope: project files" })
vim.keymap.set({ "n" }, "<C-g>", T("live_grep"), { desc = "Telescope: live grep" })
vim.keymap.set({ "n" }, "<C-b>", T("buffers", { previewer = false }), { desc = "Telescope: buffers" })
vim.keymap.set({ "n", "t" }, "<M-t>", T("buffers", { default_text = "term://", previewer = true }),
    { desc = "Telescope: terminal buffers" })
vim.keymap.set({ "n" }, "th", T("help_tags"), { desc = "Telescope: help tags" })
vim.keymap.set({ "n" }, "tm", T("man_pages"), { desc = "Telescope: man pages" })
vim.keymap.set({ "n" }, "tk", T("keymaps"), { desc = "Telescope: keymaps" })
vim.keymap.set("n", "grs", T("lsp_workspace_symbols"), { desc = "Telescope: lsp symbols" })
vim.keymap.set("n", "grr", T("lsp_references"), { desc = "Telescope: lsp references" })
vim.keymap.set("n", "<C-]>", T("lsp_definitions"), { desc = "Telescope: lsp definitions" })
vim.keymap.set("n", "z=", function()
    load_telescope()
    builtin.spell_suggest(themes.get_cursor({ border = true }))
end, { desc = "Telescope: spell suggest" })

-- Git integration
local gitsigns

local load_git = load_once(function()
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
defer(load_git)

vim.keymap.set({ "n", "t", "i" }, "<M-S-g>", function()
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
vim.keymap.set({ "n", "t" }, "<leader>gp", function()
    load_git()
    gitsigns.preview_hunk()
end, { desc = "Git: preview hunk" })
vim.keymap.set({ "n", "t" }, "<leader>gQ", function()
    load_git()
    gitsigns.setqflist("all")
end, { desc = "Git: quickfix all hunks" })
vim.keymap.set({ "n", "t" }, "<leader>gq", function()
    load_git()
    gitsigns.setqflist()
end, { desc = "Git: quickfix buffer hunks" })
vim.keymap.set({ "n", "t" }, "<leader>gr", function()
    load_git()
    gitsigns.reset_hunk()
end, { desc = "Git: reset hunk" })
vim.keymap.set("n", "<leader>gS", function()
    load_git()
    vim.cmd("Gitsigns stage_buffer")
end, { desc = "Git: stage current file" })
vim.keymap.set("n", "<leader>gs", function()
    load_git()
    vim.cmd("Gitsigns stage_hunk")
end, { desc = "Git: stage current hunk" })
vim.keymap.set("n", "<leader>gU", function()
    load_git()
    vim.cmd("Gitsigns reset_buffer_index")
end, { desc = "Git: unstage current file" })
vim.keymap.set("n", "<leader>gu", function()
    load_git()
    vim.cmd("Gitsigns undo_stage_hunk")
end, { desc = "Git: unstage current hunk" })
vim.keymap.set({ "n", "t" }, "<leader>gb", function()
    load_git()
    gitsigns.blame()
end, { desc = "Git: blame current line" })
vim.keymap.set({ "n", "t" }, "<leader>gd", function()
    load_git()
    vim.cmd("CodeDiff")
end, { desc = "Git: explorer (git status)" })
vim.keymap.set({ "n", "t" }, "<leader>gh", function()
    load_git()
    vim.cmd("CodeDiff history")
end, { desc = "Git: history" })
vim.keymap.set({ "n", "t" }, "<leader>gH", function()
    load_git()
    vim.cmd("GitTimeMachine")
end, { desc = "Git: history" })

-- Fidget
local load_fidget = load_once(function()
    vim.pack.add({ "https://github.com/j-hui/fidget.nvim" })
    require("fidget").setup({})
end)
defer(load_fidget)

-- Grapple
local load_grapple = load_once(function()
    vim.pack.add({ "https://github.com/cbochs/grapple.nvim" })
    require("grapple").setup({ icons = false })
end)

vim.keymap.set("n", "<M-0>", function()
    load_grapple()
    vim.cmd("Grapple tag scope=cwd")
end, { silent = true, noremap = true, desc = "Grapple: tag a file" })
vim.keymap.set("n", "<M-e>", function()
    load_grapple()
    vim.cmd("Grapple toggle_tags scope=cwd")
end, { silent = true, noremap = true, desc = "Grapple: toggle tags menu" })

vim.keymap.set("n", "<C-h>", function()
    load_grapple()
    vim.cmd("Grapple select index=1 scope=cwd")
end, { silent = true, noremap = true, desc = "Grapple: select 1 tag" })
vim.keymap.set("n", "<C-j>", function()
    load_grapple()
    vim.cmd("Grapple select index=2 scope=cwd")
end, { silent = true, noremap = true, desc = "Grapple: select 2 tag" })
vim.keymap.set("n", "<C-k>", function()
    load_grapple()
    vim.cmd("Grapple select index=3 scope=cwd")
end, { silent = true, noremap = true, desc = "Grapple: select 3 tag" })
vim.keymap.set("n", "<C-l>", function()
    load_grapple()
    vim.cmd("Grapple select index=4 scope=cwd")
end, { silent = true, noremap = true, desc = "Grapple: select 4 tag" })

for i = 1, 9 do
    vim.keymap.set("n", "<M-" .. i .. ">", function()
        load_grapple()
        vim.cmd("Grapple select index=" .. i .. " scope=cwd")
    end, { silent = true, noremap = true, desc = "Grapple: select " .. i .. " tag" })
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "grapple" },
    callback = function(args)
        vim.keymap.set("n", "<M-k>", "<cmd>m -2<cr>",
            { silent = true, noremap = true, desc = "Move selection up", buffer = args.buf })
        vim.keymap.set("n", "<M-j>", "<cmd>m +1<cr>",
            { silent = true, noremap = true, desc = "Move selection down", buffer = args.buf })
    end,
})

-- AI

local load_copilot = load_once(function ()
    vim.pack.add({ "https://github.com/github/copilot.vim" })
end)
load_copilot()

-- Cloak

local load_camouflage = load_once(function()
    vim.pack.add({ "https://github.com/zeybek/camouflage.nvim" })
    require("camouflage").setup({})
end)
load_camouflage()

vim.keymap.set("n", "<leader>ct", "<cmd>CamouflageToggle<cr>", { desc = "Toggle Camouflage" })
vim.keymap.set("n", "<leader>cr", "<cmd>CamouflageReveal<cr>", { desc = "Reveal Line" })
vim.keymap.set("n", "<leader>cy", "<cmd>CamouflageYank<cr>", { desc = "Yank Value" })
vim.keymap.set("n", "<leader>cf", "<cmd>CamouflageFollowCursor<cr>", { desc = "Follow Cursor" })

-- Multicursors
local mc
local load_multicursor = load_once(function()
    vim.pack.add({ "https://github.com/jake-stewart/multicursor.nvim" })
    mc = require("multicursor-nvim")
    mc.setup()

    mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<M-S-k>", function() mc.lineSkipCursor(-1) end, { desc = "Multicursor: skip line" })
        layerSet({ "n", "x" }, "<M-S-j>", function() mc.lineSkipCursor(1) end, { desc = "Multicursor: skip line" })
        layerSet({ "n", "v" }, "<M-S-n>", function() mc.matchSkipCursor(1) end, { desc = "Multicursor: skip match" })
        layerSet({ "n", "v" }, "<M-S-p>", function() mc.matchSkipCursor(-1) end, { desc = "Multicursor: skip match" })
        layerSet({ "n", "x" }, "<M-h>", mc.prevCursor, { desc = "Multicursor: prev cursor" })
        layerSet({ "n", "x" }, "<M-l>", mc.nextCursor, { desc = "Multicursor: next cursor" })
        layerSet({ "n", "x" }, "<M-x>", mc.deleteCursor, { desc = "Multicursor: delete cursor" })
        layerSet({ "n", "x" }, "<M-d>", mc.deleteCursor, { desc = "Multicursor: delete cursor" })
        layerSet("n", { "<C-[>" }, function()
            if not mc.cursorsEnabled() then
                mc.enableCursors()
            else
                mc.clearCursors()
            end
        end, { desc = "Multicursor: enable/clear cursors" })
    end)
end)

vim.keymap.set({ "n", "x" }, "<M-a>", function()
    load_multicursor()
    mc.matchAllAddCursors()
end, { desc = "Multicursor: add all matches" })
vim.keymap.set({ "n", "x" }, "<M-q>", function()
    load_multicursor()
    mc.toggleCursor()
end, { desc = "Multicursor: toggle cursor" })
vim.keymap.set({ "n" }, "<M-k>", function()
    load_multicursor()
    mc.lineAddCursor(-1)
end, { desc = "Multicursor: add cursor above" })
vim.keymap.set({ "n" }, "<M-j>", function()
    load_multicursor()
    mc.lineAddCursor(1)
end, { desc = "Multicursor: add cursor below" })
vim.keymap.set({ "v" }, "<M-j>", function()
    load_multicursor()
    mc.matchAddCursor(1)
end, { desc = "Multicursor: next match" })
vim.keymap.set({ "v" }, "<M-k>", function()
    load_multicursor()
    mc.matchAddCursor(-1)
end, { desc = "Multicursor: previous match" })

vim.keymap.set("x", "I", function()
    load_multicursor()
    mc.insertVisual()
end, { desc = "Multicursor: insert at starts" })
vim.keymap.set("x", "A", function()
    load_multicursor()
    mc.appendVisual()
end, { desc = "Multicursor: append at ends" })

-- LSP
local lsp_servers = {
    "lua_ls",
    "basedpyright",
    "ruff",
    "svelte",
    "vtsls",
    -- "tsgo",
    "wc_ls",
    "oxlint",
    "oxfmt",
    "biome",
    "cssls",
    "emmet_language_server",
    "html",
    "clangd",
}

local load_lsp = load_once(function()
    vim.pack.add({
        "https://github.com/mason-org/mason.nvim",
        "https://github.com/mason-org/mason-lspconfig.nvim",
        "https://github.com/neovim/nvim-lspconfig",
    })

    require("mason").setup()
    require("mason-lspconfig").setup({
        automatic_enable = false,
        ensure_installed = lsp_servers,
    })

    local capabilities = vim.lsp.protocol.make_client_capabilities()
    vim.lsp.config("*", { capabilities = capabilities })
    vim.lsp.enable(lsp_servers)
end)
defer(load_lsp)

vim.keymap.set("n", "grd", function()
    for _, client in ipairs(vim.lsp.get_clients()) do
        if client.supports_method and client:supports_method("workspace/diagnostic") then
            vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
        end
    end
    vim.defer_fn(function()
        vim.diagnostic.setqflist({
            open = true,
            title = "Workspace diagnostics",
        })
        vim.cmd("wincmd p")
    end, 500)
end, { silent = true, desc = "LSP: workspace diagnostics" })

vim.diagnostic.config({
    jump = {
        on_jump = function(_, bufnr)
            vim.diagnostic.open_float({ bufnr = bufnr, scope = "cursor", focus = false })
        end,
    },
    signs = false,
    underline = true,
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("LspOnAttach", { clear = true }),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end
        vim.lsp.semantic_tokens.enable(false, { bufnr = args.buf })
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
        end
    end,
})

-- Utils
local load_colorizer = load_once(function()
    vim.pack.add({ "https://github.com/catgoose/nvim-colorizer.lua" })
    require("colorizer").setup({})
end)
defer(load_colorizer)

-- Org mode

local load_org_mode = load_once(function ()
    vim.pack.add({
        "https://github.com/nvim-orgmode/orgmode",
        "https://github.com/hamidi-dev/org-super-agenda.nvim",
    })

    local org_dir = "~/SYNC/notes"

    require("orgmode").setup({
        org_agenda_files = org_dir .. "/**/*",
        org_default_notes_file = org_dir .. "/todo.org",

        org_todo_keywords = {
          "TODO(t)",
          "IN-PROGRESS(p!)",
          "|",
          "DONE(d!)",
          "CANCELLED(c@)",
        },

        org_agenda_skip_scheduled_if_done = true,
        org_agenda_skip_deadline_if_done = true,

        org_agenda_span = "day",

        org_agenda_show_future_repeats = "next",

        org_deadline_warning_days = 7,

        org_log_done = "time",
        org_log_into_drawer = "LOGBOOK",

        win_split_mode = "float",

        org_capture_templates = {
            t = {
                description = "Todo",
                target = org_dir .. "/todo.org",

                template = [[
* TODO %^{Title}
:PROPERTIES:
:CREATED: %U
:END:
%?]],
            },

            b = {
                description = "Tidbit: quote, zinger, one-line or textlet",
                target = org_dir .. "/tidbit.org",
                headline = "Tidbits",

                template = [[
** %^{Name}

=%^{Tidbit type|command|zinger|one-liner|textlet}=
%?]],
            },

            i = {
                description = "Ideas",
                target = org_dir .. "/ideas.org",

                template = [[
* %^{Title}	%U
%?]],
            },

            j = {
                description = "Journal entry",
                target = org_dir .. "/journal.org",
                datetree = true,

                template = [[
**** %^{Title}	%U
%?]],
            },
        },
    })

    vim.lsp.enable("org")

    local terminal = {
        DONE = true,
        CANCELLED = true,
    }

    local function active(item)
        return item.todo_state ~= nil
        and not terminal[item.todo_state]
    end

    require("org-super-agenda").setup({
        org_directories = { org_dir },
        todo_states = {
            {
                name = "TODO",
                shortcut = "t",
                keymap = "ot",
                color = "#FF5555",
                strike_through = false,
                fields = {
                    "filename",
                    "todo",
                    "headline",
                    "priority",
                    "date",
                    "tags",
                },
            },

            {
                name = "IN-PROGRESS",
                shortcut = "i",
                keymap = "oi",
                color = "#BD93F9",
                strike_through = false,
                fields = {
                    "filename",
                    "todo",
                    "headline",
                    "priority",
                    "date",
                    "tags",
                },
            },

            {
                name = "DONE",
                shortcut = "d",
                keymap = "od",
                color = "#50FA7B",
                strike_through = true,
                fields = {
                    "filename",
                    "todo",
                    "headline",
                    "priority",
                    "date",
                    "tags",
                },
            },

            {
                name = "CANCELLED",
                shortcut = "c",
                keymap = "oc",
                color = "#6272A4",
                strike_through = true,
                fields = {
                    "filename",
                    "todo",
                    "headline",
                    "priority",
                    "date",
                    "tags",
                },
            },
        },

        groups = {
            {
                name = "Overdue",
                matcher = function(item)
                    if not active(item) then
                        return false
                    end

                    return
                    (item.deadline and item.deadline:is_past())
                    or (item.scheduled and item.scheduled:is_past())
                end,
                sort = {
                    by = "date_nearest",
                    order = "asc",
                },
            },

            {
                name = "Today",
                matcher = function(item)
                    if terminal[item.todo_state] then
                        return false
                    end

                    local scheduled_today =
                    item.scheduled
                    and item.scheduled:days_from_today() == 0

                    local deadline_today =
                    item.deadline
                    and item.deadline:days_from_today() == 0

                    return scheduled_today or deadline_today
                end,

                sort = {
                    by = "scheduled_time",
                    order = "asc",
                },
            },

            {
                name = "Important",
                matcher = function(item)
                    return active(item)
                    and item.priority == "A"
                end,

                sort = {
                    by = "date_nearest",
                    order = "asc",
                },
            },

            {
                name = "In progress",
                matcher = function(item)
                    return item.todo_state == "IN-PROGRESS"
                end,

                sort = {
                    by = "date_nearest",
                    order = "asc",
                },
            },

            {
                name = "Upcoming",
                matcher = function(item)
                    if terminal[item.todo_state] then
                        return false
                    end

                    local days = 10

                    local deadline =
                    item.deadline
                    and item.deadline:days_from_today()

                    local scheduled =
                    item.scheduled
                    and item.scheduled:days_from_today()

                    return
                    (deadline and deadline > 0 and deadline <= days)
                    or
                    (scheduled and scheduled > 0 and scheduled <= days)
                end,

                sort = {
                    by = "date_nearest",
                    order = "asc",
                },
            },

            {
                name = "Inbox",
                matcher = function(item)
                    return item.todo_state == "TODO"
                    and not item.scheduled
                    and not item.deadline
                end,

                sort = {
                    by = "priority",
                    order = "asc",
                },
            },
        },

        upcoming_days = 10,

        hide_empty_groups = true,
        allow_duplicates = false,
        show_other_group = true,

        show_tags = true,
        show_filename = true,

        heading_max_length = 80,

        -- "classic" or "compact"
        view_mode = "compact",

        group_sort = {
            by = "date_nearest",
            order = "asc",
        },

    })
end)
load_org_mode()

vim.keymap.set("n", "<leader>oA", "<cmd>OrgSuperAgenda!<cr>", { noremap = true, silent = true, desc = "Org: open Agenda" })

-- Translate

local pantran

local load_pantran = load_once(function()
    vim.pack.add({ "https://github.com/potamides/pantran.nvim" })

    pantran = require("pantran")

    pantran.setup({
        default_engine = "google",

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

-- Theme
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

require("gnome-track").setup(function(scheme)
    local theme, is_transparent
    if scheme == "prefer-dark" then
        is_transparent, theme = true, "stille-leere"
        vim.cmd.colo("everforest")
        return
    else
        is_transparent, theme = false, "stille-hell"
    end
    require("stille").setup({ transparent = is_transparent, terminal_colors = false })
    vim.cmd.colo(theme)
end)
