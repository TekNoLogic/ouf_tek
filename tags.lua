
local myname, ns = ...
TEKX = ns
local oUF = ns.oUF


oUF.Tags.Events["tekpp"] = "UNIT_ENERGY UNIT_FOCUS UNIT_MANA UNIT_RAGE UNIT_RUNIC_POWER UNIT_MAXENERGY UNIT_MAXFOCUS UNIT_MAXMANA UNIT_MAXRAGE UNIT_MAXRUNIC_POWER"
oUF.Tags.Methods["tekpp"] = function(u) local c, m = UnitPower(u), UnitPowerMax(u) return c >= m and m ~= 100 and _TAGS["maxpp"](u) or _TAGS["perpp"](u).."%" end

oUF.Tags.Events["tekhp"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags.Methods["tekhp"] = function(u) local c, m = UnitHealth(u), UnitHealthMax(u) return (c <= 1 or not UnitIsConnected(u)) and "" or c >= m and _TAGS["maxhp"](u)
	or UnitCanAttack("player", u) and _TAGS["perhp"](u).."%" or "-".._TAGS["missinghp"](u) end

oUF.Tags.Events["tekhp2"] = "UNIT_HEALTH UNIT_MAXHEALTH"
oUF.Tags.Methods["tekhp2"] = function(u) local c, m = UnitHealth(u), UnitHealthMax(u) if c == 0 then return "Dead" elseif c < m then return "-".._TAGS["missinghp"](u) end end

oUF.Tags.Events["tekpet"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_NAME_UPDATE"
oUF.Tags.Methods["tekpet"] = function(u) if UnitHealth(u) >= UnitHealthMax(u) then return _TAGS["name"](u) end end

oUF.Tags.Events["tekminus"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["tekminus"] = function(u) local c = UnitClassification(u); if c == "minus" then return "-" end end

oUF.Tags.Events["tekquest"] = "UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["tekquest"] = function(u) if UnitIsQuestBoss(u) then return "Quest" end end

oUF.Tags.Events["teklevel"] = "UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED"
oUF.Tags.Methods["teklevel"] = function(u)
	local c = UnitClassification(u)
	if c == "worldboss" then
		return "Boss"
	else
		local plusminus = _TAGS["plus"](u)
		if not plusminus then plusminus = _TAGS["tekminus"](u) end
		local level = _TAGS["level"](u)
		if (plusminus) then
			return level.. plusminus
		else
			return level
		end
	end
end



oUF.Tags.Methods["teksacs"]   = function(u) if UnitAura(u, "Sacred Shield")          then return "|cffFFAA00SS|r" end end
oUF.Tags.Methods["tekbol"]    = function(u) if UnitAura(u, "Beacon of Light")        then return "|cffFFD800BoL|r" end end
oUF.Tags.Methods["tekgs"]     = function(u) if UnitAura(u, "Guardian Spirit")        then return "|cffFFD800GS|r" end end
oUF.Tags.Methods["tekmd"]     = function(u) if UnitAura(u, "Misdirection")           then return "|cff8E79FEMD|r" end end
oUF.Tags.Methods["tekss"]     = function(u) if UnitAura(u, "Soulstone Resurrection") then return "|cffCA21FFSs|r" end end
oUF.Tags.Methods["tekinn"]    = function(u) if UnitAura(u, "Innervate")              then return "|cff00FF33Inn|r" end end
oUF.Tags.Methods["tekpws"]    = function(u) if UnitAura(u, "Power Word: Shield")     then return "|cffFFD800PwS|r" end end
oUF.Tags.Methods["tekrenew"]  = function(u) if UnitAura(u, "Renew")                  then return "|cff00FF10Rn|r" end end
oUF.Tags.Methods["tekfood"]   = function(u) if UnitAura(u, "Food")                   then return "|cffD79A6DFoo|r" end end
oUF.Tags.Methods["tekdrink"]  = function(u) if UnitAura(u, "Drink")                  then return "|cff00A1DEDr|r" end end
oUF.Tags.Methods["tekms"]     = function(u) if UnitAura(u, "Mortal Strike")          then return "|cffFF1111Ms|r" end end
oUF.Tags.Methods["tekfw"]     = function(u) if UnitAura(u, "Fear Ward")              then return "|cff9900FFFW|r" end end
oUF.Tags.Methods["tekrejuv"]  = function(u) if UnitAura(u, "Rejuvenation")           then return "|cff00FEBFRej|r" end end
oUF.Tags.Methods["tekregrow"] = function(u) if UnitAura(u, "Regrowth")               then return "|cff00FF10Rg|r" end end
oUF.Tags.Methods["tekflour"]  = function(u) if UnitAura(u, "Flourish")               then return "|cff33FF33Fl|r" end end
oUF.Tags.Methods["tekws"]     = function(u) if UnitDebuff(u, "Weakened Soul")        then return "|cffFF5500Ws|r" end end
oUF.Tags.Methods["tekpom"]    = function(u) local c = select(4, UnitAura(u, "Prayer of Mending")) if c then return "|cffFFCF7FPoM("..c..")|r" end end
oUF.Tags.Methods["teklb"]     = function(u) local c = select(4, UnitAura(u, "Lifebloom"))         if c then return "|cffA7FD0ALB("..c..")|r" end end

local function HasDebuffType(unit, t)
	for i=1,40 do
		local name, _, _, _, debuffType = UnitDebuff(unit, i)
		if not name then return
		elseif debuffType == t then return true end
	end
end

oUF.Tags.Methods["tekdisease"] = function(u) return HasDebuffType(u, "Disease") and "|cff996600Di|r" end
oUF.Tags.Methods["tekmagic"]   = function(u) return HasDebuffType(u, "Magic")   and "|cff3399FFMa|r" end
oUF.Tags.Methods["tekcurse"]   = function(u) return HasDebuffType(u, "Curse")   and "|cff9900FFCu|r" end
oUF.Tags.Methods["tekpoison"]  = function(u) return HasDebuffType(u, "Poison")  and "|cff009900Po|r" end

oUF.Tags.Events["teksacs"]   = "UNIT_AURA"
oUF.Tags.Events["tekbol"]    = "UNIT_AURA"
oUF.Tags.Events["tekmd"]     = "UNIT_AURA"
oUF.Tags.Events["tekss"]     = "UNIT_AURA"
oUF.Tags.Events["tekinn"]    = "UNIT_AURA"
oUF.Tags.Events["tekpws"]    = "UNIT_AURA"
oUF.Tags.Events["tekrenew"]  = "UNIT_AURA"
oUF.Tags.Events["tekfood"]   = "UNIT_AURA"
oUF.Tags.Events["tekdrink"]  = "UNIT_AURA"
oUF.Tags.Events["tekms"]     = "UNIT_AURA"
oUF.Tags.Events["tekws"]     = "UNIT_AURA"
oUF.Tags.Events["tekfw"]     = "UNIT_AURA"
oUF.Tags.Events["tekpom"]    = "UNIT_AURA"
oUF.Tags.Events["teklb"]     = "UNIT_AURA"
oUF.Tags.Events["tekrejuv"]  = "UNIT_AURA"
oUF.Tags.Events["tekregrow"] = "UNIT_AURA"
oUF.Tags.Events["tekflour"]  = "UNIT_AURA"

oUF.Tags.Events["tekdisease"] = "UNIT_AURA"
oUF.Tags.Events["tekmagic"]   = "UNIT_AURA"
oUF.Tags.Events["tekcurse"]   = "UNIT_AURA"
oUF.Tags.Events["tekpoison"]  = "UNIT_AURA"
