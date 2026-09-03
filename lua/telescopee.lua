local telescope
local themes
local actions
local builtin
local state

--- Helpers

local function create_image_previewer()
    local image_api = require("image")
    local previewers = require("telescope.previewers")
    local preview_utils = require("telescope.previewers.utils")

    local default_buffer_previewer_maker = previewers.buffer_previewer_maker
    local current_image

    local image_extensions = {
        png = true,
        jpg = true,
        jpeg = true,
        gif = true,
        webp = true,
        avif = true,
    }

    local function clear_image()
        if not current_image then
            return
        end

        pcall(current_image.clear, current_image)
        current_image = nil
    end

    local function is_image_file(filepath)
        local stat = vim.uv.fs_stat(filepath)
        if not stat or stat.type ~= "file" then
            return false
        end

        local ext = filepath:match("%.([^%.]+)$")
        return ext ~= nil and image_extensions[ext:lower()] == true
    end

    -- Telescope caches preview buffers, so filetype_hook is not guaranteed to
    -- run when revisiting an entry. Wrapping buffer_previewer_maker makes image
    -- handling run for every selection, including cached entries/directories.
    return function(filepath, bufnr, opts)
        local image_preview_enabled = opts
            and opts.preview
            and opts.preview.image_preview == true

        if not image_preview_enabled then
            return default_buffer_previewer_maker(filepath, bufnr, opts)
        end

        clear_image()

        -- Keep Telescope's normal preview behavior for directories/text files.
        if not is_image_file(filepath) then
            return default_buffer_previewer_maker(filepath, bufnr, opts)
        end

        local winid = opts.winid
        if not winid
            or not vim.api.nvim_win_is_valid(winid)
            or not vim.api.nvim_buf_is_valid(bufnr)
        then
            return
        end

        -- Leave no binary/text content underneath the terminal image.
        pcall(vim.api.nvim_buf_set_lines, bufnr, 0, -1, false, { "" })

        local width = math.max(vim.api.nvim_win_get_width(winid) - 2, 1)
        local height = math.max(vim.api.nvim_win_get_height(winid) - 2, 1)

        local ok, img = pcall(
            image_api.from_file,
            vim.fn.fnamemodify(filepath, ":p"),
            {
                window = winid,
                buffer = bufnr,
                inline = false,

                x = 1,
                y = 1,
                width = width,
                height = height,

                -- image.nvim defaults to 50% max window height. The Telescope
                -- preview pane should be allowed to use the full assigned area.
                max_width_window_percentage = 100,
                max_height_window_percentage = 100,
            }
        )

        if not ok or not img then
            preview_utils.set_preview_message(
                bufnr,
                winid,
                ok and "Image preview unavailable"
                    or ("Image preview failed: " .. tostring(img))
            )
            return
        end

        current_image = img

        local rendered, render_err = pcall(img.render, img)
        if not rendered then
            clear_image()
            preview_utils.set_preview_message(
                bufnr,
                winid,
                "Image preview failed: " .. tostring(render_err)
            )
        end
    end
end

local function create_file_browser_helpers()
    local wallpaper = require("wallpaper")
    local fb_actions = require("telescope._extensions.file_browser.actions")
    local fb_utils = require("telescope._extensions.file_browser.utils")
    local Path = require("plenary.path")

    local function set_background(_)
        local entry = state.get_selected_entry()
        if not entry then
            return
        end

        local path
        if entry.Path then
            path = entry.Path:absolute()
        else
            path = entry.path or entry.filename or entry.value
        end

        wallpaper.set(path)
    end

    local function open_in_netrw(prompt_bufnr)
        local entry = state.get_selected_entry()
        if not entry then
            return
        end

        local path = entry.Path:parent():absolute()

        actions.close(prompt_bufnr)

        vim.schedule(function()
            vim.cmd("Explore " .. vim.fn.fnameescape(path))
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

    return {
        actions = fb_actions,
        open_in_netrw = open_in_netrw,
        set_background = set_background,
    }
end

local function configure_telescope()
    local previewers = require("telescope.previewers")
    local buffer_previewer_maker = vim.g.neovide
        and previewers.buffer_previewer_maker
        or create_image_previewer()

    local file_browser = create_file_browser_helpers()

    telescope.setup({
        defaults = {
            buffer_previewer_maker = buffer_previewer_maker,
            mappings = {
                i = {
                    ["<Esc>"] = actions.close,
                    ["<C-x>"] = actions.delete_buffer,
                },
            },
        },

        extensions = {
            ["ui-select"] = {
                themes.get_ivy({
                    border = true,
                    layout_config = { height = 0.25 },
                }),
            },

            file_browser = {
                theme = "ivy",
                previewer = true,
                sorting_strategy = "descending",

                preview = {
                    image_preview = true,
                },

                layout_config = {
                    prompt_position = "bottom",
                },

                path = vim.loop.cwd(),
                cwd = vim.loop.cwd(),

                hidden = true,
                no_ignore = true,
                prompt_path = true,
                cwd_to_path = true,
                hide_parent_dir = true,
                grouped = true,

                mappings = {
                    i = {
                        ["<Tab>"] = actions.select_default,
                        ["<C-o>"] = file_browser.open_in_netrw,
                        ["<C-z>"] = file_browser.actions.open,
                        ["<C-j>"] = file_browser.actions.create_from_prompt,
                        ["<C-b>"] = file_browser.set_background,
                    },
                    n = {
                        ["<Tab>"] = actions.select_default,
                        ["o"] = file_browser.open_in_netrw,
                        ["z"] = file_browser.actions.open,
                        ["<C-j>"] = file_browser.actions.create_from_prompt,
                        ["<C-b>"] = file_browser.set_background,
                    },
                },
            },
        },
    })

    pcall(telescope.load_extension, "ui-select")
    pcall(telescope.load_extension, "file_browser")
    pcall(telescope.load_extension, "current_buffer")
    pcall(telescope.load_extension, "scope")
end

--- Loading

local load_telescope = LoadOnce(function()
    local telescope_jump_line = {
        dir = "~/code/personal/telescope-current-buffer.nvim",
        url = "https://github.com/i0i-i0i/telescope-current-buffer.nvim",
    }

    vim.opt.runtimepath:append(telescope_jump_line.dir)

    vim.pack.add({
        "https://github.com/nvim-telescope/telescope.nvim",
        "https://github.com/nvim-telescope/telescope-file-browser.nvim",
        "https://github.com/nvim-telescope/telescope-ui-select.nvim",
    })

    telescope = require("telescope")
    themes = require("telescope.themes")
    actions = require("telescope.actions")
    builtin = require("telescope.builtin")
    state = require("telescope.actions.state")

    configure_telescope()
end)

load_telescope()

--- Shared picker layout

local function ivy_full(telescope_opts)
    load_telescope()

    local defaults = {
        sorting_strategy = "descending",

        layout_config = {
            height = vim.o.lines
                - vim.o.cmdheight
                - (vim.o.laststatus > 0 and 1 or 0),
            width = 0.999,
            preview_cutoff = 5,
            preview_width = 0.65,
            prompt_position = "bottom",
        },

        borderchars = {
            prompt = { " ", " ", " ", " ", " ", " ", " ", " " },
            results = { " ", " ", " ", " ", " ", " ", " ", " " },
            preview = { " ", " ", " ", " ", " ", " ", " ", " " },
        },

        results_title = false,
        preview_title = false,

        mappings = {
            i = {
                ["<Esc>"] = actions.close,
            },
        },
    }

    return themes.get_ivy(
        vim.tbl_deep_extend("force", defaults, telescope_opts or {})
    )
end

local function picker(name, telescope_opts)
    return function()
        load_telescope()

        local opts = telescope_opts
        if type(opts) == "function" then
            opts = opts()
        end

        builtin[name](ivy_full(opts))
    end
end

--- Keymaps

vim.keymap.set("n", "<M-/>", function()
    require("telescope_current_buffer").fuzzy()
end, { desc = "Telescope: grep current buffer" })

vim.keymap.set("n", "<C-f>", "<cmd>Telescope file_browser path=%:p:h select_buffer=true<cr>")

vim.keymap.set("n", "<C-p>", picker("fd"), {
    desc = "Telescope: project files",
})

vim.keymap.set("n", "<M-r>", picker("registers"), {
    desc = "Telescope: registers",
})

vim.keymap.set("n", "<C-n>", "<cmd>tabnew<cr><cmd>Telescope file_browser path=~/SYNC/notes/<cr>", {
    desc = "Telescope: notes",
})

vim.keymap.set("n", "<C-g>", picker("live_grep"), {
    desc = "Telescope: live grep",
})

vim.keymap.set("n", "<C-b>", picker("buffers", {
    previewer = false,
}), {
    desc = "Telescope: buffers",
})

vim.keymap.set("n", "<C-M-b>", "<cmd>Telescope scope buffers<cr>", {
    desc = "Telescope: all scope buffersbuffers",
})

vim.keymap.set({ "n", "t" }, "<M-t>", picker("buffers", {
    default_text = "term://",
    previewer = true,
}), {
    desc = "Telescope: terminal buffers",
})

vim.keymap.set("n", "th", picker("help_tags"), {
    desc = "Telescope: help tags",
})

vim.keymap.set("n", "tm", picker("man_pages"), {
    desc = "Telescope: man pages",
})

vim.keymap.set("n", "tk", picker("keymaps"), {
    desc = "Telescope: keymaps",
})

vim.keymap.set("n", "grs", picker("lsp_workspace_symbols"), {
    desc = "Telescope: lsp symbols",
})

vim.keymap.set("n", "grr", picker("lsp_references"), {
    desc = "Telescope: lsp references",
})

vim.keymap.set("n", "<C-]>", picker("lsp_definitions"), {
    desc = "Telescope: lsp definitions",
})

vim.keymap.set("n", "z=", function()
    load_telescope()
    builtin.spell_suggest(themes.get_cursor({ border = true }))
end, {
    desc = "Telescope: spell suggest",
})
