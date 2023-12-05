local gutil = ...
local self = {}
local initialized = false
gutil.engines.object = self

local objects = {
    [381153] = true,
    [380654] = true,
    [381045] = true,
    [382325] = true,
    [380653] = true,
    [380840] = true,
    [385022] = true,
    [385021] = true,
    [406385] = true
}
local function conditions(guid)
    return objects[gutil.api.object_id(guid)]
end

function self:run()
    -- remove
    gutil.objects.trackers:foreach(function(o, i)
        if not gutil.api.object_exists(o.guid) then
            gutil.objects.trackers[i] = nil
        end
    end)

    -- add
    for guid, _ in gutil.api.pairs(gutil.objects.all.objects) do
        if conditions(guid) then
            gutil.objects.trackers:add(gutil.classes.game_object(guid))
        end
    end

    --update
    gutil.objects.trackers:update()

    --sort
    if #gutil.objects.trackers > 1 then
        gutil.objects.trackers:sort(function(a, b)
            if a and b then
                return a.distance < b.distance
            end
        end)
    end

    gutil.objects.trackers:foreach( function(object)
        gutil.libs.draw.Line(gutil.player.x, gutil.player.y, gutil.player.z, object.x, object.y, object.z)
    end)
end

function self:initialize()
    gutil.objects.trackers = gutil.engines.object_table()
    initialized = true
end

self.frame = CreateFrame("Frame")
self.frame:SetScript("OnUpdate", function()
    if initialized and gutil.settings.enabled then
        self:run()
    end
end)


