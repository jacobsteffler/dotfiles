local awful = require("awful")
local gears = require("gears")

local M = {}

M.terminal = "alacritty"
M.editor = "vim"
M.editor_cmd = M.terminal .. " -e " .. M.editor

local function spawn_once_pgrep(cmd, with_shell)
    local pgrep_match

    if type(cmd) == "table" then pgrep_match = cmd[1]
    else pgrep_match = cmd end

    local split_path = gears.string.split(pgrep_match, "/")
    local path_count = 0
    for _ in pairs(split_path) do path_count = path_count + 1 end
    pgrep_match = split_path[path_count]


    awful.spawn.easy_async_with_shell("pgrep -x -u $USER " .. pgrep_match, function(out, err, rsn, code)
        if code ~= 0 then
            if with_shell then awful.spawn.with_shell(cmd)
            else awful.spawn(cmd, false) end
        end
    end)
end

spawn_once_pgrep("/home/jacob/scripts/dex_launcher")
spawn_once_pgrep("compton")
spawn_once_pgrep("flameshot")

return M
