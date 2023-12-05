---
-- Game_object functionality.
-- @classmod game_object
--

---
-- @type game_object


---
-- The unique identifier of the game_object.
-- @string[readonly] guid

---
-- The object id of the game_object.
-- @string[readonly] id

---
-- Whether the game_object is categorized as an ore.
-- @bool[readonly] ore

---
-- Whether the game_object is categorized as a quest objective.
-- @bool[readonly] quest

---
-- Distance from player to game_object
-- @number[readonly] distance

---
-- The X-coordinate position of the game_object.
-- @number[readonly] x

---
-- The Y-coordinate position of the game_object.
-- @number[readonly] y

---
-- The Z-coordinate position of the game_object.
-- @number[readonly] z


local gutil = ...
local game_object = gutil.classes.game_object
local api = gutil.api

local ores = {
    [189980] = true,
    [189981] = true,
    [189978] = true,
    [189979] = true,
}

local function is_ore(guid)
    if ores[api.object_id(guid)] then
        return true
    else
        return false
    end
end

---
-- Constructs a new game object.
--
-- Initializes a new game object with the provided object identifier (guid). The game object
-- contains information such as the guid, object id, and whether it is categorized as ore or
-- a quest objective.
--
-- @function game_object:new
-- @param object The identifier (guid) of the game object.
-- @return game_object The newly created game object.
--
function game_object:new(object)
    self.guid = object
    self.id = api.object_id(self.guid)
    -- self.ore = is_ore(self.guid)
    -- self.quest = gutil.tracker_manager.is_quest_objective(self.guid)
end

---
-- Updates the state of the game object.
--
-- Retrieves and updates information about the game object, including its distance from the player
-- and its current position (x, y, z).
--
-- @function game_object:update
--
function game_object:update()
    self.distance = api.distance("player", self.guid)
    self.x, self.y, self.z = api.object_position(self.guid)
end