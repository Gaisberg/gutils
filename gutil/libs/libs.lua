local gutil = ...

local list = {
    "libs/LibStub/LibStub.lua",
    "libs/LibDraw/LibDraw.lua",
    "libs/LibClassicSpecs/LibClassicSpecs.lua",
    "libs/Ace3/AceGUI-3.0/AceGUI-3.0.lua",
    "libs/LibDBIcon-1.0/LibDBIcon-1.0.lua",
    "libs/LibDataBroker-1.1/LibDataBroker-1.1.lua",
    "libs/CallbackHandler-1.0/CallbackHandler-1.0.lua",
    "libs/AceAddon-3.0/AceAddon-3.0.lua",
    "libs/AceConsole-3.0/AceConsole-3.0.lua",
    "libs/AceDB-3.0/AceDB-3.0.lua"
}

local widgets = "libs/Ace3/AceGUI-3.0/widgets/"
for _, v in gutil.api.pairs(gutil.api.get_directory_files(widgets)) do
    gutil.api.require(widgets .. v)
end

for _, file in gutil.api.pairs(list) do
    gutil.api.require(file, gutil)
end

-- libs
gutil.libs.specs = LibStub("LibClassicSpecs")
if not _G["GetSpecializationInfo"] then
    _G["GetSpecializationInfo"] = gutil.libs.specs.GetSpecializationInfo
end
if not _G["GetSpecialization"] then
    _G["GetSpecialization"] = gutil.libs.specs.GetSpecialization
end
gutil.libs.draw = LibStub("LibDraw")
gutil.api.require("libs/json/JSON.lua", gutil)