local dmc = ...
local env = {}

if (not dmc) or (not dmc.IsInWorld) then
  return
end

local localenv = setmetatable(
  {},
  {
    __index = function(self, func)
      return dmc[func] or _G[func]
    end
  }
)

local unlockList =  --add the locked wow APIs you need to this list
{
  "CastSpellByName",
  "JumpOrAscendStart",
  "UnitName",
  "UnitAura",
  "UnitHealth",
  "UnitClass",
  "UnitHealthMax",
  "UnitIsDeadOrGhost",
  "UnitCanAttack",
  "UnitAffectingCombat",
  "UnitCastingInfo",
  "UnitChannelInfo",
  "UnitIsFriend",
  "UnitInParty",
  "UnitInRaid",
  "UnitIsUnit",
  "SpellStopCasting",
  "GetUnitSpeed",
  "UnitGroupRolesAssigned",
  "GetRaidTargetIndex",
  "UnitDetailedThreatSituation",
  "UnitClassification",
  "UnitLevel",
  "RunMacroText",
  "TargetUnit",
  "UnitGetIncomingHeals",
  "UnitPower",
  "UnitIsTapDenied",
  "UnitPlayerOrPetInParty",
  "UnitPlayerOrPetInRaid"
}

for i = 1, #unlockList do
  local funcname = unlockList[i]
  local func = _G[funcname]
  localenv[funcname] = function(...) return dmc.SecureCode(func, ...) end
end

localenv.name = "dmc"

local function LoadAddon()
  if dmc.IsInWorld() then
    localenv.RequireFile("/gutil/entry.lua", localenv)
    return
  end
  C_Timer.After(0.04, LoadAddon)
end

LoadAddon()

