local gutil = ...
local self = {}
local json = gutil.libs.json
local filename = "settings/" .. string.lower(gutil.api.string.gsub(gutil.api.get_realm_name(), " ", "_")) .."_" .. string.lower(gutil.api.unit_name("player")) ..".json"
gutil.managers.settings = self
gutil.settings = {}

local defaults = {
    enabled = false,
    active = {profile = nil, version = "general"},
    debug = false,
    tracker = false,
    pulse_rate = 0.1,
    profiles = {}
}

gutil.settings = defaults

local function load_file()
    local return_value = gutil.settings
    if gutil.api.file_exists(filename) then
        local e_values = gutil.api.read_file(filename)
        if e_values then
            local d_values = json:decode(e_values)
            for k, v in gutil.api.pairs(d_values) do
                return_value[k] = v
            end
        end
    end
    return return_value
end

local function write_settings(settings)
    gutil.api.write_file(filename, json:encode_pretty(settings), false)
end

function self:save(write)
    local settings = {
        enabled = gutil.settings.enabled,
        active = gutil.settings.active,
        debug = gutil.settings.debug,
        tracker = gutil.settings.tracker,
        pulse_rate = gutil.settings.pulse_rate,
        profiles = gutil.settings.profiles
    }
    if gutil.settings.active.profile then
        if not settings.profiles[gutil.settings.active.profile] then
            settings.profiles[gutil.settings.active.profile] = { [gutil.settings.active.version] = gutil.profile.settings }
        end
        settings.profiles[gutil.settings.active.profile][gutil.settings.active.version] = gutil.profile.settings
    end

    if write then
        write_settings(settings)
    end
end

function self:load()
    local settings = gutil.settings

    if not settings.profiles[gutil.settings.active.profile] then
        for k, v in gutil.api.pairs(load_file()) do
            settings[k] = v
        end
    end

    for k, v in gutil.api.pairs(settings) do
        gutil.settings[k] = v
    end
end

self.frame = CreateFrame("Frame")
self.frame:RegisterEvent("PLAYER_LEAVING_WORLD")
self.frame:SetScript("OnEvent", function(_, event,...)
    if event == "PLAYER_LEAVING_WORLD" then
        self:save(true)
    end
end)