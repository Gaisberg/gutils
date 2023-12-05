local env = ...
local gutil = {}

local function load_addon()
    gutil = { api = {}, libs = {} }
    gutil.game_version = GetBuildInfo()
    env.RequireFile("/gutil/unlockers/"..env.name..".lua", gutil, env)
    gutil.api.require("api.lua", gutil, env)
    gutil.api.require("libs/libs.lua", gutil)
    gutil.api.require("core.lua", gutil)
end

load_addon()
