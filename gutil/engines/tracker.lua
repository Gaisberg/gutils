-- local gutil = ...
-- local self = {}
-- local initialized = false
-- gutil.managers.tracker = self

-- local function conditions(guid)
--     return not gutil.api.unit_is_dead_or_ghost(guid)
--     and gutil.api.distance("player", guid) < 40
--     and gutil.classes.unit.in_los(guid)
--     and gutil.classes.unit.is_enemy(guid)
-- end

-- function self:run()
--     gutil.objects.enemies:foreach(function(o, i)
--         if not conditions(o.guid) then
--             gutil.objects.enemies[i] = nil
--         end
--     end)

--     for guid, _ in gutil.api.pairs(gutil.objects.all.units) do
--         if conditions(guid) then
--             gutil.objects.enemies:add(gutil.classes.unit(guid))
--         end
--     end

--     gutil.objects.enemies:update()
-- end

-- function self:start()
--     enabled = true
-- end

-- function self:stop()
--     enabled = false
-- end

-- function self:initialize()
--     gutil.objects.enemies = gutil.engines.object_table()
-- end

-- self.frame = CreateFrame("Frame")
-- self.frame:SetScript("OnUpdate", function()
--     if enabled then
--         self:run()
--     end
-- end)


-- local gutil = ...
-- local api = gutil.api
-- gutil.tracker_manager = {}
-- local tracker = gutil.tracker_manager
-- local loader = QuestieLoader

-- if loader then
--     tracker.tooltips = loader:ImportModule("QuestieTooltips")
-- end

-- function tracker.is_quest_objective(object)
--     if not loader then
--         return false
--     end
--     local object_id = api.object_id(object)
--     local prefix = "m_"
--     if api.object_type(object) == 8 then
--         prefix = "o_"
--     end
--     if object_id and tracker.tooltips.lookupByKey[prefix .. object_id] then
--         for _, tooltip in api.pairs(tracker.tooltips.lookupByKey[prefix .. object_id]) do
--             if tooltip.objective and tooltip.objective.Update then
--                 tooltip.objective:Update()
--                 if not tooltip.objective.Completed then
--                     return true
--                 end
--             end
--         end
--     else
--         return false
--     end
-- end

-- function tracker.run()
--     gutil.objects.tracker:update()
--     if #gutil.objects.tracker > 1 then
--         gutil.objects.tracker:sort( function(a, b)
--             if a and b then
--                 return a.distance < b.distance
--             end
--         end)
--     end

--     local i = 0
--     gutil.objects.tracker:foreach(function(k)
--         i = tracker.draw_circle(k, i)
--     end)
-- end

-- -- HOW ABOUT A UI?
-- function tracker.draw_circle(object, i)
--     local draw_amount = 5
--     local guid = object.guid
--     if i <= draw_amount
--     and ((api.object_type(guid) == 5 and (not api.unit_is_dead_or_ghost(guid) or api.object_lootable(guid) and not api.unit_is_tap_denied(guid)))
--     or api.object_type(guid) == 8) then
--         gutil.libs.draw.Circle(object.x, object.y, object.z, 1)
--         if object.ore then --and gutil.api.is_spell_known() then
--             gutil.libs.draw.Line(gutil.player.x, gutil.player.y, gutil.player.z, object.x, object.y, object.z)
--         end
--         i = i + 1
--     end
--     return i
-- end