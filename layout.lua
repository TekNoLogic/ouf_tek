
local myname, ns = ...
local oUF = ns.oUF


-----------------------
--      Cluster      --
-----------------------

oUF:SetActiveStyle("Classic")

local player = oUF:Spawn("player")
player:SetPoint("BOTTOMRIGHT", WorldFrame, "BOTTOM", 0, 80)

local target = oUF:Spawn("target")
target:SetPoint("LEFT", player, "RIGHT")

local boss1 = oUF:Spawn("boss1")
boss1:SetPoint("TOPRIGHT", WorldFrame, "TOP", 0, -30)

local boss2 = oUF:Spawn("boss2")
boss2:SetPoint("LEFT", boss1, "RIGHT")

local boss3 = oUF:Spawn("boss3")
boss3:SetPoint("LEFT", boss2, "RIGHT")

local boss4 = oUF:Spawn("boss4")
boss4:SetPoint("RIGHT", boss1, "LEFT")


oUF:SetActiveStyle("Classic - Small")

local pet = oUF:Spawn("pet")
pet:SetPoint('BOTTOMRIGHT', player, 'TOPRIGHT')

local focus = oUF:Spawn("focus")
focus:SetPoint("BOTTOMLEFT", target, "TOPLEFT")


----------------------------
--      Party frames      --
----------------------------

oUF:SetActiveStyle("Classic - Party")

local party = oUF:SpawnHeader("oUF_Party", nil, "party,raid",
	"showParty", true,
	"yOffset", 0,
	"xOffset", -40,
	'oUF-initialConfigFunction', [[ self:SetWidth(170) self:SetHeight(31) ]])
party:SetPoint("TOPLEFT", UIParent, "LEFT", 300, 0)

-- local tanks = oUF:Spawn("header", "oUF_Tanks")
-- tanks:SetPoint("BOTTOM", party, "TOP", 0, 20)
-- tanks:SetAttribute("showRaid", true)
-- tanks:SetAttribute("yOffset", 0)
-- tanks:SetAttribute("xOffset", -40)
-- tanks:SetAttribute("groupFilter", "MAINTANK,MAINASSIST")
-- tanks:Show()
--
--
-- local ptanks = oUF:Spawn("header", "oUF_Tanks")
-- ptanks:SetPoint("BOTTOM", tanks, "TOP", 0, 0)
-- ptanks:SetAttribute("showRaid", true)
-- ptanks:SetAttribute("yOffset", 0)
-- ptanks:SetAttribute("xOffset", -40)
-- ptanks:SetAttribute("nameList", "")
-- ptanks:Show()
--
--
-- local mytanks = {}
-- SLASH_OUF_TEK_TANK1 = "/ptank"
-- SlashCmdList.OUF_TEK_TANK = function(msg)
-- 	if InCombatLockdown() then return print("Cannot set personal tanks in combat!") end
--
-- 	local name = msg ~= "" and msg or UnitName("target")
-- 	local found
-- 	for i,n in pairs(mytanks) do
-- 		if n == name then
-- 			found = true
-- 			table.remove(mytanks, i)
-- 		end
-- 	end
-- 	if not found then table.insert(mytanks, name) end
--
-- 	ptanks:SetAttribute("nameList", table.concat(mytanks, ","))
-- end
--
--
-- oUF:SetActiveStyle("Classic - PartyPet")
--
-- local lastpet
-- for i=1,4 do
-- 	local pet = oUF:Spawn("partypet"..i)
-- 	pet:SetPoint("TOPRIGHT", lastpet or party, lastpet and "BOTTOMRIGHT" or "TOPLEFT")
-- 	lastpet = pet
-- end


---------------------------
--      Rune frames      --
---------------------------

for i=1,6 do _G["RuneButtonIndividual"..i]:ClearAllPoints() end

RuneButtonIndividual4:SetPoint("RIGHT", player, "LEFT", -2, 0)
RuneButtonIndividual2:SetPoint("BOTTOM", RuneButtonIndividual4, "TOP", 0, 4)
RuneButtonIndividual6:SetPoint("TOP", RuneButtonIndividual4, "BOTTOM", 0, -4)
RuneButtonIndividual5:SetPoint("RIGHT", RuneButtonIndividual6, "LEFT", -4, 0)
RuneButtonIndividual3:SetPoint("RIGHT", RuneButtonIndividual4, "LEFT", -4, 0)
RuneButtonIndividual1:SetPoint("RIGHT", RuneButtonIndividual2, "LEFT", -4, 0)


---------------------------
--      Eclipse bar      --
---------------------------

local f = CreateFrame("Frame", nil, UIParent)
f:SetWidth(1) f:SetHeight(1)
f:SetPoint("TOP", player, "BOTTOM", 0, -20)
f.unit = "player"
EclipseBarFrame:SetParent(f)
EclipseBarFrame:ClearAllPoints()
EclipseBarFrame:SetPoint("CENTER")


-------------------------
--      HOLY POWA      --
-------------------------

PaladinPowerBar:SetParent(player)
PaladinPowerBar:ClearAllPoints()
PaladinPowerBar:SetPoint("TOP", player, "BOTTOM", 0, 7)


--------------------------
--      Holy balls      --
--------------------------

PriestBarFrame:SetParent(player)
PriestBarFrame:ClearAllPoints()
PriestBarFrame:SetPoint("TOP", player, "BOTTOM", 0, 4)


---------------------------
--      Monky balls      --
---------------------------

MonkHarmonyBar:SetParent(player)
MonkHarmonyBar:ClearAllPoints()
MonkHarmonyBar:SetPoint("TOP", player, "BOTTOM", 0, 18)


---------------------------------------------
--      I think I sharded in my pants      --
---------------------------------------------

ShardBarFrame:SetParent(player)
ShardBarFrame:ClearAllPoints()
ShardBarFrame:SetPoint("TOP", player, "BOTTOM", 0, 2)


--------------------------
--      Phase icon      --
--------------------------

local parent, ns = ...
local oUF = ns.oUF

local function Update(self, event, arg1)
	local Phase = self.Phase
	local unit = self.unit

	if event == 'UNIT_OTHER_PARTY_CHANGED' and arg1 ~= unit then return end

	local inOtherGroup, canInteract = UnitInOtherParty(unit)
	if not canInteract then
		if Phase:IsObjectType("Texture") then
			Phase:SetTexture("Interface\\PlayerFrame\\whisper-only")
			Phase:SetTexCoord(0.1875, 0.8125, 0.1875, 0.8125)
		end
		Phase.tooltip = PARTY_IN_PUBLIC_GROUP_MESSAGE
		Phase:Show()
	elseif not UnitInPhase(unit) and UnitExists(unit) then
		if Phase:IsObjectType("Texture") then
			Phase:SetTexture("Interface\\TargetingFrame\\UI-PhasingIcon")
			Phase:SetTexCoord(0.15625, 0.84375, 0.15625, 0.84375)
		end
		Phase.tooltip = PARTY_PHASED_MESSAGE
		Phase:Show()
	else
		Phase:Hide()
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate')
end

local function Enable(self)
	local Phase = self.Phase
	if Phase then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)
		self:RegisterEvent("GROUP_ROSTER_UPDATE", Update, true)
		self:RegisterEvent("UNIT_PHASE", Update, true)
		self:RegisterEvent("PARTY_MEMBER_ENABLE", Update, true)
		self:RegisterEvent("PARTY_MEMBER_DISABLE", Update, true)
		self:RegisterEvent("UNIT_OTHER_PARTY_CHANGED", Update, true)

		Phase.__owner = self

		return true
	end
end

local function Disable(self)
	local Phase = self.Phase
	if Phase then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:UnregisterEvent("GROUP_ROSTER_UPDATE", Update)
		self:UnregisterEvent("UNIT_PHASE", Update)
		self:UnregisterEvent("PARTY_MEMBER_ENABLE", Update)
		self:UnregisterEvent("PARTY_MEMBER_DISABLE", Update)
		self:UnregisterEvent("UNIT_OTHER_PARTY_CHANGED", Update)
	end
end

oUF:AddElement('Phase', Update, Enable, Disable)
