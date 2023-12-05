local gutil, env = ...

gutil.api.require = function(file, ...)
    return env.RequireFile("/gutil/" .. file, ...)
end

gutil.api.get_directory_files = function (...)
    local file_string = env.GetDirectoryFiles(env.GetExeDirectory() .. "/gutil/" .. ...)
    local files = {}
    for token in string.gmatch(file_string, "[^|]+") do
        table.insert(files, token)
    end
    return files
end

gutil.api.file_exists = function(...)
    return env.FileExists(env.GetExeDirectory() .. "/gutil/" .. ...)
end

gutil.api.write_file = function(filename, string, append)
    return env.WriteFile(env.GetExeDirectory() .. "/gutil/" ..  filename, string, append)
end

gutil.api.read_file = function(...)
    return env.ReadFile(env.GetExeDirectory() .. "/gutil/" ..  ...)
end

gutil.api.click_position = function(...)
    return env.ClickPosition(...)
end

gutil.api.objects = function()
    local objects = {}
    local types = {
        [5] = true,
        [6] = true,
        [8] = true,
    }
    for i = 1, env.GetObjectCount(), 1 do
        local guid = env.GetObjectWithIndex(i)
        if env.IsGuid(guid) then
            local type = env.ObjectType(guid)
            if types[type] then
                if type == 6 then
                    type = 5
                end
                if type == 5 then
                    type = "units"
                else
                    type = "objects"
                end
                objects[type] = objects[type] or {}
                objects[type][guid] = i
            end
        end
    end
    return objects
end

gutil.api.object_type = function(...)
    return env.ObjectType(...)
end

gutil.api.draw  = env.Draw

gutil.api.object_position = function(...)
    return env.GetUnitPosition(...)
end

gutil.api.object_id = function(...)
    return env.ObjectID(...)
end

gutil.api.real_distance = function(...)
    return env.GetDistance3D(...)
end

gutil.api.distance = function(unit1, unit2)
    local x1, y1, z1 = env.GetUnitPosition(unit1)
    local x2, y2, z2 = env.GetUnitPosition(unit2)
    local r1 = env.UnitCombatReach(unit1) or 0
    local r2 = env.UnitCombatReach(unit2) or 0

    if x1 and y1 and z1 and x2 and y2 and z2 and r1 and r2 then
        local value = math.sqrt((x2 - x1)^2 + (y2-y1)^2 + (z2-z1)^2) -(r1 + r2)
        if value < 0 then
            return 0
        else
            return value
        end
    else
        return 999
    end

    -- return env.GetDistance3D(...) or 999
end

gutil.api.unit_target = function(...)
    return env.UnitTarget(...)
end

gutil.api.trace_line = function(...)
    return env.TraceLine(...)
end

gutil.api.unit_facing = function (...)
    return env.UnitFacing(...)
end

gutil.api.unit_summoned_by = function(...)
    return env.UnitSummonedBy(...)
end

gutil.api.unit_combat_reach = function(...)
    return env.UnitCombatReach(...)
end

gutil.api.unit_is_mounted = function(...)
    return env.UnitIsMounted(...)
end

gutil.api.unit_specialization_id = function(...)
    return env.UnitSpecializationID(...)
end

gutil.api.object_is_quest_objective = function(...)
    return env.ObjectIsQuestObjective(...)
end

gutil.api.is_spell_pending = function(...)
    return env.IsSpellPending(...)
end

gutil.api.get_aura_count = function(...)
    return env.GetAuraCount(...)
end

gutil.api.get_aura_with_index = function(...)
    return env.GetAuraWithIndex(...)
end

gutil.api.world_to_screen = function(wX, wY, wZ)
    local sX, sY, Visible = env.WorldToScreen(wX, wY, wZ)
    if not Visible and (not sX or sX == 0) and (not sY or sY == 0) then
      return false, false, false
    end
    return sX, -sY, Visible
end

gutil.api.object_lootable = function (...)
    return env.UnitIsLootable(...)
end

function gutil.api.unit_flags(...)
    return env.UnitFlags(...)
end

function gutil.api.object_exists(...)
    return env.ObjectExists(...)
end

function gutil.api.get_key_state(...)
    return env.GetKeyState(...) ~= nil
end

function gutil.api.object_name(...)
    return env.ObjectName(...)
end