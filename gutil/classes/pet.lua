---
-- Pet class
-- @classmod pet
--
---
-- @type pet

---
-- The unique identifier of the pet.
-- @string[readonly] guid

---
-- Pet's HP
-- @number[readonly] hp

---
-- Pet's name
-- @string[readonly] name

---
-- Pet's target (GUID)
-- @string[readonly] target

local gutil = ...
local pet = gutil.classes.pet
local api = gutil.api

function pet:new()
    self.guid = "stub"
    self.hp = 100
end

function pet:update()
    self.guid = gutil.api.unit_guid("pet")
    if self.guid and self.guid ~= "stub" then
        self.name = gutil.api.unit_name(self.guid)
        self.target = api.unit_target(self.guid)
        self.hp = api.unit_health(self.guid) / api.unit_health_max(self.guid) * 100
    end
end