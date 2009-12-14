
local myname, ns = ...
local oUF = ns.oUF


oUF.TagEvents["[tekpp]"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER"
oUF.Tags["[tekpp]"] = function(u) local c, m = UnitPower(u), UnitPowerMax(u) return c >= m and m ~= 100 and oUF.Tags["[maxpp]"](u) or oUF.Tags["[perpp]"](u).."%" end

oUF.TagEvents["[tekhp]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["[tekhp]"] = function(u) local c, m = UnitHealth(u), UnitHealthMax(u) return (c <= 1 or not UnitIsConnected(u)) and "" or c >= m and oUF.Tags["[maxhp]"](u)
	or UnitCanAttack("player", u) and oUF.Tags["[perhp]"](u).."%" or "-"..oUF.Tags["[missinghp]"](u) end

oUF.TagEvents["[tekhp2]"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags["[tekhp2]"] = function(u) local c, m = UnitHealth(u), UnitHealthMax(u) if c == 0 then return "Dead" elseif c < m then return "-"..oUF.Tags["[missinghp]"](u) end end

oUF.TagEvents["[tekpet]"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE"
oUF.Tags["[tekpet]"] = function(u) if UnitHealth(u) >= UnitHealthMax(u) then return oUF.Tags["[name]"](u) end end


oUF.Tags["[teksacs]"]   = function(u) if UnitAura(u, "Sacred Shield")          then return "|cffFFAA00SS|r" end end
oUF.Tags["[tekbol]"]    = function(u) if UnitAura(u, "Beacon of Light")        then return "|cffFFD800BoL|r" end end
oUF.Tags["[tekgs]"]     = function(u) if UnitAura(u, "Guardian Spirit")        then return "|cffFFD800GS|r" end end
oUF.Tags["[tekmd]"]     = function(u) if UnitAura(u, "Misdirection")           then return "|cff8E79FEMD|r" end end
oUF.Tags["[tekss]"]     = function(u) if UnitAura(u, "Soulstone Resurrection") then return "|cffCA21FFSs|r" end end
oUF.Tags["[tekinn]"]    = function(u) if UnitAura(u, "Innervate")              then return "|cff00FF33Inn|r" end end
oUF.Tags["[tekpws]"]    = function(u) if UnitAura(u, "Power Word: Shield")     then return "|cffFFD800PwS|r" end end
oUF.Tags["[tekrenew]"]  = function(u) if UnitAura(u, "Renew")                  then return "|cff00FF10Rn|r" end end
oUF.Tags["[tekfood]"]   = function(u) if UnitAura(u, "Food")                   then return "|cffD79A6DFoo|r" end end
oUF.Tags["[tekdrink]"]  = function(u) if UnitAura(u, "Drink")                  then return "|cff00A1DEDr|r" end end
oUF.Tags["[tekms]"]     = function(u) if UnitAura(u, "Mortal Strike")          then return "|cffFF1111Ms|r" end end
oUF.Tags["[tekfw]"]     = function(u) if UnitAura(u, "Fear Ward")              then return "|cff9900FFFW|r" end end
oUF.Tags["[tekrejuv]"]  = function(u) if UnitAura(u, "Rejuvenation")           then return "|cff00FEBFRej|r" end end
oUF.Tags["[tekregrow]"] = function(u) if UnitAura(u, "Regrowth")               then return "|cff00FF10Rg|r" end end
oUF.Tags["[tekflour]"]  = function(u) if UnitAura(u, "Flourish")               then return "|cff33FF33Fl|r" end end
oUF.Tags["[tekws]"]     = function(u) if UnitDebuff(u, "Weakened Soul")        then return "|cffFF5500Ws|r" end end
oUF.Tags["[tekpom]"]    = function(u) local c = select(4, UnitAura(u, "Prayer of Mending")) if c then return "|cffFFCF7FPoM("..c..")|r" end end
oUF.Tags["[teklb]"]     = function(u) local c = select(4, UnitAura(u, "Lifebloom"))         if c then return "|cffA7FD0ALB("..c..")|r" end end

local function HasDebuffType(unit, t)
	for i=1,40 do
		local name, _, _, _, debuffType = UnitDebuff(unit, i)
		if not name then return
		elseif debuffType == t then return true end
	end
end

oUF.Tags["[tekdisease]"] = function(u) return HasDebuffType(u, "Disease") and "|cff996600Di|r" end
oUF.Tags["[tekmagic]"]   = function(u) return HasDebuffType(u, "Magic")   and "|cff3399FFMa|r" end
oUF.Tags["[tekcurse]"]   = function(u) return HasDebuffType(u, "Curse")   and "|cff9900FFCu|r" end
oUF.Tags["[tekpoison]"]  = function(u) return HasDebuffType(u, "Poison")  and "|cff009900Po|r" end

oUF.TagEvents["[teksacs]"]   = "UNIT_AURA"
oUF.TagEvents["[tekbol]"]    = "UNIT_AURA"
oUF.TagEvents["[tekmd]"]     = "UNIT_AURA"
oUF.TagEvents["[tekss]"]     = "UNIT_AURA"
oUF.TagEvents["[tekinn]"]    = "UNIT_AURA"
oUF.TagEvents["[tekpws]"]    = "UNIT_AURA"
oUF.TagEvents["[tekrenew]"]  = "UNIT_AURA"
oUF.TagEvents["[tekfood]"]   = "UNIT_AURA"
oUF.TagEvents["[tekdrink]"]  = "UNIT_AURA"
oUF.TagEvents["[tekms]"]     = "UNIT_AURA"
oUF.TagEvents["[tekws]"]     = "UNIT_AURA"
oUF.TagEvents["[tekfw]"]     = "UNIT_AURA"
oUF.TagEvents["[tekpom]"]    = "UNIT_AURA"
oUF.TagEvents["[teklb]"]     = "UNIT_AURA"
oUF.TagEvents["[tekrejuv]"]  = "UNIT_AURA"
oUF.TagEvents["[tekregrow]"] = "UNIT_AURA"
oUF.TagEvents["[tekflour]"]  = "UNIT_AURA"

oUF.TagEvents["[tekdisease]"] = "UNIT_AURA"
oUF.TagEvents["[tekmagic]"]   = "UNIT_AURA"
oUF.TagEvents["[tekcurse]"]   = "UNIT_AURA"
oUF.TagEvents["[tekpoison]"]  = "UNIT_AURA"
