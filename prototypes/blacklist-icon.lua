local mod_defines = require("defines")

local blacklist_icon = {
    type = "smoke",
    name = "blacklist-icon",
    flags = {"not-repairable", "not-blueprintable", "not-deconstructable", "placeable-off-grid", "not-on-map"},
    duration = 9999999,
    spread_duration = 10,
    fade_away_duration = nil,
    start_scale = 0.1,
    end_scale = 1,
    color = { r = 1, g = 1, b = 1, a = 1 },
    cyclic = true,
    affected_by_wind = false,
    show_when_smoke_off = true,
    movement_slow_down_factor = 0,
    vertical_speed_slowdown = 0,
    render_layer = "selection-box",
    animation =
    {
        filename = mod_defines.MOD_NAME.."/graphics/lock-icon.png",
        width = 16,
        height = 16,
        scale = 0.5,
        frame_count = 1
    }
}

local fading_blacklist_icon = util.table.deepcopy(blacklist_icon)
fading_blacklist_icon.name = "fading-blacklist-icon"
fading_blacklist_icon.duration = 10
fading_blacklist_icon.fade_away_duration = 10
fading_blacklist_icon.spread_duration = 10
fading_blacklist_icon.start_scale = 1
fading_blacklist_icon.end_scale = 0.1

data:extend({blacklist_icon, fading_blacklist_icon})
