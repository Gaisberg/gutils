-- Copy me in the class folder you want to add a profile for.

local gutil = ...
local profile = gutil.profile
local spell = gutil.classes.spell
local buff = gutil.classes.buff
local player = gutil.player
local target = player.target
local enemies = gutil.objects.enemies
local get = gutil.profile_manager.get_setting

profile.name = "This will be shown in profile selection dropbox e.g. MyElementalShaman"
profile.description = "This will show up in profile tab."

profile.spells = {
    water_shield = spell("Water Shield"),
    lightning_bolt = spell("Lightning Bolt"),
}

profile.buffs = {
    water_shield = buff(24398),
}

profile.settings = {
    water_shield = { name = "Water Shield", value = 1},
}

function profile.run()

    if player.combat and player.ready then
        if get("Lightning Bolt") then
            enemies:foreach(function(unit)
                if profile.spells.lightning_bolt:cast(unit) then return end
            end)
        end
    end
    if get("Water Shield") then
        if profile.buffs.water_shield:stacks() <= get("Water Shield") then
            if profile.spells.water_shield:cast() then return end
        end
    end
end