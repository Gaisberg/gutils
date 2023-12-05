local gutil = ...
local api = gutil.api
local require = api.require
local pairs = api.pairs

gutil.managers = {}

local list = {
    "profile.lua",
    "settings.lua"
}

for _, file in pairs(list) do
    require("managers/" .. file, gutil)
end