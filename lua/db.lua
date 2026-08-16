local function load_dotenv(path)
    for _, line in ipairs(vim.fn.readfile(path)) do
        if line ~= "" and not line:match("^%s*#") then
            local key, value = line:match("^([%w_]+)=(.*)$")

            if key then
                value = value:gsub('^"(.*)"$', "%1")
                value = value:gsub("^'(.*)'$", "%1")

                vim.env[key] = value
            end
        end
    end
end

local function get_connections()
    local connections = {}

    for i = 1, 99 do
        local alias = vim.env["DATABASE_" .. i .. "_ALIAS"]
        local driver = vim.env["DATABASE_" .. i .. "_DRIVER"]
        local url = vim.env["DATABASE_" .. i .. "_URL"]

        if not driver and not url then
            break
        end


        if driver and driver ~= "" and url and url ~= "" then
            table.insert(connections, {
                alias = alias or ("database-" .. i),
                driver = driver,
                dataSourceName = url,
            })
        else
            vim.notify(
                ("Incomplete database connection DATABASE_%d_*"):format(i),
                vim.log.levels.WARN
            )
        end
    end

    if #connections == 0 then
        vim.notify(
            "No database connections configured; sqls disabled",
            vim.log.levels.WARN
        )
        return
    end

    return connections
end

--- @param env_file_name string
local function setup_sqls_lsp(env_file_name)
    local env_file = vim.fs.find(env_file_name, {
        upward = true,
        path = vim.fn.getcwd(),
    })[1]

    if env_file then
        load_dotenv(env_file)
    end

    vim.lsp.config("sqls", {
        settings = {
            sqls = {
                connections = get_connections(),
            },
        },
    })
end

local load_db = LoadOnce(function()
    vim.pack.add({ "https://github.com/nanotee/sqls.nvim" })

    setup_sqls_lsp(".env.local")

    vim.lsp.enable("sqls")
end)

local group = vim.api.nvim_create_augroup("pi_user_keymaps", {
    clear = true,
})

local function bmap(buf, modes, lhs, rhs, desc)
    vim.keymap.set(modes, lhs, rhs, {
        buffer = buf,
        silent = true,
        noremap = true,
        desc = desc,
    })
end

vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "sql", "mysql", "plsql" },
    callback = function(ev)
        load_db()

        bmap(ev.buf, { "n", "x" }, "<M-s>q", "<Plug>(sqls-execute-query)", "SQL: execute query")
        bmap(ev.buf, { "n", "x" }, "<M-s>v", "<Plug>(sqls-execute-query-vertical)", "SQL: execute query vertical")
        bmap(ev.buf, "n", "<M-s>c", "<cmd>SqlsSwitchConnection<cr>", "SQL: switch connection")
        bmap(ev.buf, "n", "<M-s>d", "<cmd>SqlsSwitchDatabase<cr>", "SQL: switch database")
        bmap(ev.buf, "n", "<M-s>C", "<cmd>SqlsShowConnections<cr>", "SQL: show connections")
        bmap(ev.buf, "n", "<M-s>D", "<cmd>SqlsShowDatabases<cr>", "SQL: show databases")
    end,
})
