vim.loader.enable()

-- Settings
vim.g.mapleader = " "

vim.o.lazyredraw = true
vim.o.swapfile = false
vim.o.wildmode = "longest:list,full"
vim.o.wildmenu = true
vim.o.laststatus = 3
vim.o.cmdheight = 0
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
vim.o.linebreak = true
vim.o.winborder = "none"
vim.o.splitright = true
vim.o.mousescroll = "ver:1,hor:1"

vim.o.signcolumn = "yes:1"
vim.o.number = true
vim.o.relativenumber = true
vim.o.statuscolumn = "%C%l%s"

vim.o.foldmethod = "expr"
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldnestmax = 3

vim.o.foldcolumn = "auto:3"
vim.o.foldtext = ""

vim.o.fillchars = {
    -- fold = " ",
    foldopen = "",
    foldclose = "",
    foldsep = "",
}

vim.o.showtabline = 1
vim.o.tabline = "%!v:lua.MyTabLine()"

function MyTabLine()
    local tabs = {}
    local current = vim.fn.tabpagenr()
    local total = vim.fn.tabpagenr("$")

    for i = 1, total do
        local wins = vim.fn.tabpagebuflist(i)
        local bufnr = wins[1]
        local name = vim.fn.bufname(bufnr)

        if name == "" then
            name = "[No Name]"
        else
            name = vim.fn.fnamemodify(name, ":t")
        end

        local label = i .. ": " .. name

        if i == current then
            table.insert(tabs, "%#TabLineSel# " .. label .. " ")
        else
            table.insert(tabs, "%#TabLine# " .. label .. " ")
        end
    end

    table.insert(tabs, "%#TabLineFill#")
    return table.concat(tabs)
end

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
    ui2.enable({
        enable = true,
        msg = {
            targets = {
                default = "msg",
                progress = "msg",
            },
            height = 0.5,
            timeout = 4000,
        },
        cmd = {
            height = 0.5,
        },
    })
end

-- Abbreviations
vim.cmd.cabbrev("W w")
vim.cmd.cabbrev("Wa wa")
vim.cmd.cabbrev("N norm")

-- Keymaps
local opts = { silent = true, noremap = true }

vim.keymap.set("i", "<C-c>", "<cmd>noh<cr><Esc>", vim.tbl_extend("force", opts, { desc = "Escape" }))
vim.keymap.set({ "n", "i" }, "<C-[>", "<cmd>noh<cr><Esc>", vim.tbl_extend("force", opts, { desc = "Escape" }))
vim.keymap.set({ "n", "x" }, "j", function()
    return vim.v.count == 0 and "gj" or "j"
end, vim.tbl_extend("force", opts, { expr = true, remap = false, desc = "Move down by display line" }))
vim.keymap.set({ "n", "x" }, "k", function()
    return vim.v.count == 0 and "gk" or "k"
end, vim.tbl_extend("force", opts, { expr = true, remap = false, desc = "Move up by display line" }))

vim.keymap.set("n", "Q", ":noh<cr>Q", { silent = true })

vim.keymap.set({ "i", "n", "t", "v" }, "<M-1>", "<cmd>tabnext 1<cr>", { desc = "Select 1 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-2>", "<cmd>tabnext 2<cr>", { desc = "Select 2 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-3>", "<cmd>tabnext 3<cr>", { desc = "Select 3 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-4>", "<cmd>tabnext 4<cr>", { desc = "Select 4 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-5>", "<cmd>tabnext 5<cr>", { desc = "Select 5 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-6>", "<cmd>tabnext 6<cr>", { desc = "Select 6 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-7>", "<cmd>tabnext 7<cr>", { desc = "Select 7 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-8>", "<cmd>tabnext 8<cr>", { desc = "Select 8 tab" })
vim.keymap.set({ "i", "n", "t", "v" }, "<M-9>", "<cmd>tabnext 9<cr>", { desc = "Select 9 tab" })

vim.keymap.set("n", "gp", "`[v`]", { desc = "Select pasted text" })
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
vim.keymap.set("n", "<C-w>t", "<cmd>tab term<cr><cmd>startinsert<cr>", { noremap = true, silent = true, desc = "Open term" })
vim.keymap.set({ "n", "t", "v", "i" }, "<C-M-t>", "<cmd>tab term<cr><cmd>startinsert<cr>", { noremap = true, silent = true, desc = "Open term" })
vim.keymap.set({ "n", "t", "v", "i" }, "<C-M-v>", "<cmd>vs term://$SHELL<cr><cmd>startinsert<cr>", { noremap = true, silent = true, desc = "Open term vertical" })
vim.keymap.set({ "n", "t", "v", "i" }, "<C-M-s>", "<cmd>sp term://$SHELL<cr><cmd>startinsert<cr>", { noremap = true, silent = true, desc = "Open term horizontal" })

vim.keymap.set({ "n", "t", "v", "i" }, "<C-M-a>", "<cmd>tab term pi<cr><cmd>startinsert<cr>", { noremap = true, silent = true, desc = "Open term" })

vim.keymap.set("n", "gw", "<cmd>bp|bd #<cr>", vim.tbl_extend("force", opts, { desc = "Close current buffer" }))
vim.keymap.set("n", "gW", "<cmd>bp|bd! #<cr>", vim.tbl_extend("force", opts, { desc = "Force close current buffer" }))
vim.keymap.set({ "i", "v", "n", "t" }, "<C-M-c>", "<cmd>bd!<cr>", { noremap = true, silent = true, desc = "Close window and buffer" })

vim.keymap.set("t", { "<M-[>", "<C-M-[>" }, "<C-\\><C-n>",
    vim.tbl_extend("force", opts, { desc = "Enter normal mode" }))
vim.keymap.set({ "t", "n" }, { "<C-]><C-w>", "<M-w>" }, function()
    vim.cmd("stopinsert")
    local ctrl_w = vim.api.nvim_replace_termcodes("<C-w>", true, false, true)
    vim.api.nvim_feedkeys(ctrl_w, "m", true)
end, vim.tbl_extend("force", opts, { desc = "Exit terminal mode" }))
vim.keymap.set("t", { "<C-]><C-r>", "<M-r>" }, function()
    return "<C-\\><C-n>\"" .. vim.fn.getcharstr() .. "pi"
end, vim.tbl_extend("force", opts, { expr = true, desc = "Paste register in terminal" }))

vim.keymap.set({ "n", "v" }, "<C-e>", "4<C-e>", vim.tbl_extend("force", opts, { desc = "Scroll down 4 lines" }))
vim.keymap.set({ "n", "v" }, "<C-y>", "4<C-y>", vim.tbl_extend("force", opts, { desc = "Scroll up 4 lines" }))
vim.keymap.set("n", "<M-p>", "<cmd>cprev<CR>zz", vim.tbl_extend("force", opts, { desc = "Previous quickfix item" }))
vim.keymap.set("n", "<M-n>", "<cmd>cnext<CR>zz", vim.tbl_extend("force", opts, { desc = "Next quickfix item" }))

vim.keymap.set({ "n", "i" }, "<M-l>", "<cmd>t.<cr>",
    vim.tbl_extend("force", opts, { desc = "Duplicate current line" }))
vim.keymap.set("x", "<M-l>", ":t'><cr>gv", vim.tbl_extend("force", opts, { desc = "Duplicate selection" }))

vim.keymap.set({ "n", "t", "i" }, { "<M-i>", "<C-M-i>" }, "<cmd>tabprevious<cr>",
    vim.tbl_extend("force", opts, { desc = "Previous tab" }))
vim.keymap.set({ "n", "t", "i" }, { "<M-o>", "<C-M-o>" }, "<cmd>tabnext<cr>",
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
vim.keymap.set("i", "<C-space>", "<C-n>", opts)

vim.keymap.set("i", "<M-u>", "<C-o>gUw<C-o>w", opts)
vim.keymap.set("i", "<M-l>", "<C-o>guw<C-o>w", opts)
vim.keymap.set("i", "<M-c>", "<C-o>guw<C-o>~<C-o>w", opts)

vim.keymap.set({ "c", "i" }, "<M-b>", "<C-Left>", opts)
vim.keymap.set({ "c", "i" }, "<M-f>", "<C-Right>", opts)

vim.keymap.set("i", "<C-k>", "<C-o>D", opts)
vim.keymap.set({ "c", "i" }, "<M-BS>", "<C-w>", opts)
vim.keymap.set("c", "<M-d>", "<C-Right><C-w>", opts)
vim.keymap.set("i", "<M-d>", "<C-o>dw", opts)
vim.keymap.set({ "c", "i" }, "<C-d>", "<Del>", opts)

vim.keymap.set("i", { "<C-'>" }, "<Esc>f", opts)

vim.keymap.set("i", { "<C-/>", "" }, "<cmd>undo<cr>", opts)
vim.keymap.set("i", "<M-/>", "<cmd>redo<cr>", opts)

_G.cmdline_kill_to_end = function()
    local line = vim.fn.getcmdline()
    local pos = vim.fn.getcmdpos()
    return line:sub(1, pos - 1)
end

vim.keymap.set("c", "<C-k>", [[<C-\>e v:lua.cmdline_kill_to_end()<CR>]], { noremap = true })

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

vim.api.nvim_create_autocmd("TermOpen", {
    group = main_group,
    callback = function(args)
        vim.opt_local.spell = false
        vim.bo.filetype = "shell"

        vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
            buffer = args.buf,
            callback = function()
                vim.schedule(function()
                    if vim.api.nvim_get_current_buf() == args.buf then
                        vim.cmd("startinsert")
                    end
                end)
            end,
        })

        vim.schedule(function()
            if vim.api.nvim_get_current_buf() == args.buf then
                vim.cmd("startinsert")
            end
        end)
    end,
})

vim.api.nvim_create_autocmd({ "TermRequest" }, {
    group = main_group,
    desc = "Handles OSC 7 dir change requests",
    callback = function(ev)
        local val, n = string.gsub(ev.data.sequence, "\027]7;file://[^/]*", "")
        if n > 0 then
            local dir = val
            if vim.fn.isdirectory(dir) == 0 then
                vim.notify("invalid dir: " .. dir)
                return
            end
            vim.b[ev.buf].osc7_dir = dir
            if vim.api.nvim_get_current_buf() == ev.buf then
                vim.cmd.lcd(dir)
            end
        end
    end
})

vim.api.nvim_create_autocmd("FileType", {
    group = main_group,
    pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "lsp-installer", "sqls_output" },
    callback = function(event)
        vim.keymap.set("n", "q", "<cmd>bd<cr>", { buffer = event.buf, desc = "Close window" })
    end,
})

-- Large configs

local load_plenary = LoadOnce(function()
    vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
end)
load_plenary()

---@param name string
---@param load_opts { defer?: boolean } | nil
local function load_part(name, load_opts)
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

load_part("theme", { defer = false })
load_part("utils", { defer = false })
load_part("explorer", { defer = false })
load_part("db", { defer = false })
load_part("org-mode", { defer = false })
load_part("telescopee", { defer = false })
load_part("sesss", { defer = false })

load_part("completion", { defer = true })
load_part("translate", { defer = true })
load_part("lsp-config", { defer = true })
load_part("git", { defer = true })
-- load_part("llm", { defer = true })
