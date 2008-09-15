--[[
	Elements handled: .Health

	Shared:
	 The following settings are listed by priority:
	 - colorTapping
	 - colorDisconnected
	 - colorHappiness
	 - colorClass (Colors player units based on class)
	 - colorClassNPC (Colors non-player units based on class)
	 - colorReaction
	 - colorSmooth - will use smoothGradient instead of the internal gradient if set.

	Background:
	 - multiplier - number used to manipulate the power background. (default: 1)

	WotLK only:
	 - frequentUpdates - do OnUpdate polling of health data.

	Functions that can be overridden from within a layout:
	 - :PreUpdateHealth(event, unit)
	 - :OverrideUpdateHealth(event, unit, bar, min, max) - Setting this function
	 will disable the above color settings.
	 - :PostUpdateHealth(event, unit, bar, min, max)
--]]
local parent = debugstack():match[[Interface\AddOns\(.-)\]]
local global = GetAddOnMetadata(parent, 'X-oUF')
assert(global, 'X-oUF needs to be defined in the parent add-on.')
local oUF = _G[global]

local OnHealthUpdate
do
	local UnitHealth = UnitHealth
	OnHealthUpdate = function(self)
		if(self.disconnected) then return end
		local health = UnitHealth(self.unit)

		if(health ~= self.min) then
			self:SetValue(health)
			self.min = health

			self:GetParent():UNIT_MAXHEALTH("OnHealthUpdate", self.unit)
		end
	end
end

function oUF:UNIT_MAXHEALTH(event, unit)
	if(self.unit ~= unit) then return end
	if(self.PreUpdateHealth) then self:PreUpdateHealth(event, unit) end

	local min, max = UnitHealth(unit), UnitHealthMax(unit)
	local bar = self.Health
	bar:SetMinMaxValues(0, max)
	bar:SetValue(min)

	bar.disconnected = not UnitIsConnected(unit)
	bar.unit = unit

	if(not self.OverrideUpdateHealth) then
		local r, g, b, t
		if(bar.colorTapping and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then
			t = self.colors.tapped
		elseif(bar.colorDisconnected and not UnitIsConnected(unit)) then
			t = self.colors.disconnected
		elseif(bar.colorHappiness and unit == "pet" and GetPetHappiness()) then
			t = self.colors.happiness[GetPetHappiness()]
		elseif(bar.colorClass and UnitIsPlayer(unit)) or (bar.colorClassNPC and not UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		elseif(bar.colorReaction) then
			t = self.colors.reaction[UnitReaction(unit, "player")]
		elseif(bar.colorSmooth and max ~= 0) then
			r, g, b = self.ColorGradient(min / max, unpack(bar.smoothGradient or self.colors.smooth))
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(b) then
			bar:SetStatusBarColor(r, g, b)

			local bg = bar.bg
			if(bg) then
				local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end
	else
		self:OverrideUpdateHealth(event, unit, bar, min, max)
	end

	if(self.PostUpdateHealth) then self:PostUpdateHealth(event, unit, bar, min, max) end
end
oUF.UNIT_HEALTH = oUF.UNIT_MAXHEALTH

table.insert(oUF.subTypes, function(self)
	local health = self.Health
	if(health) then
		if(health.frequentUpdates and (self.unit and not self.unit:match'%w+target$') or not self.unit) then
			health:SetScript('OnUpdate', OnHealthUpdate)
		else
			self:RegisterEvent"UNIT_HEALTH"
		end
		self:RegisterEvent"UNIT_MAXHEALTH"
		self:RegisterEvent'UNIT_HAPPINESS'
		-- For tapping.
		self:RegisterEvent'UNIT_FACTION'

		if(not health:GetStatusBarTexture()) then
			health:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end
	end
end)
oUF:RegisterSubTypeMapping"UNIT_MAXHEALTH"