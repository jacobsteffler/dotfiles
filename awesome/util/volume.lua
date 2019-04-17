local awful = require("awful")
local naughty = require("naughty")

local M = {}

local TITLE = "Volume"
local notif_id = nil

local function show_volume_notification(volume)
    local notif

    if notif_id ~= nil then
        notif = naughty.getById(notif_id)

        if notif ~= nil then
            naughty.replace_text(notif, TITLE, volume)
            return
        end
    end
    
    notif = naughty.notify({title = TITLE, text = volume})
    notif_id = notif.id
end

local function get_and_notify_volume()
    awful.spawn.easy_async_with_shell("pulsemixer --get-volume | cut -f 1 -d \" \"", show_volume_notification)
end

function M.raise()
    awful.spawn("pulsemixer --change-volume +5", false)
    get_and_notify_volume()
end

function M.lower()
    awful.spawn("pulsemixer --change-volume -5", false)
    get_and_notify_volume()
end

function M.mute()
    awful.spawn("pulsemixer --toggle-mute", false)
end

return M
