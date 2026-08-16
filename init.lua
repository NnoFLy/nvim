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

vim.o.signcolumn = "yes:1"
vim.o.number = true
vim.o.relativenumber = true
vim.o.statuscolumn = "%C%l%s"

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldnestmax = 3

vim.opt.foldcolumn = "auto:3"
vim.opt.foldtext = ""

vim.opt.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
}

local startup_group = vim.api.nvim_create_augroup("StartupLazyLoad", { clear = true })

function Defer(fn)
    vim.api.nvim_create_autocmd("VimEnter", {
        group = startup_group,
        once = true,
        callback = function()
            vim.schedule(fn)
        end,
    })
end

function LoadOnce(fn)
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

vim.keymap.set("i", "<C-c>", "<cmd>noh<cr><Esc>", vim.tbl_extend("force", opts, { desc = "Escape" }))
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

vim.api.nvim_create_autocmd("FileType", {
    group = main_group,
    pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "lsp-installer", "sqls_output" },
    callback = function(event)
        vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = event.buf, desc = "Close window" })
    end,
})

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
        vim.cmd.colo("vague")
        return
    else
        is_transparent, theme = false, "stille-hell"
    end
    require("stille").setup({ transparent = is_transparent, terminal_colors = false })
    vim.cmd.colo(theme)
end)

-- Large configs

local load_plenary = LoadOnce(function()
    vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
end)
load_plenary()

---@param name string
---@param load_opts { defer?: boolean } | nil
local function load_large(name, load_opts)
    load_opts = load_opts or {}

    local function load()
        local ok, err = pcall(require, name)

        if not ok then
            vim.notify(
                ("Failed to load %q: %s"):format(name, err),
                vim.log.levels.ERROR
            )
        end

        return ok
    end

    if load_opts.defer then
        Defer(load)
        return
    end

    return load()
end

load_large("utils", { defer = false })
load_large("explorer", { defer = false })
load_large("db", { defer = false })
load_large("org-mode", { defer = false })
load_large("telescopee", { defer = false })

load_large("translate", { defer = true })
load_large("multiple-cursors", { defer = true })
load_large("lsp-config", { defer = true })
load_large("git", { defer = true })
load_large("llm", { defer = true })
