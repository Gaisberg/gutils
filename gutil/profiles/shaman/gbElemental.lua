local gutil = ...
local profile = gutil.profile
local spell = gutil.classes.spell
local buff = gutil.classes.buff
local player = gutil.player
local get = gutil.managers.profile.get_setting

profile.name = "Name here..."
profile.description = "Insert profile description here..."
profile.game_version = "game version here... e.g. 10.2.0"

profile.spells = {
    water_shield = spell("Water Shield"),
    lightning_bolt = spell(49238),
}

profile.buffs = {
    water_shield = buff(24398),
}

profile.debuffs = {
    -- debuffs here...
}

profile.settings = {
    water_shield = { name = "Water Shield", value = true},
    lightning_bolt = { name = "Lightning Bolt", value = 100},
}

function profile.run()


    if not profile.buffs.water_shield:exists() then
        if profile.spells.water_shield:cast() then
            return
        end
    end
    if player.combat and player.ready then

        if gutil.player.target.hp < get("lightning_bolt") then
            if profile.spells.lightning_bolt:cast(gutil.player.target) then return end
        end
    end
end