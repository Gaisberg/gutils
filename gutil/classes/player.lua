---
-- Player functionality.
-- @classmod player
--

---
-- @type player


local gutil = ...
local player = gutil.classes.player
local pet = gutil.classes.pet
local buff = gutil.classes.buff
local api = gutil.api

---
-- Constructs a new player object.
--
-- Initializes a new player object with information such as player identifier (guid),
-- player name, player class, player specialization, and a unit object representing the player.
--
-- @function player:new
-- @return player The newly created player object.
--
function player:new()
    ---
    -- The unique identifier of the player.
    -- @string[readonly] guid
    self.guid = api.unit_guid("player")
    ---
    -- The name of the player.
    -- @string[readonly] name
    self.name = api.unit_name(self.guid)
    ---
    -- The class of the player.
    -- @string[readonly] class
    self.class = api.unit_class(self.guid)
    ---
    -- The specialization of the player.
    -- @string[readonly] spec
    self.spec = api.select(2, _G["GetSpecializationInfo"](_G["GetSpecialization"]()))
    ---
    -- The player's pet.
    -- @table[readonly] pet
    self.pet = pet()
end

---
-- Updates the state of the player.
--
-- Retrieves and updates information about the player, including the player's unit,
-- readiness status, target information, and various other properties.
--
-- @function player:update
--
function player:update()
    self.pet:update()
    ---
    -- Indicates the readiness of the player.
    -- @bool[readonly] ready True if the player is ready for actions (not mounted, not eating/drinking, not stunned, not pacified, not silenced).
    self.ready = (not api.unit_is_mounted(self.guid)
                    and not buff("Drink"):exists() and not buff("Food"):exists()
                    and not self:is_stunned()  and not self:is_pacified() and not self:is_silenced())

    ---
    -- The current target of the player.
    -- @table[readonly] target A unit object representing the player's target.
    -- @see unit
    local target = gutil.api.unit_target(self.guid)
    if target then
        local type = "enemy"
        if gutil.classes.unit.is_friend(target) then
            type = "friend"
        end

        self.target = gutil.classes.unit(target, 1, type)
        self.target:update()
    else
        self.target = gutil.classes.unit("stub")
    end

    ---
    -- Indicates whether the player is in combat.
    -- @bool[readonly] combat True if the player is in combat, false otherwise.
    self.combat = api.unit_affecting_combat(self.guid)
    ---
    -- The current power value of the player.
    -- @number[readonly] power The current power value of the player.
    self.power = api.unit_power(self.guid)
    ---
    -- Indicates whether the player is currently casting a spell.
    -- @bool[readonly] casting True if the player is casting, false otherwise.
    self.casting = self:is_casting()
    ---
    -- Indicates whether the player is on the global cooldown.
    -- @bool[readonly] on_global_cooldown True if the player is on the global cooldown, false otherwise.
    self.on_global_cooldown = self.global_cooldown()
    ---
    -- The health percentage of the player.
    -- @number[readonly] hp The health percentage of the player.
    self.hp = api.unit_health(self.guid) / api.unit_health_max(self.guid) * 100
end

---
-- Checks if the player is currently casting a spell or channeling.
-- @function player:is_casting
-- @tparam table self The player object.
-- @treturn bool True if the player is casting a spell or channeling, false otherwise.
function player:is_casting()
    local spell = select(9, api.unit_casting_info(self.guid))
    local cspell = select(8, api.unit_channel_info(self.guid))

    if spell or cspell then
        return true
    else
        return false
    end
end

---
-- Checks if the player is in a silenced state.
--
-- Determines whether the player is in a state of silence.
--
-- @function player:is_silenced
-- @return boolean True if the player is silenced, false otherwise.
--
function player:is_silenced()
    local flags = api.unit_flags(self.guid)
    if not flags then
        return false
    end
    return bit.band(flags, 0x00002000) ~= 0
end

---
-- Checks if the player is in a pacified state.
--
-- Determines whether the player is in a state of pacification.
--
-- @function player:is_pacified
-- @return boolean True if the player is pacified, false otherwise.
--
function player:is_pacified()
    local flags = api.unit_flags(self.guid)
    if not flags then
        return false
    end
    return bit.band(flags, 0x00020000) ~= 0

end

---
-- Checks if the player is in a stunned state.
--
-- Determines whether the player is in a state of stun.
--
-- @function player:is_stunned
-- @return boolean True if the player is stunned, false otherwise.
--
function player:is_stunned()
    local flags = api.unit_flags(self.guid)
    if not flags then
        return false
    end
    return bit.band(flags, 0x00040000) ~= 0
end

---
-- Checks if the player is on the global cooldown.
--
-- Determines whether the player is currently on the global cooldown.
--
-- @function player.global_cooldown
-- @return boolean True if the player is on the global cooldown, false otherwise.
--
function player.global_cooldown()
    local cooldown = api.get_spell_cooldown(61304)
    if cooldown ~= 0 then
        return true
    else
        return false
    end
end

---
-- Retrieves the remaining time of the global cooldown.
-- @function player.global_cooldown_remaining
-- @treturn number The remaining time of the global cooldown in seconds.
function player.global_cooldown_remaining()
    local _, value = api.get_spell_cooldown(61304)
    return value
end

---
-- Checks if a specific talent is enabled for the player.
-- @function player.talent_enabled
-- @param input Either the talent's name (string) or its spell ID (number).
-- @treturn bool True if the talent is enabled, false otherwise.
function player.talent_enabled(input)
    if type(input) == "string" then
        input = select(7, api.get_spell_info(input))
    end
    if input then return api.is_player_spell(input) else return false end
end