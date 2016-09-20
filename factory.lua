
local myname, ns = ...
local oUF = ns.oUF

local texture = [[Interface\AddOns\oUF_tek\textures\statusbar]]
local smallheight, height, width = 31, 64, 170
local UnitReactionColor = {
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.0, b = 0.0 },
	{ r = 1.0, g = 0.5, b = 0.0 },
	{ r = 1.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
	{ r = 0.0, g = 1.0, b = 0.0 },
}
local gray = {r = .3, g = .3, b = .3}
local focus_highlight = {r = 1, g = 0, b = 1}

local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
end

local function GetBorderColor(self, unit)
	if self.istankframe and UnitExists("focus") and UnitIsUnit(unit, "focus") then
		return focus_highlight
	elseif not (UnitIsDeadOrGhost(unit) or UnitIsTapDenied(unit)) then
		return UnitReactionColor[UnitReaction(unit, 'player')]
	end
end

local PostUpdateHealth = function(self, unit, bar, min, max)
	self = self.hpparent or self
	local color = GetBorderColor(self, unit) or gray
	self:SetBackdropBorderColor(color.r, color.g, color.b)
end
local function Update_Focus_Highlight(self, event, ...) PostUpdateHealth(self, self.unit) end

local backdrop = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4},
}


------------------------------
--      Layout factory      --
------------------------------

local func = function(settings, self, unit, isSingle)
	self.istankframe = self:GetParent():GetName() == "oUF_Tanks"
	if self.istankframe then
		self.PLAYER_FOCUS_CHANGED = Update_Focus_Highlight
		self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	end

	self.unit = unit
	self.menu = menu

	if isSingle then
		if settings.size == 'partypet' then
			self:SetWidth(width/2)
		else
			self:SetWidth(width)
		end

		if settings.size == 'partypet' or settings.size == 'small' or settings.size == 'party' then
			self:SetHeight(smallheight)
		else
			self:SetHeight(height)
		end
	end

	self:SetScript("OnEnter", UnitFrame_OnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	self:RegisterForClicks"anyup"
	self:SetAttribute("*type2", "menu")

	self:SetBackdrop(backdrop)
	self:SetBackdropColor(0, 0, 0, 1)
	self:SetBackdropBorderColor(.3, .3, .3, 1)

	-- Health bar
	local hp = CreateFrame("StatusBar")
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
	hp.hpparent = self
	hp.PostUpdate = PostUpdateHealth

	local hpp = hp:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") --"GameFontNormal")
	hpp:SetPoint("RIGHT", hp, -2, 0)
	hpp:SetTextColor(1, 1, 1)
	self:Tag(hpp, settings.size == 'partypet' and "[tekhp2]" or "[dead][offline][tekhp]")

	-- My incoming heals
	local myhpin = CreateFrame("StatusBar", nil, hp)
	myhpin:SetWidth(width)
	myhpin:SetStatusBarTexture(texture)
	myhpin:SetStatusBarColor(0, 1, 0.5, 0.25)

	myhpin:SetPoint("TOPLEFT", hp:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	myhpin:SetPoint("BOTTOMLEFT", hp:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

	-- Other player's incoming heals
	local othhpin = CreateFrame("StatusBar", nil, hp)
	othhpin:SetWidth(width)
	othhpin:SetStatusBarTexture(texture)
	othhpin:SetStatusBarColor(0, 1, 0.5, 0.25)

	othhpin:SetPoint("TOPLEFT", myhpin:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
	othhpin:SetPoint("BOTTOMLEFT", myhpin:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)

	self.HealPrediction = {maxOverflow = 1.0, myBar = myhpin, otherBar = othhpin}

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
	self:Tag(name, settings.size == 'partypet' and "[tekpet]" or "[name][ >leader]")

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
		pp:SetPoint("TOP", 0, -25)
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
		self:Tag(info, "[difficulty][teklevel][ >rare][ >tekquest] [raidcolor][smartclass]")

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

		local shield = cast:CreateTexture(nil, "BORDER")
		shield:SetDrawLayer("BORDER", -1)
		shield:SetPoint("CENTER", casticon)
		shield:SetSize(26, 26)
		shield:SetTexture("Interface\\Buttons\\UI-Button-Outline")
		cast.Shield = shield

		self.Castbar = cast
	end

	local auratags = "[tekcurse< ][tekpoison< ][tekdisease< ][tekmagic< ][tekms< ][tekmd< ][tekgs< ][tekbol< ][teksacs< ][tekpws< ][tekws< ][tekflour< ][teklb< ][tekregrow< ][tekrejuv< ][tekrenew< ][tekpom< ][tekss< ][tekfw< ][tekinn< ][tekfood< ][tekdrink]"
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
			if settings.size == 'small' then
				buffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT")
			else
				buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
			end
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

	local role = self:CreateTexture(nil, "OVERLAY")
	role:SetHeight(16)
	role:SetWidth(16)
	role:SetPoint("RIGHT", self, "TOPRIGHT", -10, -1)
	self.LFDRole = role

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
	if settings.size then
		pvp:SetPoint("CENTER", self, "LEFT", 6, -6)
	else
		pvp:SetPoint("CENTER", self, "BOTTOMLEFT", 12, 0)
	end

	self.PvP = pvp

	if unit == "player" then
		-- PvP details
		local pvpframe = CreateFrame("Frame", nil, self)
		pvpframe:SetHeight(32)
		pvpframe:SetWidth(32)
		pvpframe:SetPoint("CENTER", self, "BOTTOMLEFT", 12, 0)

		pvp:SetParent(pvpframe)
		function pvpframe:SetTexture(...) pvp:SetTexture(...) end

		local pvptime = pvpframe:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		pvptime:SetPoint("BOTTOMRIGHT", pvpframe, "LEFT", 4, 0)

		pvpframe:SetScript("OnUpdate", function()
			local endtime = GetPVPTimer()
			local now = GetTime()
			if not endtime then return end

			if endtime > 300000 then
				pvptime:SetText("∞")
			else
				local minutes = math.floor(endtime/1000/60)
				local seconds = math.floor(endtime/1000) % 60
				pvptime:SetText(("%d:%02d"):format(minutes, seconds))
				-- if minutes > 0 then
				-- else
				-- 	pvptime:SetText(seconds.. "s")
				-- end
			end
		end)

		self.PvP = pvpframe


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

		local dm = CreateFrame("StatusBar")
		dm:SetStatusBarTexture(texture)
		dm:SetParent(self)
		dm:SetHeight(4)
		dm:SetPoint("TOPLEFT", pp, "BOTTOMLEFT", 0, -1)
		dm:SetPoint("TOPRIGHT", pp, "BOTTOMRIGHT", 0, -1)
		dm.colorSmooth = true
		dm.smoothGradient = {
			1, 0, 0,
			1, 1, 0,
			0, 1, 1,
			0, 0, 1,
		}
		dm:SetScript("OnShow", function() pp:SetHeight(10) end)
		dm:SetScript("OnHide", function() pp:SetHeight(14) end)
		dm:Hide()
		self.DruidMana = dm

		local dmbg = dm:CreateTexture(nil, "BORDER")
		dmbg:SetAllPoints(dm)
		dmbg:SetTexture(texture)
		dmbg.multiplier = .5
		dm.bg = dmbg

		local _, myclass = UnitClass("player")
		local icons = {}
		local atlas
		if myclass == "MAGE" then
			atlas = "Mage-ArcaneCharge"
		elseif myclass == "MONK" then
			atlas = "MonkUI-LightOrb"
		elseif myclass == "WARLOCK" then
			atlas = "nameplate-WarlockShard-On"
		end

		function icons:UpdateTexture() end

		function icons:PostUpdate(cur, max, hasMaxChanged, powerType, event)
			if event == "ClassPowerDisable" then return end
			for i=1,max do
				local icon = self[i]
				if i > cur then
					icon:Show()
					icon:SetAlpha(0.3)
				else
					icon:SetAlpha(1)
				end
			end
		end

		for index = 1, 6 do
			local icon = self:CreateTexture(nil, "BACKGROUND")

			-- Position and size.
			icon:SetSize(16, 16)
			icon:SetPoint("TOPLEFT", self, "BOTTOMLEFT", index * 16, 0)

			-- Set texture
			if atlas then icon:SetAtlas(atlas) end

			if myclass == "PALADIN" then
				icon:SetTexture("Interface\\PlayerFrame\\PaladinPowerTextures")
				icon:SetTexCoord(0.28125000, 0.38671875, 0.64843750, 0.81250000)
			end

			icons[index] = icon
    end

    -- Register with oUF
    self.ClassIcons = icons
	end

	local phase = self:CreateTexture(nil, "ARTWORK")
	phase:SetSize(25, 25)
	phase:SetPoint("RIGHT", self, "LEFT")
	phase:SetAlpha(0.6)
	self.Phase = phase

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
