vim.g.loaded_nvim_dir_plugin = 1
vim.g.netrw_hide = 1
vim.g.netrw_list_hide = [[^\.\.\/,^\.\/]]
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 0
vim.g.netrw_browse_split = 0

vim.keymap.set("n", "-", "<cmd>Ex<cr>")

vim.cmd([[
    function! NetrwToggleListStyle(islocal) abort
        let w:netrw_liststyle =
        \ get(w:, 'netrw_liststyle', get(g:, 'netrw_liststyle', 0)) == 3
        \ ? 0
        \ : 3

        return 'refresh'
    endfunction
]])

vim.g.Netrw_UserMaps = {
    { "i", "NetrwToggleListStyle" },
}

local netrw_group = vim.api.nvim_create_augroup("NetrwGroup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = netrw_group,
    pattern = "netrw",
    callback = function(args)
        vim.opt_local.bufhidden = "wipe"
        vim.opt_local.rnu = true
        vim.opt_local.nu = true
        vim.keymap.set("n", "q", "<cmd>bp<cr>",
            { buffer = args.buf, noremap = true, nowait = true, silent = true, desc = "Close netrw" })
    end
})

vim.api.nvim_create_autocmd("FileType", {
    group = netrw_group,
    pattern = "netrw",

    callback = function(ev)
        vim.keymap.set("n", "gb", function()
            local name

            local ok, result = pcall(
                vim.fn["netrw#Call"],
                "NetrwGetWord"
            )

            if ok and type(result) == "string" and result ~= "" then
                name = result
            else
                name = vim.fn.expand("<cfile>")
            end

            name = name:gsub("[*/=@|]$", "")

            local dir = vim.b.netrw_curdir

            if not dir or not name or name == "" then
                return
            end

            require("utils.wallpaper").set(
                vim.fs.joinpath(dir, name)
            )
        end, {
            buffer = ev.buf,
            desc = "Set as desktop background",
        })
    end,
})
