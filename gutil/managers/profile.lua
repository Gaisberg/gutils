local gutil = ...
local self = {}
gutil.managers.profile = self
gutil.profile = {}

function self:get_profiles()
    local class = gutil.api.string.lower(gutil.api.unit_class("player"))
    local build = gutil.api.get_build_info()
    class = string.gsub(class, " ", "_")
    local folder = "profiles/"..class.."/"
    local files = gutil.api.get_directory_files(folder)
    local profiles = {}
    for _, v in gutil.api.pairs(files) do
        local name = gutil.api.read_file(folder .. v):match('profile%.name%s-=%s-"(.-)"')
        local version = gutil.api.read_file(folder .. v):match('profile%.game_version%s-=%s-"(.-)"')
        if version == build and name then
            profiles[name] = folder..v
        end
    end
    return profiles
end

function self:load_profile()
    gutil.profile = {}
    local profiles = gutil.managers.profile:get_profiles()
    gutil.api.require(profiles[gutil.settings.active.profile], gutil)
    if not gutil.settings.profiles[gutil.settings.active.profile] then
        gutil.settings.profiles[gutil.settings.active.profile] = {
            general = gutil.profile.settings,
            dungeon = gutil.profile.settings,
            raid = gutil.profile.settings
        }
    end
    gutil.managers.profile:set_profile_settings(gutil.settings.active.version)
    gutil.ui.set_minimap_icon()
end

function self:set_profile_settings(version)
    if version == gutil.settings.active.version then
        for k, v in gutil.api.pairs(gutil.settings.profiles[gutil.settings.active.profile][gutil.settings.active.version]) do
            gutil.profile.settings[k] = v
        end
    end
end

function self:get_setting(name)
    return gutil.profile.settings[name].value
end