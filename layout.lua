--[[-------------------------------------------------------------------------
  Trond A Ekseth grants anyone the right to use this work for any purpose,
  without any conditions, unless such conditions are required by law.
---------------------------------------------------------------------------]]

local texture = [[Interface\AddOns\oUF_tek\textures\statusbar]]
local smallheight, height, width = 31, 64, 170
local UnitReactionColor = UnitReactionColor
local gray = {r = .3, g = .3, b = .3}
local oUF = tekoUFembed
tekoUFembed = nil

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	local color = not UnitIsDeadOrGhost(unit) and (not UnitIsTapped(unit) or UnitIsTappedByPlayer(unit)) and UnitReactionColor[UnitReaction(unit, 'player')] or gray
	self:SetBackdropBorderColor(color.r, color.g, color.b)
end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}


---------------------------
--      Custom tags      --
---------------------------

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

oUF.Tags["[tekdisease]"] = function(u) return HasDebuffType(u, "Disease") and "|cff996600Di|r" or "" end
oUF.Tags["[tekmagic]"]   = function(u) return HasDebuffType(u, "Magic")   and "|cff3399FFMa|r" or "" end
oUF.Tags["[tekcurse]"]   = function(u) return HasDebuffType(u, "Curse")   and "|cff9900FFCu|r" or "" end
oUF.Tags["[tekpoison]"]  = function(u) return HasDebuffType(u, "Poison")  and "|cff009900Po|r" or "" end

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


------------------------------
--      Layout factory      --
------------------------------

local func = function(settings, self, unit)
	self.unit = unit
	self.menu = menu

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(.3, .3, .3, 1)

	-- Health bar
	local hp = CreateFrame"StatusBar"
	hp:SetStatusBarTexture(texture)

	hp:SetParent(self)
	hp:SetPoint("TOP", 0, -8)
	hp:SetPoint("LEFT", 8, 0)
	hp:SetPoint("RIGHT", -8, 0)

	hp.colorTapping = true
	hp.colorHappiness = true
	hp.colorDisconnected = true
	hp.colorClass = true
	hp.colorClassNPC = true
	hp.frequentUpdates = true

	self.Health = hp
	self.PostUpdateHealth = PostUpdateHealth

	local hpp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
	hpp:SetPoint("RIGHT", hp, -2, 0)
	hpp:SetTextColor(1, 1, 1)
	self:Tag(hpp, settings.size == 'partypet' and "[tekhp2]" or "[dead][offline][tekhp]")

	-- Health bar background
	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
	hpbg.multiplier = .5
	hp.bg = hpbg

	-- Unit name
	local name = hp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
	name:SetPoint("LEFT", 2, 0)
	name:SetPoint("RIGHT", hpp, "LEFT", -2, 0)
	name:SetJustifyH"LEFT"
	name:SetTextColor(1, 1, 1)
	self:Tag(name, settings.size == 'partypet' and "[tekpet]" or "[name][leader]")

	-- Power bar
	local pp = CreateFrame"StatusBar"
	pp:SetStatusBarTexture(texture)

	pp:SetParent(self)
	pp:SetPoint("LEFT", 8, 0)
	pp:SetPoint("RIGHT", -8, 0)

	pp.colorTapping = true
	pp.colorDisconnected = true
	pp.colorPower = true

	self.Power = pp

	-- Power bar background
	local ppbg = pp:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(pp)
	ppbg:SetTexture(texture)
	ppbg.multiplier = .5
	pp.bg = ppbg


	if settings.size == 'partypet' then
		name:SetPoint("LEFT", 2, 1)
		name:SetPoint("RIGHT", -2, 0)
		hpp:SetPoint("RIGHT", hp, -2, 1)

		hp:SetHeight(14)

		pp:Hide()
		ppbg:Hide()
		self.Power = nil

	elseif settings.size == 'small' or settings.size == 'party' then
		name:SetPoint("LEFT", 2, 1)
		hpp:SetPoint("RIGHT", hp, -2, 1)

		hp:SetHeight(10)
		pp:SetHeight(4)
		pp:SetPoint("BOTTOM", 0, 8)

	else
		hp:SetHeight(14)
		pp:SetHeight(14)
		pp.colorPower = true
		pp.frequentUpdates = true

		local ppp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
		ppp:SetPoint("RIGHT", pp, -2, 0)
		ppp:SetTextColor(1, 1, 1)
		ppp.frequentUpdates = self.unit == "player"
		self:Tag(ppp, "[tekpp]")

		-- Info string
		local info = pp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
		info:SetPoint("LEFT", 2, 0)
		info:SetPoint("RIGHT", ppp, "LEFT", -2, 0)
		info:SetJustifyH"LEFT"
		info:SetTextColor(1, 1, 1)
		self:Tag(info, "[difficulty][smartlevel][( )rare] [raidcolor][smartclass]")

		local cast = CreateFrame"StatusBar"
		cast:SetWidth(width - 16 -14)
		cast:SetHeight(14)
		cast:SetStatusBarTexture(texture)
		cast:SetStatusBarColor(.8, .8, 0)

		cast:SetParent(self)
		cast:SetPoint("BOTTOM", 0, 8)
		cast:SetPoint("LEFT", 8 + 14, 0)

		local castbg = cast:CreateTexture(nil, "BORDER")
		castbg:SetAllPoints()
		castbg:SetTexture(texture)
		castbg:SetVertexColor(.4, .4, 0)
		cast.bg = castbg

		local castime = cast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
		castime:SetPoint("RIGHT", cast, -2, 0)
		castime:SetTextColor(1, 1, 1)
		cast.Time = castime

		local castext = cast:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
		castext:SetPoint("LEFT", cast, 2, 0)
		castext:SetPoint("RIGHT", castime, "LEFT", -2, 0)
		castext:SetJustifyH"LEFT"
		castext:SetTextColor(1, 1, 1)
		cast.Text = castext


		local casticon = cast:CreateTexture(nil, "BORDER")
		casticon:SetPoint("RIGHT", cast, "LEFT")
		casticon:SetWidth(14) casticon:SetHeight(14)
		cast.Icon = casticon

		self.Castbar = cast
	end

	local auratags = "[tekcurse( )][tekpoison( )][tekdisease( )][tekmagic( )][tekms( )][tekmd( )][tekgs( )][tekbol( )][teksacs( )][tekpws( )][tekws( )][tekflour( )][teklb( )][tekregrow( )][tekrejuv( )][tekrenew( )][tekpom( )][tekss( )][tekfw( )][tekinn( )][tekfood( )][tekdrink]"
	if(unit ~= 'player') then
		if settings.size == 'party' then
			local auras = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			auras:SetPoint("LEFT", self, "RIGHT")
			auras:SetTextColor(1, 1, 1)
			self:Tag(auras, auratags)

		elseif settings.size == 'partypet' then
			local auras = self:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
			auras:SetPoint("RIGHT", self, "LEFT")
			auras:SetTextColor(1, 1, 1)
			self:Tag(auras, auratags)

		else
			-- Buffs
			local buffs = CreateFrame("Frame", nil, self)
			if settings.size == 'small' then buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT") else buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT") end
			buffs:SetHeight(16)
			buffs:SetWidth(width/2)

			buffs.size = 16
			buffs.num = math.floor(width / buffs.size + .5)
			buffs["growth-y"] = settings.size == 'small' and "UP" or "DOWN"

			self.Buffs = buffs

			-- Debuffs
			local debuffs = CreateFrame("Frame", nil, self)
			if settings.size == 'small' then debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT") else debuffs:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT") end
			debuffs:SetHeight(16)
			debuffs:SetWidth(width/2)

			debuffs.initialAnchor = settings.size == 'small' and "BOTTOMRIGHT" or "TOPRIGHT"
			debuffs["growth-x"] = "LEFT"
			debuffs["growth-y"] = settings.size == 'small' and "UP" or "DOWN"
			debuffs.size = 16
			debuffs.num = math.floor(width / debuffs.size + .5)

			self.Debuffs = debuffs
		end
	else
	end

	local leader = self:CreateTexture(nil, "OVERLAY")
	leader:SetHeight(16)
	leader:SetWidth(16)
	leader:SetPoint("LEFT", self, "TOPLEFT", 15, 0)
	leader:SetTexture[[Interface\GroupFrame\UI-Group-LeaderIcon]]
	self.Leader = leader

	-- Raid icon
	local ricon = self:CreateTexture(nil, "OVERLAY")
	ricon:SetHeight(16)
	ricon:SetWidth(16)
	ricon:SetPoint("CENTER", self, "TOP")
	ricon:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]
	self.RaidIcon = ricon

	-- Threat icon
	local threat = self:CreateTexture(nil, "OVERLAY")
	threat:SetHeight(20)
	threat:SetWidth(20)
	threat:SetPoint("CENTER", self, "TOPRIGHT", -4, -4)
	threat:SetTexture([[Interface\Minimap\ObjectIcons]])
	threat:SetTexCoord(6/8, 7/8, 1/2, 1)
	self.Threat = threat

	-- PvP icon
	local pvp = self:CreateTexture(nil, "OVERLAY")
	pvp:SetHeight(32)
	pvp:SetWidth(32)
	if settings.size then pvp:SetPoint("CENTER", self, "LEFT", 6, -6) else pvp:SetPoint("CENTER", self, "BOTTOMLEFT", 12, 0) end
	self.PvP = pvp

	if unit == "player" then
		-- Resting icon
		local rest = self:CreateTexture(nil, "OVERLAY")
		rest:SetHeight(24)
		rest:SetWidth(24)
		rest:SetPoint("CENTER", self, "TOPLEFT", 5, -1)
		rest:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		rest:SetTexCoord(0, 1/2, 0, 0.421875)
		self.Resting = rest

		local combat = self:CreateTexture(nil, "OVERLAY")
		combat:SetHeight(24)
		combat:SetWidth(24)
		combat:SetPoint("CENTER", self, "BOTTOMRIGHT", -5, 5)
		combat:SetTexture([[Interface\CharacterFrame\UI-StateIcon]])
		combat:SetTexCoord(1/2, 1, 0.01, 0.5)
		self.Combat = combat

	end

	-- Range fading on party
	if(not unit) then
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .65
	end
end

oUF:RegisterStyle("Classic", setmetatable({
	["initial-width"] = width,
	["initial-height"] = height,
}, {__call = func}))

oUF:RegisterStyle("Classic - Small", setmetatable({
	["initial-width"] = width,
	["initial-height"] = smallheight,
	["size"] = 'small',
}, {__call = func}))

oUF:RegisterStyle("Classic - Party", setmetatable({
	["initial-width"] = width,
	["initial-height"] = smallheight,
	["size"] = 'party',
}, {__call = func}))

oUF:RegisterStyle("Classic - PartyPet", setmetatable({
	["initial-width"] = width/2,
	["initial-height"] = smallheight,
	["size"] = 'partypet',
}, {__call = func}))


-----------------------
--      Cluster      --
-----------------------

oUF:SetActiveStyle"Classic"

local player = oUF:Spawn"player"
player:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOM", 0, 80)

local target = oUF:Spawn"target"
target:SetPoint("LEFT", player, "RIGHT")

oUF:SetActiveStyle"Classic - Small"

local pet = oUF:Spawn"pet"
pet:SetPoint('BOTTOMRIGHT', player, 'TOPRIGHT')

local focus = oUF:Spawn"focus"
focus:SetPoint("BOTTOMLEFT", target, "TOPLEFT")


----------------------------
--      Party frames      --
----------------------------

oUF:SetActiveStyle("Classic - Party")

local party = oUF:Spawn("header", "oUF_Party")
party:SetPoint("TOPLEFT", UIParent, "LEFT", 300, 0)
party:SetManyAttributes(
	"showParty", true,
	"yOffset", 0, -- -smallheight,
	"xOffset", -40
)
party:Show()


local tanks = oUF:Spawn("header", "oUF_Tanks")
tanks:SetPoint("BOTTOM", party, "TOP", 0, 20)
tanks:SetManyAttributes(
	"showRaid", true,
	"yOffset", 0, -- -smallheight,
	"xOffset", -40,
	"groupFilter", "MAINTANK,MAINASSIST"
)
tanks:Show()


oUF:SetActiveStyle("Classic - PartyPet")

local partypets = oUF:Spawn("header", "oUF_PartyPets", "SecureGroupPetHeaderTemplate")
partypets:SetPoint("TOPRIGHT", party, "TOPLEFT")
partypets:SetManyAttributes(
	"showParty", true,
	"yOffset", 0, -- -smallheight,
	"xOffset", -40
)
partypets:Show()




---------------------------
--      Rune frames      --
---------------------------

RuneButtonIndividual4:ClearAllPoints()
RuneButtonIndividual4:SetPoint("RIGHT", player, "LEFT", -2, 0)

RuneButtonIndividual2:ClearAllPoints()
RuneButtonIndividual2:SetPoint("BOTTOM", RuneButtonIndividual4, "TOP", 0, 4)

RuneButtonIndividual6:ClearAllPoints()
RuneButtonIndividual6:SetPoint("TOP", RuneButtonIndividual4, "BOTTOM", 0, -4)

RuneButtonIndividual5:ClearAllPoints()
RuneButtonIndividual5:SetPoint("RIGHT", RuneButtonIndividual6, "LEFT", -4, 0)

RuneButtonIndividual3:ClearAllPoints()
RuneButtonIndividual3:SetPoint("RIGHT", RuneButtonIndividual4, "LEFT", -4, 0)

RuneButtonIndividual1:ClearAllPoints()
RuneButtonIndividual1:SetPoint("RIGHT", RuneButtonIndividual2, "LEFT", -4, 0)

