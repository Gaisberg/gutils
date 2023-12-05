---
-- Helper functions to simplify combat rotations.
-- @module functions
--

local gutil = ...
gutil.functions = {}

--- Automatically targets enemies based on specified conditions.
-- This function checks if the auto-target feature is enabled in the profile settings.
-- If enabled, it iterates over the enemy units and targets the closest one within a certain distance.
-- The distance is determined by the type parameter; for "melee," it is set to 5, otherwise 40.
-- @function gutil.functions.auto_target
-- @tparam string type The type of targeting, either "melee" or any other value.
--   If "melee," the distance for targeting is set to 5; otherwise, it is set to 40.
-- @see objects.enemies
-- @see player.target
-- @usage gutil.functions.auto_target("melee") -- Automatically targets enemies within melee range.
-- @usage gutil.functions.auto_target("ranged") -- Automatically targets enemies within a default range.
gutil.functions.auto_target = function(type)
    local distance = 40
    if type == "melee" then
        distance = 5
    end
    if gutil.profile.settings
    and gutil.profile.settings["auto_target"]
    and gutil.profile.settings["auto_target"].value then
        gutil.objects.enemies:foreach(function(enemy)
            if (gutil.player.target.guid == "stub" or gutil.player.target.hp == 0 or gutil.player.target.distance > distance)
            and enemy.guid ~= "stub" and gutil.api.is_unit_facing(gutil.player.guid, enemy.guid)
            and enemy.distance < distance then
                gutil.api.target_unit(enemy.guid)
                return
            end
        end)
    end
end