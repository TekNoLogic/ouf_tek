--[[-------------------------------------------------------------------------
  Trond A Ekseth grants anyone the right to use this work for any purpose,
  without any conditions, unless such conditions are required by law.
---------------------------------------------------------------------------]]

local texture = [[Interface\AddOns\oUF_Classic\textures\statusbar]]
local height, width = 47, 260

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local classification = {
	worldboss = 'B',
	rareelite = 'R',
	elite = '+',
	rare = 'r',
	normal = '',
	trivial = 't',
}

local updateInfoString = function(self, event, unit)
	if(unit ~= self.unit) then return end

	local level = UnitLevel(unit)
	if(level == -1) then
		level = '??'
	end

	local class, rclass = UnitClass(unit)
	local color = RAID_CLASS_COLORS[rclass]
	if(not UnitIsPlayer(unit)) then
		class = UnitCreatureFamily(unit) or UnitCreatureType(unit)
	end

	local happiness = GetPetHappiness()
	if(happiness == 1) then
		happiness = ":<"
	elseif(happiness == 2) then
		happiness = ":|"
	elseif(happiness == 3) then
		happiness = ":D"
	else
		happiness = ""
	end

	self.Info:SetFormattedText(
		"L%s%s |cff%02x%02x%02x%s|r %s",
		level,
		classification[UnitClassification(unit)],
		color.r*255, color.g*255, color.b*255,
		class,
		happiness
	)
end

local OverrideUpdateHealth = function(self, event, bar, unit, min, max)
	local color = self.colors.health[0]
	bar:SetStatusBarColor(color.r, color.g, color.b)
	bar.bg:SetVertexColor(color.r * .5, color.g * .5, color.b * .5)
	bar.value:SetFormattedText('%d/%d', min, max)
end

local PostUpdatePower = function(self, event, bar,unit, min, max)
	bar.value:SetFormattedText('%d/%d', min, max)
end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

local func = function(settings, self, unit)
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
	hp:SetWidth(width - 90)
	hp:SetHeight(14)
	hp:SetStatusBarTexture(texture)

	hp:SetParent(self)
	hp:SetPoint("TOP", 0, -8)
	hp:SetPoint("LEFT", 8, 0)

	self.Health = hp
	-- We have to override for now...
	self.OverrideUpdateHealth = OverrideUpdateHealth

	local hpp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	hpp:SetPoint("LEFT", hp, "RIGHT", 2, 0)
	hpp:SetPoint("RIGHT", self, -2, 0)
	hpp:SetFont(GameFontNormal:GetFont(), 11)
	hpp:SetTextColor(1, 1, 1)

	hp.value = hpp

	-- Health bar background
	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
	hp.bg = hpbg

	-- Power bar
	local pp = CreateFrame"StatusBar"
	pp:SetWidth(width - 90)
	pp:SetHeight(14)
	pp:SetStatusBarTexture(texture)

	pp:SetParent(self)
	pp:SetPoint("BOTTOM", 0, 8)
	pp:SetPoint("LEFT", 8, 0)

	self.Power = pp

	-- Power bar background
	local ppbg = pp:CreateTexture(nil, "BORDER")
	ppbg:SetAllPoints(pp)
	ppbg:SetTexture(texture)
	pp.bg = ppbg

	local ppp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	ppp:SetPoint("LEFT", pp, "RIGHT", 2, 0)
	ppp:SetPoint("RIGHT", self, -2, 0)
	ppp:SetFont(GameFontNormal:GetFont(), 11)
	ppp:SetTextColor(1, 1, 1)

	pp.value = ppp
	self.PostUpdatePower = PostUpdatePower

	-- Unit name
	local name = hp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	name:SetPoint("LEFT", 2, -1)
	name:SetPoint("RIGHT", -2, 0)
	name:SetJustifyH"LEFT"
	name:SetFont(GameFontNormal:GetFont(), 11)
	name:SetTextColor(1, 1, 1)

	self.Name = name

	-- Info string
	local info = pp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	info:SetPoint("LEFT", 2, -1)
	info:SetPoint("RIGHT", -2, 0)
	info:SetJustifyH"LEFT"
	info:SetFont(GameFontNormal:GetFont(), 11)
	info:SetTextColor(1, 1, 1)

	self.Info = info
	self.UNIT_LEVEL = updateInfoString
	self:RegisterEvent"UNIT_LEVEL"

	if(unit == "pet") then
		self.UNIT_HAPPINESS = updateInfoString
		self:RegisterEvent"UNIT_HAPPINESS"
	end
end

oUF:RegisterStyle("Classic", setmetatable({
	["initial-width"] = width,
	["initial-height"] = height,
}, {__call = func}))

-- hack to get our level information updated.
oUF:RegisterSubTypeMapping"UNIT_LEVEL"
oUF:SetActiveStyle"Classic"

local player = oUF:Spawn"player"
player:SetPoint("CENTER", 0, -400)
