local gutil = ...
local self = {}
local initialized = false
gutil.engines.unit = self

local function conditions(guid)
    return not gutil.api.unit_is_dead_or_ghost(guid)
    and gutil.api.distance("player", guid) < 40
    and gutil.classes.unit.in_los(guid)
end

function self:run()
    -- remove
    gutil.objects.enemies:foreach(function(o, i)
        if not conditions(o.guid) then
            gutil.objects.enemies[i] = nil
        end
    end)

    gutil.objects.friends:foreach(function(o, i)
        if not conditions(o.guid) then
            gutil.objects.friends[i] = nil
        end
    end)

    -- add
    for guid, _ in gutil.api.pairs(gutil.objects.all.units) do
        if conditions(guid) then
            if gutil.classes.unit.is_enemy(guid) then
                gutil.objects.enemies:add(gutil.classes.unit(guid, 0, "enemy"))
            elseif gutil.classes.unit.is_friend(guid) then
                gutil.objects.friends:add(gutil.classes.unit(guid, 0, "friend"))
            end
        end
    end

    gutil.objects.friends:add(gutil.player)
    if gutil.api.object_exists("pet") then
        gutil.objects.friends:add(gutil.classes.unit("pet"))
    end

    --update
    gutil.objects.enemies:update()
    gutil.objects.friends:update()

    --sort
    if #gutil.objects.enemies > 1 then
        local lowest, highest, norm, score, raid_target
        local value = "hp"
        if gutil.player.role == "TANK" then
            value = "threat"
        end
        gutil.objects.enemies:foreach(function(o)
            if not lowest or o[value] < lowest then
                lowest = o[value]
            end
            if not highest or o[value] > highest then
                highest = o[value]
            end
        end)
        gutil.objects.enemies:foreach(function(o)
            norm = (10 - 1) / (highest - lowest) * (o[value] - highest) + 10
            if norm ~= norm or gutil.api.to_string(norm) == gutil.api.to_string(0/0) then
                norm = 0
            end
            score = norm
            if not gutil.player.role == "TANK" and o.ttd > 1.5 then
                score = score + 5
            end
            raid_target = gutil.api.get_raid_target_index(o.guid)
            if raid_target then
                score = score + raid_target * 3
                if raid_target == 8 then
                    score = score + 5
                end
            end
            o.score = score
        end)
        gutil.objects.enemies:sort(function(a, b)
            if a and b then
                return a.score > b.score
            end
        end)
        if gutil.player.target then
            gutil.objects.enemies:sort(function(a)
                if a then
                    return a.guid == gutil.player.target
                end
            end)
        end
    end
    if #gutil.objects.friends > 1 and gutil.player.role == "HEALER" then
        gutil.objects.friends:sort(function(a, b)
            if a and b then
                return a.hp < b.hp
            end
        end)
    end
end

function self:initialize()
    gutil.objects.enemies = gutil.engines.object_table()
    gutil.objects.friends = gutil.engines.object_table()
    initialized = true
end

-- self.frame = CreateFrame("Frame")
-- self.frame:SetScript("OnUpdate", function()
--     if initialized and gutil.settings.enabled then
--         self:run()
--     end
-- end)


