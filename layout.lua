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

local OverrideUpdateHealth = function(self, event, bar, unit, min, max)
	local color = self.colors.health[0]
	bar:SetStatusBarColor(color.r, color.g, color.b)
	bar.bg:SetVertexColor(color.r * .5, color.g * .5, color.b * .5)
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
	self:SetBackdropBorderColor(.5, .5, .5, 1)

	-- Health bar
	local hp = CreateFrame"StatusBar"
	hp:SetWidth(width - 90)
	hp:SetHeight(14)
	hp:SetStatusBarTexture(texture)

	hp:SetParent(self)
	hp:SetPoint("TOP", 0, -6)
	hp:SetPoint("LEFT", 6, 0)

	self.Health = hp
	-- We have to override for now...
	self.OverrideUpdateHealth = OverrideUpdateHealth

	-- Health bar background
	local hpbg = hp:CreateTexture(nil, "BORDER")
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
	hp.bg = hpbg
end

oUF:RegisterStyle("Classic", setmetatable({
	["initial-width"] = width,
	["initial-height"] = height,
}, {__call = func}))

oUF:SetActiveStyle"Classic"

local player = oUF:Spawn"player"
player:SetPoint("CENTER", 0, -400)
