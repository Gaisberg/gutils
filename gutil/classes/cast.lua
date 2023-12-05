---
-- Functions for interacting with spells regarding casting.
-- @module cast
-- @see spell
--
local gutil = ...
local api = gutil.api
local spell = gutil.classes.spell
local cast_timer = api.get_time()

function spell:print(msg)
    if gutil.settings.debug then
        print(msg)
    end
end

---
-- Checks if the spell is castable on the specified target.
--
-- @function spell:castable
-- @param target (Optional) The target on which to check the spell's castability.
-- If nil, the default target is determined based on the spell type.
-- @param stop_casting (Optional) If true, will ignore player casting state.
-- @return boolean True if the spell is castable on the target, false otherwise.
-- @usage local fire_bolt = gutil.classes.spell("Firebolt")
--if fire_bolt:castable(gutil.player.target) then print("I can cast firebolt on my target") end
function spell:castable(target, stop_casting)
    if not self:is_known() then return false end
    if not target then
        if self.is_harmful and gutil.player.target then
            target = gutil.player.target
        elseif self.is_helpful then
            target = gutil.player
        else
            return false
        end
    end
    
    local return_value = false

    if target.guid then
        if ((not gutil.player.casting or stop_casting)
        and not gutil.player.on_global_cooldown
        and not api.is_current_spell(self.id)
        and not api.is_auto_repeat_spell(self.id)
        and self:is_ready())
        or (self.cast_type == "pet" and gutil.player.pet.hp > 0) then
            if target.guid == gutil.player.guid
            or (self.min_range <= target.distance and self.max_range >= target.distance
            or self:in_range(target.guid)
            or self.max_range == 0 and target.distance < 5) then
                if self.cast_time <= 0 or (self.cast_time > 0 and not gutil.player.moving) then
                    return_value = true
                end
            end
        end
    end
    return return_value
end

---
-- Casts the spell on the specified target.
-- Preferred way of casting.
--
-- @function spell:cast
-- @param target (Optional) The target on which to cast the spell.
-- If nil, the default target is determined based on the spell type.
-- @param stop_casting (Optional) If true, stops current casting before initiating the spell cast.
-- @return boolean True if the spell is successfully cast on the target, false otherwise.
-- @usage local fire_bolt = gutil.classes.spell("Firebolt")
--if fire_bolt:cast(gutil.player.target) then return end
function spell:cast(target, stop_casting)
    local return_value = false
    if not target then
        if self.is_harmful and gutil.player.target then
            target = gutil.player.target
        elseif self.is_helpful then
            target = gutil.player
        else
            return false
        end
    end
    if self:castable(target, stop_casting) then
        if
        (api.get_time() - cast_timer) > 0.2 then
            cast_timer = api.get_time()
            if stop_casting and gutil.player.casting then
                gutil.api.stop_casting()
            end
            if self.cast_type == "ground" and self:cast_ground(target)
            or self:cast_facing(target) then
                if target.guid == gutil.player.guid then
                    target.name = "self"
                end
                self:print("[gutil] Casting " .. self.name .." [".. self.id .. "]" .. " on " .. target.name)
                return_value = true
            end
        end
    end

    return return_value
end

---
-- Casts a ground-targeted spell at the specified location.
-- Shouldnt be without spell:castable() first.
--
-- @function spell:cast_ground
-- @param target The target location for the ground-targeted spell.
-- @return boolean True if the spell is successfully cast on the ground, false otherwise.
-- @usage local fire_bolt = gutil.classes.spell("Firebolt")
--if fire_bolt:castable(gutil.player.target) and if fire_bolt:cast_ground(gutil.player.target) then return end
function spell:cast_ground(target)
    local is_mouselooking = false
    if self:is_ready() then
        local x, y, z = api.object_position(target.guid)
            api.cast_spell_by_name(self.name)
            if api.is_mouselooking() then
                is_mouselooking = true
                api.mouselook_stop()
            end
            if api.is_spell_pending(self.id) then
                api.click_position(x, y, z)
            end
            if is_mouselooking then
                api.mouselook_start()
            end
            return true
    else
        return false
    end
end

---
-- Casts the spell at the target, taking into account the player's facing direction and spell type.
-- Shouldnt be used without spell:castable() first.
--
-- @function spell:cast_facing
-- @param target The target on which to cast the spell.
-- @return boolean True if the spell is successfully cast at the target, false otherwise.
-- @usage local fire_bolt = gutil.classes.spell("Firebolt")
--if fire_bolt:castable(gutil.player.target) and if fire_bolt:cast_facing(gutil.player.target) then return end
function spell:cast_facing(target)
    if self.is_helpful
    or ((not self.is_harmful and not self.is_helpful or self.is_harmful) and api.is_unit_facing(gutil.player.guid, target.guid))
    then
        api.cast_spell_by_name(self.name, target.guid)
        return true
    else
        return false
    end
end