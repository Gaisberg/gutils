---
-- Functions for interacting with buffs and debuffs.
-- @module aura
--

local gutil = ...
local api = gutil.api
local aura = {}

local function determine_target(target)
    if not target then
        target = gutil.player
    end
    return target
end

function aura:new(obj, input)
    if type(input) == "string" then
        obj.name = input
        obj.id = select(7, api.get_spell_info(input))
    else
        obj.name = api.get_spell_info(input)
        obj.id = input
    end
end

function aura:exists(obj, target)
    target = determine_target(target)
    return aura:query(obj, target) ~= nil
end

function aura:remaining(obj, target)
    target = determine_target(target)

    local expiry = select(6, aura:query(obj, target))
    if expiry == nil then return 0 end

    return expiry - api.get_time()
end

function aura:stacks(obj, target)
    target = determine_target(target)
    local stacks = select(3, aura:query(obj, target))
    if not stacks then
        stacks = 0
    end
    return stacks
end

function aura:query(obj, target)
    return api.find_aura(obj.id, target, true, obj.type)
end

---
-- @type buff
local buff = gutil.classes.buff
function buff:new(input)
    aura:new(self, input)
    self.type = "HELPFUL"
end

---
-- Checks if the buff exists on the specified target.
--
-- @function buff:exists
-- @param target (Optional) The target to check for the buff. If nil, the default target is used.
-- @return boolean True if the buff exists on the target, false otherwise.
-- @usage local arcane_intellect = gutil.classes.buff("Arcane Intellect")
--if arcane_intellect:exists(gutil.player) then print("Arcane Intellect is active!") end
function buff:exists(target)
    return aura:exists(self, target)
end

---
-- Calculates the remaining duration of the buff on the specified target.
--
-- @function buff:remaining
-- @param target (Optional) The target to calculate the remaining duration for. If nil, the default target is used.
-- @return number The remaining duration of the buff in seconds.
-- @usage local arcane_intellect = gutil.classes.buff("Arcane Intellect")
--if arcane_intellect:remaining(gutil.player) < 2 then print("Arcane Intellect will expire in 2 seconds!") end
function buff:remaining(target)
    return aura:remaining(self, target)
end

---
-- Retrieves the number of stacks of the buff on the specified target.
--
-- @function buff:stacks
-- @param target (Optional) The target to retrieve the stack count for. If nil, the default target is used.
-- @return number The number of stacks of the buff.
-- @usage local earth_shield = gutil.classes.buff("Earth Shield")
--if earth_shield:stacks(gutil.player) == 1 then print("Only one stack of Earth Shield left!") end
function buff:stacks(target)
    return aura:stacks(self, target)
end

---
-- Queries for the buff on the specified target.
--
-- @function buff:query
-- @param target The target to query for the buff.
-- @return GetSpellInfo return value of target or nil if not found.
function buff:query(target)
    return aura:query(self, target)
end

---
-- @type debuff
local debuff = gutil.classes.debuff

function debuff:new(input)
    aura:new(self, input)
    self.type = "HARMFUL"
end

---
-- Checks if the debuff exists on the specified target.
--
-- @function debuff:exists
-- @param target (Optional) The target to check for the debuff. If nil, the default target is used.
-- @return boolean True if the debuff exists on the target, false otherwise.
-- @see buff:exists
function debuff:exists(target)
    return aura:exists(self, target)
end

---
-- Calculates the remaining duration of the debuff on the specified target.
--
-- @function debuff:remaining
-- @param target (Optional) The target to calculate the remaining duration for. If nil, the default target is used.
-- @return number The remaining duration of the debuff in seconds.
-- @see buff:remaining
function debuff:remaining(target)
    return aura:remaining(self, target)
end

---
-- Retrieves the number of stacks of the debuff on the specified target.
--
-- @function debuff:stacks
-- @param target (Optional) The target to retrieve the stack count for. If nil, the default target is used.
-- @return number The number of stacks of the debuff.
-- @see buff:stacks
function debuff:stacks(target)
    return aura:stacks(self, target)
end

---
-- Queries for the debuff on the specified target.
--
-- @function debuff:query
-- @param target The target to query for the debuff.
-- @return GetSpellInfo return value of target or nil if not found.
function debuff:query(target)
    return aura:query(self, target)
end