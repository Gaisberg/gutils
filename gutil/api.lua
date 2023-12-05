local gutil, env = ...
local api = gutil.api
setfenv(1, env)

function api.pairs(...)
    return pairs(...)
end

api.table = table

function api.sqrt(...)
    return sqrt(...)
end

function api.select(...)
    return select(...)
end

function api.setmetatable(...)
    return setmetatable(...)
end

function api.rad(...)
    return rad(...)
end

api.string = string

api.math = math

function api.create_frame(...)
    return CreateFrame(...)
end

api.ui_parent = UIParent
api.minimap = Minimap

function api.unit_aura(unit, index, filter)
    if not unit then return nil end
    return UnitAura(unit, index, filter)
end

api.aura_util = {
    find_aura_recurse = function(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2, predicateArg3, ...)
        if ... == nil then
            return nil; -- Not found
        end
        if predicate(predicateArg1, predicateArg2, predicateArg3, ...) then
            return ...;
        end
        auraIndex = auraIndex + 1;
        return api.aura_util.find_aura_recurse(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2,
            predicateArg3, api.unit_aura(unit, auraIndex, filter));
    end,

    find_aura = function(predicate, unit, filter, predicateArg1, predicateArg2, predicateArg3)
        local auraIndex = 1;
        return api.aura_util.find_aura_recurse(predicate, unit, filter, auraIndex, predicateArg1, predicateArg2,
            predicateArg3, api.unit_aura(unit, auraIndex, filter));
    end
}

do
    local function by_id_by_me(spellIdToFind, _, _, _, _, _, _, _, _, source, _, _, spellId)
        return spellIdToFind == spellId and api.unit_guid(source) == gutil.player.guid;
    end

    local function by_id(spellIdToFind, _, _, _, _, _, _, _, _, _, _, _, spellId)
        return spellIdToFind == spellId;
    end

    local function by_name_by_me(auraNameToFind, _, _, auraName, _, _, _, _, _, source)
    	return auraNameToFind == auraName and api.unit_guid(source) == gutil.player.guid;
    end

    local function by_name(auraNameToFind, _, _, auraName)
    	return auraNameToFind == auraName;
    end

    function api.aura_util.find_by_id(spellId, unit, by_me, filter)
        if by_me then
            return api.aura_util.find_aura(by_id_by_me, unit, filter, spellId)
        else
            return api.aura_util.find_aura(by_id, unit, filter, spellId)
        end
    end

    function api.aura_util.find_by_name(auraName, unit, by_me, filter)
        if by_me then
            return api.aura_util.find_aura(by_name_by_me, unit, filter, auraName)
        else
            return api.aura_util.find_aura(by_name, unit, filter, auraName)
        end
    end
end

gutil.api.find_aura = function(aura, unit, by_me, filter)
    unit = unit.guid
    if type(aura) ~= "number" then
        return api.aura_util.find_by_name(aura, unit, by_me, filter)
    end
    return api.aura_util.find_by_id(aura, unit, by_me, filter)
end

function api.unit_is_dead_or_ghost(...)
    return UnitIsDeadOrGhost(...)
end

function api.unit_is_tap_denied(...)
    return UnitIsTapDenied(...)
end

function api.get_time()
    return GetTime()
end

function api.get_spell_info(...)
    return GetSpellInfo(...)
end

api.is_moving = function(...)
    return GetUnitSpeed(...) > 0
end

function api.is_current_spell(...)
    return IsCurrentSpell(...)
end

function api.is_spell_in_range(...)
    return IsSpellInRange(...)
end

function api.is_mouselooking()
    return IsMouselooking()
end

function api.mouselook_stop()
    return MouselookStop()
end

function api.mouselook_start()
    return MouselookStart()
end

function api.cast_spell_by_name(...)
    return CastSpellByName(...)
end

function api.cast_spell_by_id(...)
    return CastSpellByID(...)
end

function api.unit_is_unit(...)
    return UnitIsUnit(...)
end

function api.unit_level(...)
    return UnitLevel(...)
end

function api.unit_name(...)
    if ... == nil then
        return nil
    end
    return UnitName(...)
end

function api.unit_affecting_combat(...)
    return UnitAffectingCombat(...)
end

function api.get_spell_cooldown(...)
    return GetSpellCooldown(...)
end

function api.get_spell_base_cooldown(...)
    return GetSpellBaseCooldown(...)
end

function api.is_harmful_spell(...)
    return IsHarmfulSpell(...)
end

function api.is_helpful_spell(...)
    return IsHelpfulSpell(...)
end

function api.get_spell_power_cost(...)
    return GetSpellPowerCost(...)
end

function api.is_usable_spell(...)
    return IsUsableSpell(...)
end

function api.get_spell_loss_of_control_cooldown(...)
    return GetSpellLossOfControlCooldown(...)
end

function api.get_spell_charges(...)
    return GetSpellCharges(...)
end

function api.get_unit_power(...)
    return UnitPower(...)
end

function api.get_form(...)
    return GetShapeshiftForm(...)
end

function api.unit_guid(...)
    return UnitGUID(...)
end

function api.unit_health(...)
    return UnitHealth(...)
end

function api.unit_health_max(...)
    return UnitHealthMax(...)
end

function api.unit_is_friend(...)
    return UnitIsFriend(...)
end

function api.unit_is_player(...)
    return UnitIsPlayer(...)
end

function api.unit_can_attack(...)
    return UnitCanAttack(...)
end

function api.is_in_instance()
    return IsInInstance()
end

function api.unit_is_visible(...)
    return UnitIsVisible(...)
end

function api.target_unit(...)
    return TargetUnit(...)
end

function api.run_macro_text(...)
    return RunMacroText(...)
end

function api.unit_class(...)
    return UnitClass(...)
end

function api.unit_casting_info(...)
    return UnitCastingInfo(...)
end

function api.unit_channel_info(...)
    return UnitChannelInfo(...)
end

function api.get_spell_subtext(...)
    return GetSpellSubtext(...)
end

gutil.api.is_unit_facing = function(obj1, obj2)
    local ax, ay, az = api.object_position(obj1)
    local bx, by, bz = api.object_position(obj2)
    local dx, dy, dz = ax - bx, ay - by, az - bz
    local rotation = api.unit_facing(obj1);
    local value = (dy * math.sin(-rotation) - dx * math.cos(-rotation)) /
        math.sqrt(dx * dx + dy * dy)
    local isFacing = value > 0.25
    return isFacing
end

function api.unit_in_party(...)
    return UnitInParty(...)
end

function api.unit_in_raid(...)
    return UnitInRaid(...)
end

api.c_timer = C_Timer

function api.stop_casting()
    return SpellStopCasting()
end

function api.get_realm_name()
    return GetRealmName()
end

function api.get_role(...)
    return UnitGroupRolesAssigned(...)
end

function api.to_string(...)
    return tostring(...)
end

function api.get_raid_target_index(...)
    return GetRaidTargetIndex(...)
end

function api.get_threat(...)
    return UnitDetailedThreatSituation(...)
end

function api.unit_classification(...)
    return UnitClassification(...)
end

function api.get_instance_lock_time_remaining()
    return GetInstanceLockTimeRemaining()
end

function api.get_instance_lock_time_remaining_encounter(...)
    return GetInstanceLockTimeRemainingEncounter(...)
end

function api.unit_get_incoming_heals(...)
    return UnitGetIncomingHeals(...)
end

function api.is_in_group()
    return IsInGroup()
end

function api.is_in_raid()
    return IsInRaid()
end

function api.get_build_info()
    return GetBuildInfo()
end

function api.unit_power(...)
    return UnitPower(...)
end

function api.unit_is_tapped(...)
    return UnitIsTapDenied(...) == false
end

function api.unit_player_or_pet_in_group(...)
    return UnitPlayerOrPetInParty(...) or UnitPlayerOrPetInRaid(...)
end

function api.is_auto_repeat_spell(...)
    return IsAutoRepeatSpell(...)
end

function api.is_player_spell(...)
    return IsPlayerSpell(...)
end