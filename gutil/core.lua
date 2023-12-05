local gutil = ...
local last_update = gutil.api.get_time()
local in_loop = false
gutil.initialized = false

local function load_files()
    local files = {
        "classes/classes.lua",
        "managers/managers.lua",
        "engines/engines.lua",
        "misc/misc.lua",
    }

    for _, file in gutil.api.pairs(files) do
        gutil.api.require(file, gutil)
    end
end

local function load_profile()
    gutil.managers.settings.load()

    local party_type = select(2, gutil.api.is_in_instance())
    if party_type == "party" then
            gutil.settings.active.version = "dungeon"
    elseif party_type == "raid" then
            gutil.settings.active.version = "raid"
    else
        gutil.settings.active.version = "general"
    end

    gutil.managers.profile.load_profile()
    gutil.player.spec = gutil.api.select(2, _G["GetSpecializationInfo"](_G["GetSpecialization"]()))
end

local function initialize()
    load_files()
    gutil.player = gutil.classes.player()
    load_profile()
    gutil.engines.unit:initialize()
    -- gutil.engines.object:initialize()
    gutil.ui.create_spell_warning_frame()
    gutil.initialized = true
end

local function on_update()
    gutil.libs.draw:clearCanvas()
    if gutil.initialized and gutil.settings.enabled then
        in_loop = true
        gutil.player:update()
        if gutil.profile.run and gutil.api.get_time() - last_update >= gutil.settings.pulse_rate then
            gutil.profile.run()
            last_update = gutil.api.get_time()
        end
        -- if gutil.settings.tracker then
        --     gutil.tracker_manager.run()
        -- end
        in_loop = false
    end
end

initialize()
gutil.frame = CreateFrame("Frame")
gutil.frame:RegisterAllEvents()
gutil.frame:SetScript("OnUpdate", function()
    if not in_loop then
        on_update()
    end
end)
gutil.frame:SetScript("OnEvent", function(self, event,...)
    if event == "LOADING_SCREEN_DISABLED" then
        local party_type = select(2, gutil.api.is_in_instance())
        if party_type == "party" then
                gutil.settings.active.version = "dungeon"
        elseif party_type == "raid" then
                gutil.settings.active.version = "raid"
        else
            gutil.settings.active.version = "general"
        end
        gutil.managers.profile.set_profile_settings(gutil.settings.active.version)
    end
    if event == "ACTIVE_TALENT_GROUP_CHANGED" then
        gutil.api.c_timer.After(0.3, function()
            load_profile()
        end)
    end
end)
