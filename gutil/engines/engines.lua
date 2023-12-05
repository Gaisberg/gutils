local gutil = ...
local api = gutil.api
local require = api.require
local pairs = api.pairs

gutil.engines = {}


local function object_table()
    local cls = {}
    cls.__index = cls
    gutil.api.setmetatable(
        cls,
        {
            __call = function(self, ...)
                local instance = gutil.api.setmetatable({}, self)
                instance:new(...)
                return instance
            end
        }
    )

    --- Iterates over the elements of the table and applies a callback function.
    -- This method iterates over the non-function elements of the table and applies
    -- the provided callback function.
    -- @function table:foreach
    -- @tparam function callback The callback function to apply to each element.
    --   It should accept two parameters: the value and the key of the element.
    -- @usage gutil.objects.enemies:foreach(function(o) print(o.name) end) -- Prints all enemy names.

    function cls:foreach(callback)
        for k, v in gutil.api.pairs(self) do
            if type(v) ~= "function" and k ~= "__index" then
                callback(v, k)
            end
        end
    end

    --- Checks if the table contains a specified element.
    -- This method checks if the table contains a specified element, which can be either
    -- a string or a table with a 'guid' property.
    -- @function table:contains
    -- @param obj The element to check for containment.
    -- @treturn bool True if the table contains the element, false otherwise.
    -- @usage gutil.objects.enemies:contains(gutil.api.unit_guid("target")) -- Return true if enemies contains "target".
    function cls:contains(obj)
        local contains = false
        cls:foreach(function(o, i)
            if type(obj) == "table" then
                if obj.guid == o.guid then
                    contains = true
                    return
                end
            elseif type(obj) == "string" then
                if obj == o then
                    contains = true
                    return
                end
            end
        end)
        return contains
    end

    --- Updates all elements in the table.
    -- This method calls the 'update' method on each non-function element in the table.
    -- @function table:update
    function cls:update()
        self:foreach(function(o, i)
            o:update()
        end)
    end

    --- Sorts the elements in the table.
    -- This method sorts the elements in the table using the provided comparison function.
    -- @function table:sort
    -- @tparam[opt] function func The comparison function used for sorting.
    -- @usage gutil.objects.friends:foreach(function(a, b) a.hp < b.hp end) -- Sorts friends with lowest hp first.
    function cls:sort(func)
        gutil.api.table.sort(self, func)
    end

    --- Adds an element to the table if it is not already present.
    -- This method adds an element to the table if it does not already exist in the table.
    -- @function table:add
    -- @param obj The element to add to the table.
    -- @see table:contains
    function cls:add(obj)
        if not self:contains(obj) then
            gutil.api.table.insert(self, obj)
        end
    end

    return cls
end

gutil.engines.object_table = object_table
gutil.objects = { all = {units = {}, objects = {}}, friends = object_table(), enemies = object_table(), trackers = object_table()}

local list = {
    "unit.lua",
    -- "object.lua"
    -- "tracker.lua"
}

for _, file in pairs(list) do
    require("engines/" .. file, gutil)
end

local last_update = gutil.api.get_time()
local frame = CreateFrame("Frame")
frame:SetScript("OnUpdate", function()
    if gutil.initialized and gutil.settings.enabled and gutil.api.get_time() - last_update >= gutil.settings.pulse_rate then
        local objects = api.objects()

        objects.units = objects.units or {}
        objects.objects = objects.objects or {}
        gutil.objects.all = objects
        gutil.engines.unit:run()
        last_update = gutil.api.get_time()
    end
end)