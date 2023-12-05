---
-- Spell functionality.
-- @classmod spell
--

---
-- @type spell

local gutil = ...
local api = gutil.api
local spell = gutil.classes.spell

---
-- Constructs a new spell object.
--
-- Initializes a new spell object with information such as spell name, spell id, cast time,
-- range, cast type (normal, ground, pet, etc.), harmful/helpful categorization, and channeling status.
--
-- @function spell:new
-- @param input The spell name or ID to create the spell object.
-- @param cast_type (Optional) The type of spell casting (normal, ground, pet, etc.). Defaults to "normal".
-- @return spell The newly created spell object.
--
function spell:new(input, cast_type)
    if type(input) == "string" then
        self.name = input
        self.id = api.select(7, api.get_spell_info(self.name))
    elseif type(input) == "number" then
        self.id = input
        self.name = api.get_spell_info(self.id)
    end
    if self.name == nil or self.id == nil then
        self.not_found = true
        return
    end
    if not self:is_known() then return end
    self.cast_time = api.select(4, api.get_spell_info(self.id)) / 1000
    self.min_range = api.select(5,api.get_spell_info(self.id)) or 0
    self.max_range = api.select(6,api.get_spell_info(self.id)) or 0
    self.cast_type = cast_type or "normal" -- Ground, Normal, Pet ect.
    self.is_harmful = api.is_harmful_spell(self.name) or false
    self.is_helpful = api.is_helpful_spell(self.name) or false
    if not self.is_harmful and not self.is_helpful then
        if self.cast_type == "pet" then
            self.is_helpful = true
        else
            self.is_harmful = true
        end
    end

    local cost_table = api.get_spell_power_cost(self.id)
    for _, costInfo in api.pairs(cost_table) do
        if costInfo.costPerSec > 0 then
            self.cast_type = "channel"
        end
    end
end

---
-- Retrieves the cost of casting the spell.
--
-- Retrieves and returns the cost of casting the spell in terms of spell power.
--
-- @function spell:cost
-- @return number The cost of casting the spell in terms of spell power.
--
function spell:cost()
    local cost_table = api.get_spell_power_cost(self.id)
    if cost_table then
        for _, costInfo in api.pairs(cost_table) do
            if costInfo.cost > 0 then
                return costInfo.cost
            end
        end
    end
    return 0
end

---
-- Checks if the spell is in range of the specified target.
--
-- Determines whether the spell is in range of the specified target.
--
-- @function spell:in_range
-- @param target The target to check for spell range.
-- @return boolean True if the spell is in range, false otherwise.
--
function spell:in_range(target)
    local in_range = api.is_spell_in_range(self.id, target)
    if in_range == 1 then
        return true
    else
        return false
    end
end

---
-- Checks if the spell is ready for casting.
--
-- Determines whether the spell is ready for casting, considering factors such as usability and cooldown status.
--
-- @function spell:is_ready
-- @return boolean True if the spell is ready for casting, false otherwise.
--
function spell:is_ready()
    if self:is_usable() and not self:on_cooldown() then
        return true
    else
        return false
    end
end

---
-- Checks if the spell is known by the player.
--
-- Determines whether the spell is known and present in the player's spellbook.
--
-- @function spell:is_known
-- @return boolean True if the spell is known, false otherwise.
--
function spell:is_known()
    if api.get_spell_info(self.name) then
        return true
    else
        return false
    end
end

---
-- Checks if the spell is on cooldown.
--
-- Determines whether the spell is currently on cooldown.
--
-- @function spell:on_cooldown
-- @return boolean True if the spell is on cooldown, false otherwise.
--
function spell:is_usable()
    return api.is_usable_spell(self.id)
end

---
-- Checks if the spell is on cooldown.
--
-- Determines whether the spell is currently on cooldown.
--
-- @function spell:on_cooldown
-- @return boolean True if the spell is on cooldown, false otherwise.
--
function spell:on_cooldown()
    if api.get_spell_cooldown(self.id) > 0 then
        return true
    else
        return false
    end
end

---
-- Retrieves the number of charges remaining for the spell.
--
-- Retrieves and returns the number of charges remaining for the spell.
--
-- @function spell:charges
-- @return number The number of charges remaining for the spell.
--
function spell:charges()
    return api.get_spell_charges(self.id)
end

---
-- Calculates the remaining recharge time for the spell.
-- @function spell:recharge_time
-- @treturn number The remaining recharge time for the spell in seconds, or 0 if not applicable.
function spell:recharge_time()
        local charges, max_charges, charge_start, charge_duration = api.get_spell_charges(self.id)
        if not charges then return 0 end
        if max_charges then return charge_duration end
        if charges then
            if charges < max_charges then
                local chargeEnd = charge_start + charge_duration
                return chargeEnd - api.get_time()
            end
            return 0
        end
end

---
-- Calculates the remaining time until the spell is fully recharged.
-- @function spell:full_recharge_time
-- @treturn number The remaining time until the spell is fully recharged in seconds, or 0 if not applicable.
function spell:full_recharge_time()
    local charges, max_charges, charge_start, charge_duration = api.get_spell_charges(self.id)
    if not charges then return 0 end

    if charges then
        local current_time = (charges or 0) < (max_charges or 0) and charge_duration - (api.get_time() - (charge_start or 0)) or 0
        local left_time = (max_charges - charges - 1) * charge_duration
        if charges ~= max_charges then
            return current_time + left_time
        end
    end
    return 0
end

---
-- Calculates the fractional charges for the spell.
-- @function spell:charges_fractional
-- @treturn number The fractional charges for the spell.
function spell:charges_fractional()
    local charges, max_charges, charge_start, charge_duration = api.get_spell_charges(self.id)
    if not charges then return 0 end


	if max_charges == nil then max_charges = false end
	if max_charges ~= nil then
		if max_charges then
			return max_charges
		else
			if charge_start <= api.get_time() then
				local end_time = charge_start + charge_duration
				local fraction = 1 - (end_time - api.get_time()) / charge_duration
				return charges + fraction
			else
				return charges
			end
		end
	end
	return 0
end

---
-- Retrieves the remaining cooldown time for the spell.
-- @function spell:cooldown_remaining
-- @treturn number The remaining cooldown time for the spell in seconds.
function spell:cooldown_remaining()
    return select(2, api.get_spell_cooldown(self.id))
end
