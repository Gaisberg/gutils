local gutil = ...
local api = gutil.api
gutil.classes = {}
gutil.managers = {}
local require = api.require
local pairs = api.pairs

local function class()
    local cls = {}
    cls.__index = cls
    api.setmetatable(
        cls,
        {
            __call = function(self, ...)
                local instance = api.setmetatable({}, self)
                instance:new(...)
                return instance
            end
        }
    )
    return cls
end

gutil.classes.player = class()
gutil.classes.pet = class()
gutil.classes.spell = class()
gutil.classes.buff = class()
gutil.classes.debuff = class()
gutil.classes.unit = class()
gutil.classes.game_object = class()

local list = {
    "player.lua",
    "spell.lua",
    "cast.lua",
    "aura.lua",
    "unit.lua",
    "game_object.lua",
    "pet.lua"
}

for _, file in pairs(list) do
    require("classes/" .. file, gutil)
end