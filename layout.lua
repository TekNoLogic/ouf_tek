
local myname, ns = ...
local oUF = ns.oUF


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


local ptanks = oUF:Spawn("header", "oUF_Tanks")
ptanks:SetPoint("BOTTOM", tanks, "TOP", 0, 0)
ptanks:SetManyAttributes(
	"showRaid", true,
	"yOffset", 0, -- -smallheight,
	"xOffset", -40,
	"nameList", ""
)
ptanks:Show()


local mytanks = {}
SLASH_OUF_TEK_TANK1 = "/ptank"
SlashCmdList.OUF_TEK_TANK = function(msg)
	if InCombatLockdown() then return print("Cannot set personal tanks in combat!") end

	local name = msg ~= "" and msg or UnitName("target")
	local found
	for i,n in pairs(mytanks) do
		if n == name then
			found = true
			table.remove(mytanks, i)
		end
	end
	if not found then table.insert(mytanks, name) end

	ptanks:SetAttribute("nameList", table.concat(mytanks, ","))
end


oUF:SetActiveStyle("Classic - PartyPet")

local lastpet
for i=1,4 do
	local pet = oUF:Spawn("partypet"..i)
	pet:SetPoint("TOPRIGHT", lastpet or party, lastpet and "BOTTOMRIGHT" or "TOPLEFT")
	lastpet = pet
end


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

