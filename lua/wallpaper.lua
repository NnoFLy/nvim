local M = {}

local uv = vim.uv

local function notify(message, level)
    vim.schedule(function()
        vim.notify(message, level or vim.log.levels.INFO)
    end)
end

local function run(cmd, opts)
    opts = vim.tbl_extend("force", {
        text = true,
    }, opts or {})

    local result = vim.system(cmd, opts):wait()

    if result.code == 0 then
        return true
    end

    local err = vim.trim(result.stderr or "")
    if err == "" then
        err = vim.trim(result.stdout or "")
    end

    return false, err ~= "" and err or ("command exited with " .. result.code)
end

local function normalize_path(path)
    if not path or path == "" then
        return nil, "No file selected"
    end

    path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))

    local stat = uv.fs_stat(path)

    if not stat then
        return nil, "File does not exist: " .. path
    end

    if stat.type ~= "file" then
        return nil, "Not a file: " .. path
    end

    return path
end

-- -------------------------------------------------------------------------
-- Windows
-- -------------------------------------------------------------------------

local function set_windows(path)
    local powershell

    if vim.fn.executable("pwsh") == 1 then
        powershell = "pwsh"
    elseif vim.fn.executable("powershell.exe") == 1 then
        powershell = "powershell.exe"
    else
        return false, "PowerShell was not found"
    end

    local script = [[
Add-Type @'
using System.Runtime.InteropServices;

public static class NvimWallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(
        uint action,
        uint param,
        string value,
        uint flags
    );
}
'@

$path = [Environment]::GetEnvironmentVariable("NVIM_WALLPAPER")

# SPI_SETDESKWALLPAPER = 0x0014
# SPIF_UPDATEINIFILE | SPIF_SENDCHANGE = 0x0003
if (-not [NvimWallpaper]::SystemParametersInfo(20, 0, $path, 3)) {
    exit 1
}
]]

    return run({
        powershell,
        "-NoProfile",
        "-NonInteractive",
        "-Command",
        script,
    }, {
        env = {
            NVIM_WALLPAPER = path,
        },
    })
end

-- -------------------------------------------------------------------------
-- GNOME
-- -------------------------------------------------------------------------

local function set_gnome(path)
    if vim.fn.executable("gsettings") ~= 1 then
        return false, "gsettings was not found"
    end

    local schema = "org.gnome.desktop.background"
    local uri = vim.uri_from_fname(path)

    local result = vim.system({
        "gsettings",
        "list-keys",
        schema,
    }, {
        text = true,
    }):wait()

    if result.code ~= 0 then
        return false, vim.trim(result.stderr or "Unable to query GNOME settings")
    end

    local keys = result.stdout or ""

    local ok, err = run({
        "gsettings",
        "set",
        schema,
        "picture-uri",
        uri,
    })

    if not ok then
        return false, err
    end

    -- GNOME has a separate wallpaper key for dark mode.
    if keys:find("picture-uri-dark", 1, true) then
        ok, err = run({
            "gsettings",
            "set",
            schema,
            "picture-uri-dark",
            uri,
        })

        if not ok then
            return false, err
        end
    end

    return true
end

-- -------------------------------------------------------------------------
-- COSMIC
-- -------------------------------------------------------------------------

local function ron_escape(value)
    return value
        :gsub("\\", "\\\\")
        :gsub('"', '\\"')
        :gsub("\n", "\\n")
        :gsub("\r", "\\r")
        :gsub("\t", "\\t")
end

local function read_file(path)
    local file, err = io.open(path, "rb")

    if not file then
        return nil, err
    end

    local data = file:read("*a")
    file:close()

    return data
end

local function write_atomic(path, data)
    local tmp = path .. ".nvim-wallpaper.tmp"

    local file, err = io.open(tmp, "wb")
    if not file then
        return false, err
    end

    file:write(data)
    file:close()

    local ok, rename_err = os.rename(tmp, path)

    if not ok then
        os.remove(tmp)
        return false, rename_err
    end

    return true
end

local function cosmic_config_path()
    local config_home = vim.env.XDG_CONFIG_HOME

    if not config_home or config_home == "" then
        config_home = vim.fs.joinpath(vim.env.HOME, ".config")
    end

    return vim.fs.joinpath(
        config_home,
        "cosmic",
        "com.system76.CosmicBackground",
        "v1",
        "all"
    )
end

local function set_cosmic(path)
    local config = cosmic_config_path()

    local data = read_file(config)

    -- If COSMIC hasn't created a user override yet, use its packaged
    -- default as the starting point.
    if not data then
        local default =
            "/usr/share/cosmic/com.system76.CosmicBackground/v1/all"

        data = read_file(default)

        if not data then
            return false,
                "COSMIC background config was not found. Set a wallpaper once in COSMIC Settings first."
        end

        vim.fn.mkdir(vim.fs.dirname(config), "p")
    end

    local source = 'source: Path("' .. ron_escape(path) .. '")'

    local updated, count = data:gsub(
        'source:%s*Path%(%s*".-"%s*%)',
        source,
        1
    )

    if count == 0 then
        return false, "Could not find source: Path(...) in COSMIC config"
    end

    -- A manually selected single image should not behave like a
    -- theme-filtered slideshow.
    updated = updated:gsub(
        "filter_by_theme:%s*%a+",
        "filter_by_theme: false",
        1
    )

    updated = updated:gsub(
        "rotation_frequency:%s*%d+",
        "rotation_frequency: 0",
        1
    )

    return write_atomic(config, updated)
end

-- -------------------------------------------------------------------------
-- Public API
-- -------------------------------------------------------------------------

local function desktop()
    local sysname = uv.os_uname().sysname

    if sysname == "Windows_NT" then
        return "windows"
    end

    local value = table.concat({
        vim.env.XDG_CURRENT_DESKTOP or "",
        vim.env.XDG_SESSION_DESKTOP or "",
        vim.env.DESKTOP_SESSION or "",
    }, ":"):lower()

    if value:find("cosmic", 1, true) then
        return "cosmic"
    end

    if value:find("gnome", 1, true) then
        return "gnome"
    end

    return "unknown"
end

function M.set(path)
    local err

    path, err = normalize_path(path)

    if not path then
        notify(err, vim.log.levels.ERROR)
        return false
    end

    local backend = desktop()

    local ok

    if backend == "windows" then
        ok, err = set_windows(path)
    elseif backend == "gnome" then
        ok, err = set_gnome(path)
    elseif backend == "cosmic" then
        ok, err = set_cosmic(path)
    else
        ok = false
        err = "Unsupported desktop environment"
    end

    if not ok then
        notify(
            "Could not set background: " .. (err or "unknown error"),
            vim.log.levels.ERROR
        )
        return false
    end

    notify("Background: " .. vim.fs.basename(path))

    return true
end

return M
