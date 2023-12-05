---
-- Unit functionality.
-- @classmod unit
--

---
-- @type unit

local gutil = ...
local api = gutil.api
local unit = gutil.classes.unit

---
-- Constructs a new unit object.
--
-- Initializes a new unit object with information such as unit identifier (guid), unit name,
-- target information, distance, time to die (TTD), and depth (recursion level).
--
-- @function unit:new
-- @param guid The identifier of the unit.
-- @param depth (Optional) The depth of the unit in the hierarchy. Defaults to 0.
-- @return unit The newly created unit object.
--
function unit:new(guid, depth, type)
    if not depth then depth = 0 end
    if not guid or depth >= 3 then return {} end
    ---
    -- The unique identifier of the unit.
    -- @string[readonly] guid
    self.guid = guid
    if guid == "stub" then
        self.name = "stub"
        self.hp = -1
        self.distance = 999
        self.moving = false
        self.ttd = -1
        self.threat = -1
        self.distance = 999
    else
        ---
        -- The name of the unit.
        -- @string[readonly] name
        self.name = api.unit_name(self.guid)
    end
    if not depth then
        self.depth = 0
    else
        self.depth = depth + 1
    end
    if type then
        self[type] = true
    end
end

---
-- Updates the state of the unit.
--
-- Retrieves and updates information about the unit, including its position, enemy/friend status,
-- health percentage, distance to player, target information, combat status, casting status, and more.
--
-- @function unit:update
--
function unit:update()
    if self.enemy then
        ---
        -- The health percentage of the unit.
        -- @number[readonly] hp The health percentage of the unit.
        self.hp = api.unit_health(self.guid) / api.unit_health_max(self.guid) * 100
        ---
        -- The distance between the player and the unit.
        -- @number[readonly] distance The distance between the player and the unit.
        self.distance = api.distance("player", self.guid) or 999
        ---
        -- The target of the unit.
        -- @table[readonly] target The target of the unit.
        -- @see api.unit_target
        self.target = api.unit_target(self.guid)
        ---
        -- The target of the target of the unit.
        -- @table[readonly] target_of_target The target of the target of the unit.
        -- @see api.unit_target
        self.target_of_target = api.unit_target(self.target)
        ---
        -- Indicates whether the unit is currently moving.
        -- @bool[readonly] moving True if the unit is moving, false otherwise.
        -- @see api.is_moving
        self.moving = api.is_moving(self.guid)
        ---
        -- The time to die (TTD) of the unit.
        -- @number[readonly] ttd The time to die of the unit.
        -- @see unit:calculate_ttd
        self.ttd = self:calculate_ttd()
        ---
        -- The threat level of the unit towards the player.
        -- @number[readonly] threat The threat level of the unit towards the player.
        self.threat = select(2, gutil.api.get_threat("player", self.guid)) or 0
    elseif self.friend then
        self.hp = self:calculate_hp()
        ---
        -- The role of the unit.
        -- @string[readonly] role The role of the unit.
        -- @see unit:get_role
        self.role = self:get_role()
    end
end

---
-- Calculates the health percentage of the unit.
--
-- Calculates and returns the health percentage of the unit, considering incoming heals if in a group.
--
-- @function unit:calculate_hp
-- @return number The health percentage of the unit.
--
function unit:calculate_hp()
    local health = api.unit_health(self.guid)
    local max_health = api.unit_health_max(self.guid)
    local incoming_health = gutil.api.unit_get_incoming_heals(self.guid) or 0
    local calc_health = health + incoming_health
    if calc_health > max_health then calc_health = max_health end
    return calc_health / max_health * 100
end

---
-- Retrieves the role of the unit.
--
-- Retrieves and returns the role of the unit (tank, healer, damage) if the unit is a friendly player.
--
-- @function unit:get_role
-- @return string The role of the unit.
--
function unit:get_role()
    return gutil.api.get_role(self.guid)
end

---
-- Checks if the unit is a boss.
-- Thanks to BR for this!
--
-- Determines whether the unit is a boss based on classification, health, and instance information.
--
-- @function unit:is_boss
-- @return boolean True if the unit is a boss, false otherwise.
--
function unit:is_boss()
    local class = gutil.api.unit_classification(self.guid)
    local max = gutil.api.unit_health_max(self.guid)
    local p_max = gutil.api.unit_health_max("player")
    local instance = gutil.api.is_in_instance()
    local compare = max > 4 * p_max

    if self:is_instance_boss() or self.is_dummy(self.guid)
        or (not class == "trivial" and instance ~= "party"
            and ((class == "rare" and compare) or class == "rareelite" or class == "worldboss"
                or (class == "elite" and ((compare and instance ~= "raid") or instance == "scenario")) or api.unit_level(self.guid) < 0)) then
        return true
    else
        return false
    end
end

---
-- Checks if the unit is a boss in the current instance.
--
-- Determines whether the unit is a boss in the current instance based on encounter and boss information.
--
-- @function unit:is_instance_boss
-- @return boolean True if the unit is a boss in the current instance, false otherwise.
--
function unit:is_instance_boss()
    if gutil.api.is_in_instance() then
        local total = select(3, api.get_instance_lock_time_remaining())
        for i = 1, total do
            if api.object_exists(self.guid) then
                local boss_name = api.get_instance_lock_time_remaining_encounter(i)
                if self.name == boss_name then return true end
            end
        end
        for i = 1, 5 do
            local num = "boss" .. i
            if self.guid == api.unit_guid(num) then return true end
        end
    end
    return false
end

---
-- Calculates the estimated time to die (TTD) of the unit.
--
-- Calculates and returns the estimated TTD of the unit based on historical health data.
--
-- @function unit:calculate_ttd
-- @return number The estimated TTD of the unit.
--
function unit:calculate_ttd()
    local time = api.get_time()
    if self.is_dummy(self.guid) then return -1 end
    if self.hp == 0 then return -1 end
    if self.hp == 100 then return -1 end


    if not self.cache then
        self.cache = { values = {}, time = 0, hp = self.hp, start_time = time, last_time = 0 }
        return -1
    end

    if self.hp ~= self.cache.last_hp or (time - self.cache.start_time - self.cache.last_time) > 0.5 then
        local value = { time = time - self.cache.start_time, hp = self.hp }
        tinsert(self.cache.values, 1, value)
        self.cache.last_hp = self.hp
        self.cache.last_time = time - self.cache.start_time
    end

    local count = #self.cache.values
    if count > 0 and (count > 100 or (time - self.cache.start_time - self.cache.values[count].time) > 10) then
        self.cache.values[count] = nil
        count = count - 1
    end

    if count > 1 then
        local a, b = 0, 0
        local ex2, ex, exy, ey = 0, 0, 0, 0
        local x, y
        for i = 1, count do
            x, y = self.cache.values[i].time, self.cache.values[i].hp
            ex2 = ex2 + x * x
            ex = ex + x
            exy = exy + x * y
            ey = ey + y
        end
        local invariant = 1 / (ex2 * count - ex * ex)
        a = (-ex * exy * invariant) + (ex2 * ey * invariant)
        b = (count * exy * invariant) - (ex * ey * invariant)
        if b ~= 0 then
            local ttd_sec = (0 - a) / b
            ttd_sec = math.min(999, ttd_sec - (time - self.cache.start_time))
            if ttd_sec > 0 then
                return ttd_sec
            end
        end
    end
end

---
-- Checks if the unit is currently casting or channeling a spell.
--
-- Determines whether the unit is currently casting or channeling a spell.
--
-- @function unit:is_casting
-- @return boolean True if the unit is casting or channeling, false otherwise.
--
function unit:is_casting()
    local spell = select(9, api.unit_casting_info(self.guid))
    local cspell = select(8, api.unit_channel_info(self.guid))

    if spell or cspell then
        return true
    else
        return false
    end
end

---
-- Checks if the unit is a dummy.
--
-- Determines whether the unit is a dummy based on its name.
--
-- @function unit.is_dummy
-- @param guid The identifier of the unit to check.
-- @return boolean True if the unit is a dummy, false otherwise.
--
function unit.is_enemy(guid)
    if guid == "stub" then return false end
    local has_threat
    gutil.objects.friends:foreach(function (o)
        if select(3, api.get_threat(o.guid, guid)) ~= nil then
            has_threat = true
            return
        end
    end)
    return api.unit_can_attack("player", guid) and ((api.unit_affecting_combat(guid) and api.unit_is_tapped(guid) and has_threat) or unit.is_dummy(guid))
end

---
-- Checks if the unit is a dummy.
--
-- Determines whether the unit is a dummy based on its name.
--
-- @function unit.is_dummy
-- @param guid The identifier of the unit to check.
-- @return boolean True if the unit is a dummy, false otherwise.
--
function unit.is_dummy(guid)
    return api.string.find(string.lower(api.unit_name(guid)), "dummy")
end

---
-- Checks if the unit is a friendly player.
--
-- Determines whether the unit is a friendly player based on not being dead or a ghost, and party/raid membership.
--
-- @function unit.is_friend
-- @param guid The identifier of the unit to check.
-- @return boolean True if the unit is a friendly player, false otherwise.
--
function unit.is_friend(guid)
    return not gutil.api.unit_is_dead_or_ghost(guid) and (api.unit_player_or_pet_in_group(guid))
end

---
-- Retrieves enemies within a specified range and matching optional criteria.
--
-- Retrieves and returns a table of enemies within the specified range and matching optional criteria.
--
-- @function unit:get_enemies_in_range
-- @param range The maximum range to consider for enemies.
-- @param criteria (Optional) A function to filter enemies based on additional criteria.
-- @return table A table of enemies within the specified range and matching the criteria.
--
function unit:get_enemies_in_range(range, criteria)
    local enemies = gutil.engines.object_table()
    gutil.objects.enemies:foreach(function(o)
        local distance = api.distance(self.guid, o.guid)
        if distance <= range then
            if criteria and criteria(o) then
                enemies:add(o)
            elseif not criteria then
                enemies:add(o)
            end
        end
    end)
    return enemies
end

---
-- Checks if the unit is in the line of sight (LOS) of the player.
--
-- Determines whether the unit is in the line of sight of the player.
--
-- @function unit.in_los
-- @param guid The identifier of the unit to check for LOS.
-- @return boolean True if the unit is in LOS, false otherwise.
--
function unit.in_los(guid)
    if guid == "player" then return true end
    local ax, ay, az = api.object_position("player")
    local bx, by, bz = api.object_position(guid)
    local flags = bit.bor(0x10, 0x100, 0x1)
    if ax and ay and az and bz and by and bz then
        local hit, x, y, z = api.trace_line(ax, ay, az + 2.25, bx, by, bz + 2.25, flags);
        return hit == 0
    end
end