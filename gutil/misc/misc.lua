local gutil = ...
local api = gutil.api
local require = api.require
local pairs = api.pairs

local list = {
    "functions.lua",
    "ui.lua"
}

for _, file in pairs(list) do
    require("misc/" .. file, gutil)
end