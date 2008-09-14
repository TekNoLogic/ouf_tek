--[[-------------------------------------------------------------------------
  Trond A Ekseth grants anyone the right to use this work for any purpose,
  without any conditions, unless such conditions are required by law.
---------------------------------------------------------------------------]]

local texture = [[Interface\AddOns\oUF_tek\textures\statusbar]]
local smallheight, height, width = 31, 64, 170
local UnitReactionColor = UnitReactionColor
local gray = {r = .3, g = .3, b = .3}

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
	rareelite = 'R+',
	elite = '+',
	rare = 'R',
	normal = '',
	trivial = 't',
}

local updateInfoString = function(self, event, unit)
	if(unit ~= self.unit) then return end

	local level = UnitLevel(unit)
	if level == -1 then level = '??' end

	local class, rclass = UnitClass(unit)
	local color = RAID_CLASS_COLORS[rclass]
	if not UnitIsPlayer(unit) then class = UnitCreatureFamily(unit) or UnitCreatureType(unit) end

	local happiness
	if(unit == 'pet') then
		happiness = GetPetHappiness()
		if(happiness == 1) then
			happiness = ":("
		elseif(happiness == 2) then
			happiness = ":|"
		end
	end

	local classifcation = UnitClassification(unit)
	if classifcation == "worldboss" then
		self.Info:SetFormattedText("Boss |cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, class)
	else
		self.Info:SetFormattedText("L%s%s |cff%02x%02x%02x%s|r %s", level, classification[UnitClassification(unit)], color.r * 255, color.g * 255, color.b * 255, class, happiness or '')
	end
end

local PostUpdateHealth = function(self, event, unit, bar, min, max)
	if unit ~= player then
		color = (not UnitIsTapped(unit) or UnitIsTappedByPlayer(unit)) and UnitReactionColor[UnitReaction(unit, 'player')] or gray
		self:SetBackdropBorderColor(color.r, color.g, color.b)
	end

	if(UnitIsDead(unit)) then
		bar.value:SetText"Dead"
	elseif(UnitIsGhost(unit)) then
		bar.value:SetText"Ghost"
	elseif(not UnitIsConnected(unit)) then
		bar.value:SetText"Offline"
	elseif unit ~= "player" then
		bar.value:SetFormattedText('%d%%', min/max*100)
	elseif min == max then
		bar.value:SetText(max)
	else
		bar.value:SetFormattedText('|cffff0000%s|r', min-max)
	end
end

local PostUpdatePower = function(self, event, unit, bar, min, max)
	if min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then bar:SetValue(0) end

	if bar.value then
		if min == 0 or UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit) then
			bar.value:SetText()
		elseif min >= max then
			bar.value:SetText(max == 100 and "" or max)
		else
			bar.value:SetFormattedText('%d%%', min/max*100)
		end
	end
end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}

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
	hp:SetWidth(width - 16)
	hp:SetHeight(14)
	hp:SetStatusBarTexture(texture)

	hp:SetParent(self)
	hp:SetPoint("TOP", 0, -8)
	hp:SetPoint("LEFT", 8, 0)

	hp.colorTapping = true
	hp.colorHappiness = true
	hp.colorDisconnected = true
	hp.colorClass = true
	hp.colorReaction = true

	self.Health = hp
	self.PostUpdateHealth = PostUpdateHealth

	local hpp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
	hpp:SetPoint("RIGHT", hp, -2, 0)
	hpp:SetTextColor(1, 1, 1)

	hp.value = hpp

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

	self.Name = name

	if settings.size == 'small' then
		name:SetPoint("LEFT", 2, 1)
		hpp:SetPoint("RIGHT", hp, -2, 1)
		hp:SetHeight(10)

		-- Power bar
		local pp = CreateFrame"StatusBar"
		pp:SetWidth(width - 16)
		pp:SetHeight(4)
		pp:SetStatusBarTexture(texture)

		pp:SetParent(self)
		pp:SetPoint("BOTTOM", 0, 8)
		pp:SetPoint("LEFT", 8, 0)

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

		self.PostUpdatePower = PostUpdatePower
	else
		-- Power bar
		local pp = CreateFrame"StatusBar"
		pp:SetWidth(width - 16)
		pp:SetHeight(14)
		pp:SetStatusBarTexture(texture)

		pp:SetParent(self)
		pp:SetPoint("LEFT", 8, 0)

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

		local ppp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
		ppp:SetPoint("RIGHT", pp, -2, 0)
		ppp:SetTextColor(1, 1, 1)

		pp.value = ppp
		self.PostUpdatePower = PostUpdatePower

		-- Info string
		local info = pp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
		info:SetPoint("LEFT", 2, 0)
		info:SetPoint("RIGHT", ppp, "LEFT", -2, 0)
		info:SetJustifyH"LEFT"
		info:SetTextColor(1, 1, 1)

		self.Info = info
		self.UNIT_LEVEL = updateInfoString
		self:RegisterEvent"UNIT_LEVEL"

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

		if(unit == "pet") then
			self.UNIT_HAPPINESS = updateInfoString
			self:RegisterEvent"UNIT_HAPPINESS"
		end
	end

	if(unit ~= 'player') then
		-- Buffs
		local buffs = CreateFrame("Frame", nil, self)
		if settings.size == 'small' then buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT") else buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT") end
		buffs:SetHeight(16)
		buffs:SetWidth(width/2)

		buffs.size = 16
		buffs.num = math.floor(width / buffs.size + .5)

		self.Buffs = buffs

		-- Debuffs
		local debuffs = CreateFrame("Frame", nil, self)
		if settings.size == 'small' then debuffs:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT") else debuffs:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT") end
		debuffs:SetHeight(16)
		debuffs:SetWidth(width/2)

		debuffs.initialAnchor = settings.size == 'small' and "BOTTOMRIGHT" or "TOPRIGHT"
		debuffs["growth-x"] = "LEFT"
--~ 		debuffs.initialAnchor = settings.size == 'small' and "BOTTOMRIGHT" or "TOPRIGHT"
		debuffs.size = 16
		debuffs.num = math.floor(width / debuffs.size + .5)

		self.Debuffs = debuffs
	else
		self:RegisterEvent"PLAYER_UPDATE_RESTING"
		self.PLAYER_UPDATE_RESTING = function(self)
			if InCombatLockdown() then return end

			if IsResting() then
				self:SetBackdropBorderColor(1,1,0)
			else
				self:SetBackdropBorderColor(0,1,0)
			end
		end

		self:RegisterEvent"PLAYER_REGEN_DISABLED"
		self.PLAYER_REGEN_DISABLED = function(self)
			if not UnitAffectingCombat"player" then return end
			self:SetBackdropBorderColor(1,0,0)
		end

		self:RegisterEvent"PLAYER_REGEN_ENABLED"
		self.PLAYER_REGEN_ENABLED = self.PLAYER_UPDATE_RESTING
	end

	local leader = self:CreateTexture(nil, "OVERLAY")
	leader:SetHeight(16)
	leader:SetWidth(16)
	leader:SetPoint("LEFT", self, "TOPLEFT", 5, 0)
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

	-- Range fading on party
	if(not unit) then
		self.Range = true
		self.inRangeAlpha = 1
		self.outsideRangeAlpha = .5
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

-- hack to get our level information updated.
oUF:RegisterSubTypeMapping"UNIT_LEVEL"
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

