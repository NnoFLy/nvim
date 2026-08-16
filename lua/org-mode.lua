local load_org_mode = LoadOnce(function ()
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

vim.api.nvim_create_autocmd("FileType", {
    callback = function (ev)
        vim.keymap.set("n",
            "<leader>oA",
            "<cmd>OrgSuperAgenda!<cr>",
            { noremap = true, silent = true, desc = "Org: open Agenda", buffer = ev.buf }
        )
    end
})
