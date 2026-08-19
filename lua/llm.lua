local load_copilot = LoadOnce(function ()
    vim.pack.add({ "https://github.com/github/copilot.vim" })
end)
load_copilot()

local pi

local load_pi = LoadOnce(function()
    vim.pack.add({
        "https://github.com/zgs225/pi2.nvim",
        "https://github.com/HakonHarnes/img-clip.nvim"
    })
    pi = require("pi")

    pi.setup({
        render = { engine = "builtin" },
        layout = {
            default = "float",
            side = {
                position = "right",
                width = math.min(100, math.max(80, math.floor(vim.o.columns * 0.40))),
            },
            float = { width = 0.80, height = 0.85, border = "rounded" },
        },
        attention = {
            auto_open_on_prompt_focus = true,
            notify_on_completion = true,
        },
    })
end)

-----------------------------------------------------------------------
-- Global mappings
-----------------------------------------------------------------------

local map = vim.keymap.set

-- Main UI.
map("n", { "<leader>pf", "<M-g>" }, function()
    load_pi()
    pi.show()
end, { desc = "Pi: open" })

map("v", { "<leader>pf", "<M-g>" }, function ()
    load_pi()
    vim.cmd("<Cmd>PiSendMention<CR>")
end, { desc = "Pi: mention file/selection" })

map("n", "<leader>pc", function()
    load_pi()
    pi.continue_session()
end, { desc = "Pi: continue session" })

map("n", "<leader>pa", function ()
    load_pi()
    pi.attention()
end, { desc = "Pi: attention" })

-----------------------------------------------------------------------
-- Pi: buffer mappings
-----------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("pi_user_keymaps", {
    clear = true,
})

local function bmap(buf, modes, lhs, rhs, desc)
    vim.keymap.set(modes, lhs, rhs, {
        buffer = buf,
        silent = true,
        desc = desc,
    })
end

-- Shared across history / prompt / attachments.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = {
        "pi-chat-history",
        "pi-chat-prompt",
        "pi-chat-attachments",
    },
    callback = function(ev)
        bmap(ev.buf, { "n", "i" }, "<M-g>", pi.toggle_chat, "Pi: hide chat")
        bmap(ev.buf, { "n", "i" }, "<M-c>", pi.abort, "Pi: abort")
        bmap(ev.buf, { "n", "i" }, "<M-o>", pi.toggle_history_blocks, "Pi: toggle history blocks")
        bmap(ev.buf, { "n", "i" }, "<M-s>", pi.sessions, "Pi: sessions")
        bmap(ev.buf, { "n", "i" }, "<M-d>", pi.diff_review, "Pi: session diff")
        bmap(ev.buf, { "n", "i" }, "<M-r>", pi.resume_session, "Pi: resume session")
        bmap(ev.buf, { "n", "i" }, "<M-l>", pi.toggle_layout, "Pi: toggle layout")
    end,
})

-----------------------------------------------------------------------
-- History
-----------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "pi-chat-history",
    callback = function(ev)
        bmap(ev.buf, "n", "<M-j>", pi.focus_chat_prompt, "Pi: focus prompt")
    end,
})

-----------------------------------------------------------------------
-- Prompt
-----------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "pi-chat-prompt",
    callback = function(ev)
        -- Navigation works without leaving insert mode.
        bmap(ev.buf, { "n", "i" }, "<M-k>", pi.focus_chat_history, "Pi: focus history")
        bmap(ev.buf, { "n", "i" }, "<M-j>", pi.focus_chat_attachments, "Pi: focus attachments")

        -- Scroll conversation while continuing to type.
        bmap(ev.buf, { "n", "i" }, "<C-u>", function()
            pi.scroll_chat_history("up", 12)
        end, "Pi: scroll history up")

        bmap(ev.buf, { "n", "i" }, "<C-d>", function()
            pi.scroll_chat_history("down", 12)
        end, "Pi: scroll history down")

        -- Fast actions while composing a prompt.
        bmap(ev.buf, { "n", "i" }, "<M-m>", pi.select_model, "Pi: cycle model")
        bmap(ev.buf, { "n", "i" }, "<M-t>", pi.cycle_thinking_level, "Pi: cycle thinking")
        bmap(ev.buf, { "n", "i" }, "<M-n>", pi.new_session, "Pi: new session")
        bmap(ev.buf, { "n", "i" }, "<M-x>", pi.compact, "Pi: compact context")
        bmap(ev.buf, { "n", "i" }, "<M-S-y>", pi.paste_image, "Pi: paste image")
    end,
})

-----------------------------------------------------------------------
-- Attachments
-----------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "pi-chat-attachments",
    callback = function(ev)
        bmap(ev.buf, { "n", "i" }, "<M-k>", pi.focus_chat_prompt,
            "Pi: focus prompt")

        bmap(ev.buf, { "n", "i" }, "<M-S-y>", pi.paste_image,
            "Pi: paste image")
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = "pi-chat-prompt",
    callback = function(ev)
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(ev.buf) then
                return
            end

            local function get_mapping(mode, lhs)
                for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(ev.buf, mode)) do
                    if mapping.lhs == lhs then
                        return mapping
                    end
                end
            end

            local insert_submit = get_mapping("i", "<CR>")
            local normal_submit = get_mapping("n", "<CR>")

            -- Shift + Enter = submit prompt.
            if insert_submit and insert_submit.callback then
                vim.keymap.set("i", "<S-CR>", insert_submit.callback, {
                    buffer = ev.buf,
                    desc = "Submit π prompt",
                })
            end

            if normal_submit and normal_submit.callback then
                vim.keymap.set("n", "<S-CR>", normal_submit.callback, {
                    buffer = ev.buf,
                    desc = "Submit π prompt",
                })
            end

            -- Enter = ordinary newline while typing.
            vim.keymap.set("i", "<CR>", "<CR>", {
                buffer = ev.buf,
                noremap = true,
                desc = "Insert newline",
            })
        end)
    end,
})
