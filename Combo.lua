  ----------------------------------------------------------------------------------------------------------------------
    -- This program is free software: you can redistribute it and/or modify
    -- it under the terms of the GNU General Public License as published by
    -- the Free Software Foundation, either version 3 of the License, or
    -- (at your option) any later version.
	
    -- This program is distributed in the hope that it will be useful,
    -- but WITHOUT ANY WARRANTY; without even the implied warranty of
    -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    -- GNU General Public License for more details.

    -- You should have received a copy of the GNU General Public License
    -- along with this program.  If not, see <http://www.gnu.org/licenses/>.
----------------------------------------------------------------------------------------------------------------------


local MAJOR = "combo"

local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L      = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")
local AceGUI = LibStub( "AceGUI-3.0")

local NOTHING = {}
local UPDATE_TIME = 0.2
local MAX_BUTTON  = 10

local Module = Addon:NewBarModule( MAJOR)
Module.filter  = "HELPFUL"
Module.color   = { r=0.2, g=0.4, b=0.9 }
Module.proName = "combo"

local args = {
	option = { 
		type = "group", order = 10, name = L["General Settings"], inline = true, 
		args = {
			show     = { type = "toggle", order = 10, name = L["Enable Bar"],     desc = L["Toggle this bar and all of its icons"], width = "full" },
--			sort     = { type = "select", order = 20, name = L["Sort by"],     desc = L["Set how the icons should be sorted"], get = "GetSortType", set = "SetSortType", values = "GetSortDesc" },
			timer    = { type = "select", order = 30, name = L["Timer Style"],    desc =L["Change the timer format for this bar"], values = "GetTimerDesc" },
			flashing = { type = "toggle", order = 40, name = L["Enable Flashing"], desc = L["Flash button as the buff duration approaches zero"] },
--			spell    = { type = "toggle", order = 50, name = L["Show Spell ID"],    desc = L["Show each icon's spell ID in its tooltip"] },
		} 
	},
	layout = { 
		type = "group", order = 20, name = L["Appearance and Behaviour"], inline = true, 
		args = {
			horizontal = { type = "toggle", order = 10, name = L["Horizontal Alignment"], desc = L["Align buff icons horizontally before moving to a new row"], width = "full" },
			number     = { type = "range",  order = 30, name = L["Size"],     desc = L["Number of buttons to display on this bar"],   set = "SetNumber",   min = 1,    max = MAX_BUTTON, step = 1 },
			scale      = { type = "range",  order = 40, name = L["Scale Factor"],      desc = L["Scale all buff icons by this factor"],    set = "SetScale",    min = 0.01, max = 2,          step = 0.01, isPercent = true },
			cols       = { type = "range",  order = 50, name = L["Columns"],       desc = L["Number of colums"],     set = "SetCols",     min = 1,    max = MAX_BUTTON, step = 1 },
			xPadding   = { type = "range",  order = 60, name = L["Horizontal Padding"],   desc = L["Adds additional space between icons. Use negative values to reverse the direction of the bar"], set = "SetXPadding", min = -20,  max = 20,         step = 1 },
			rows       = { type = "range",  order = 70, name = L["Rows"],       desc = L["Number of rows"],     set = "SetRows",     min = 1,    max = MAX_BUTTON, step = 1 },
			yPadding   = { type = "range",  order = 80, name = L["Vertical Padding"],   desc = L["Adds additional space between icons. Use negative values to reverse the direction of the bar"], set = "SetYPadding", min = -50,  max = 50,         step = 1 },
			bigger     = { type = "range",  order = 90, name = L["Maximum stack size indicator"],     desc = L["When the maximum number of combo points (or spell charges/procs) has been reached, increase the size of the last icon by this amount"],   set = "SetBigger",   min = 1,    max = 2,          step = 0.01, isPercent = true },
		} 
	}
}
local blizzOptions = {
	type = "group", order = 50, name = L["Procs Bar Settings"], handler = Module, get = "GetProperty", set = "SetProperty", args = args
}
local dialogOptions = {
	type = "group", order = 20, name = L["Combo Bar"], handler = Module, get = "GetProperty", set = "SetProperty", args = args,
	plugins = {
		p1 = { 
			descr = { type = "description", order = 5, name = L["Procs Bar Settings"], fontSize = "large" }
		}
	}
}
local comboIcon
local comboSpell
local comboFkt
local comboCount = 5

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
function Module:OnModuleInitialize()
	self:RegisterOptions( blizzOptions, L["Combo Bar"])
	for i = 1, MAX_BUTTON do -- Create table entries for all ComboBar buttons (even those not currently used or displayed -> templates to be filled later)
		tinsert( self.aura, { id = i, name = "__combo__", count = 1 })
	end
end

function Module:OnModuleEnable()
	self:ACTIVE_TALENT_GROUP_CHANGED()
	self:RegisterEvent( "ACTIVE_TALENT_GROUP_CHANGED")
	self:RegisterEvent( "UPDATE_SHAPESHIFT_FORM")
end

function Module:GetOptionTable()
	return dialogOptions
end

function Module:UpdateAnchors( sort)
--	Addon:Debug( self, ":UpdateAnchors", self.profile.show)
	if self.profile.show and #comboIcon > 0 and PlayerFrame.unit == "player" then
		local maxStacks = comboFkt and type(comboFkt) == "function" and comboFkt() or 0
--		Addon:Debug( self, ":UpdateAnchors", maxStacks)
		for i,a in pairs( self.aura) do
			
			--Addon:Debug(self, "Updating auras for i = " .. i .. ", value (a) = " .. tostring(a))

			local buff = self:GetUserBuff( "BuffComboButton", a.id)
			local child = self.group.children[i]
			
			if child then -- Tag as last icon that may be scaled in size
				child:SetUserData( "bigger", i == comboCount)
			end
			
			if child and i <= maxStacks then -- Display one icon per power
				buff:SetScript( "OnEnter", nil)
				a.texture = comboIcon
				self:UpdateMasque(buff, "Combos")
				buff:Show()
				local icon = _G[buff:GetName().."Icon"]
				if icon then
					icon:SetTexture( a.texture)
				end
--				if GameTooltip:IsOwned( buff) and comboSpell then
--					GameTooltip:SetSpell( comboSpell, "spell")
--				end
				child:SetBuff( buff)
			elseif child then
				a.texture = nil
				buff:Hide()
				child:SetBuff( nil)
			else
				a.texture = nil
				buff:Hide()
			end
		end
	end
end

function Module:UpdateEnchantAnchors()
	self:UpdateAnchors()
end

function Module:MoveTo( offset)
	for i,child in pairs( self.group.children) do
		child:SetBuff( nil)
	end
	for id = 1,#self.aura do
		local buff = self:GetUserBuff( "BuffComboButton", id)
		buff:Hide()
		buff.duration:Hide()
		buff:SetScript( "OnUpdate", nil)
	end
end

------------------------------------------------------------------------------------
-- Local
------------------------------------------------------------------------------------
local function ScanAura( unit, id, filter)
	local name = GetSpellInfo( id)
	local _, _, _, count = UnitAura( unit, name, nil, filter)
	return count or 0
end


-- local function PointsWarlock()
	-- return UnitPower( "player", SPELL_POWER_SOUL_SHARDS)
-- end

------------------------------------------------------------------------------------
-- Event
------------------------------------------------------------------------------------

-- Returns the number of active Runes (Death Knight)
local function GetActiveRunes()
				
	local maxRunes = UnitPower( "player", SPELL_POWER_RUNES)
	local activeRunes = 0
	
	for i=1, maxRunes do -- Check rune status
		
		if GetRuneCount(i)> 0 then
			activeRunes = activeRunes + 1
		end
		
	end	
	
	return activeRunes

end

	-- LUT for the class powers / GetClassPowers (stored here to avoid excess garbage creation)
	local classPowers = {
		{  -- 1		Warrior		WARRIOR
			{	-- 1	Arms > Nothing
			["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			},
		
			{	-- 2	Fury > Taste for Blood (from Furious Slash)
				["GetCurrentStacks"] = function()
					return ScanAura("player", 206333, "HELPFUL")
				end,
				["maxStacks"] = 6,
				["spell"] = 206333, -- 100130 = Furious Slash
				["icon"] = "ability_warrior_bloodnova", --"ability_warrior_weaponmastery", 
			},
		
			{	-- 3	Protection > Nothing
				["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			}
		},
		
		{  -- 2		Paladin		PALADIN
			{	-- 1	Holy > Nothing
				["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			},
		
			{	-- 2	Protection > Nothing
				["GetCurrentStacks"] = function()
					return 
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "", 
			},
		
			{	-- 3	Retribution > Holy Power
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_HOLY_POWER)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "Spell_Holy_HolyBolt",
			}
		
		},		

		{  -- 3 		Hunter 	HUNTER
			{	-- 1	Beast Mastery > Nothing
			["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			},
		
			{	-- 2	Marksmanship > Nothing
				["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "", 
			},
		
			{	-- 3	Survival > Mongoose Fury
				["GetCurrentStacks"] = function()
					return ScanAura("player", 190931, "HELPFUL")
				end,
				["maxStacks"] = 6,
				["spell"] = 190931,
				["icon"] = "ability_hunter_mongoosebite",
			}
		},

		{  -- 4		Rogue		ROGUE
			{	-- 1	Assassination > Combo Points
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_COMBO_POINTS)
				end,
				["maxStacks"] = 10,
				["spell"] = 0,
				["icon"] = "Ability_DualWield",
			},
		
			{	-- 2	Outlaw > Combo Points
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_COMBO_POINTS)
				end,
				["maxStacks"] = 10,
				["spell"] = 0,
				["icon"] = "Ability_DualWield", 
			},
		
			{	-- 3	Subtletly > Combo Points
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_COMBO_POINTS)
				end,
				["maxStacks"] = 10,
				["spell"] = 0,
				["icon"] = "Ability_DualWield",
			}
		
		},		
	
		{  -- 5 		Priest 	PRIEST
			{	-- 1	Discipline > Nothing
			["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			},
		
			{	-- 2	Holy > Nothing
				["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "", 
			},
		
			{	-- 3	Shadow > Nothing
				["GetCurrentStacks"] = function()
					return 0
					--return ScanAura("player", 227386, "HELPFUL") -- TODO: Lingering Insanity
				end,
				["maxStacks"] = 0, -- 100, -- TODO
				["spell"] = 0, -- 227386, = Voidform
				["icon"] = "", -- "spell_priest_voidform",
			}
		},

		{  -- 6		Death Knight		DEATHKNIGHT
			{	-- 1	Blood > Runes
				["GetCurrentStacks"] = GetActiveRunes,
				["maxStacks"] = 6,
				["spell"] = 0,
				["icon"] = "spell_shadow_rune",
			},
		
			{	-- 2	Frost > Runes
				["GetCurrentStacks"] = GetActiveRunes,
				["maxStacks"] = 6,
				["spell"] = 0,
				["icon"] = "spell_shadow_rune", 
			},
		
			{	-- 3	Unholy > Runes
				["GetCurrentStacks"] = GetActiveRunes,
				["maxStacks"] = 6,
				["spell"] = 0,
				["icon"] = "spell_shadow_rune",
			}
		
		},		
	
		{  -- 7 		Shaman 	SHAMAN
			{	-- 1	Elemental > Lava Burst (charges if talented into)
			["GetCurrentStacks"] = function()
					
					return GetSpellCharges(51505)
	
				end,
				["maxStacks"] = function()
					
					
					local id, name, texture, selected, available, spellID, tier, column, unknown = GetTalentInfo(6, 3, GetActiveSpecGroup()) -- Talent: Echo of the Elements -> 2 charges
					
					if select(4, GetTalentInfo(6, 3, GetActiveSpecGroup())) then -- Player has 2 charges available instead of just one
						return 2
					end
					
					return 1
				
				end,
				["spell"] = 51505, -- 77762 = Lava Surge (proc)
				["icon"] = "spell_shaman_lavaburst", --"spell_shaman_lavasurge",
			},
		
			{	-- 2	Enhancement > Stormbringer
				["GetCurrentStacks"] = function()
					return ScanAura("player", 201845, "HELPFUL")
				end,
				["maxStacks"] = function()
				
					-- GetSpecializationInfo(specID) 1,2,3,4 -> 62,63, ...  and then  id, name, icon, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(rows, columns, GetActiveSpecGroup())
					
					if GetTalentInfo(5, 1, GetActiveSpecGroup()) then -- Talent: Tempest -> 2 charges per Stormbringer proc
						return 2
					end
					
					return 1
				
				end,
				["spell"] = 201845, -- 17364
				["icon"] = "spell_nature_stormreach",  --  ability_shaman_stormstrike -> Stormstrike
			},
		
			{	-- 3	Restoration > Tidal Waves
				["GetCurrentStacks"] = function()
					return ScanAura("player", 53390, "HELPFUL")
				end,
				["maxStacks"] = 2,
				["spell"] = 53390,
				["icon"] = "spell_shaman_tidalwaves",
			}
		},

		{  -- 8		Mage		MAGE
			{	-- 1	Arcane > Arcane Charges
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_ARCANE_CHARGES)
				end,
				["maxStacks"] = 4,
				["spell"] = 0,
				["icon"] = "ability_mage_arcanebarrage",
			},
		
			{	-- 2	Fire > Nothing
				["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			},
			
			{	-- 3	Frost > Icicles
				["GetCurrentStacks"] = function()
					return ScanAura("player", 205473 , "HELPFUL") -- 112965 = Fingers of Frost
				end,
				["maxStacks"] = 5,
				["spell"] = 205473, -- 44544 = Fingers of Frost
				["icon"] = "spell_frost_iceshard", --"ability_mage_wintersgrasp", 
			},
		

		
		},			
		
		{  -- 9		Warlock		WARLOCK
			{	-- 1	Affliction > Soul Shards
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_SOUL_SHARDS)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "INV_Misc_Gem_Amethyst_02",
			},
		
			{	-- 2	Demonology > Soul Shards
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_SOUL_SHARDS)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "INV_Misc_Gem_Amethyst_02", 
			},
		
			{	-- 3	Destruction > Soul Shards
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_SOUL_SHARDS)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "INV_Misc_Gem_Amethyst_02",
			}
		
		},		
		
		{  -- 10		Monk		MONK
			{	-- 1	Brewmaster > Chi
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_CHI)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "ability_monk_chiwave",
			},
		
			{	-- 2	Mistweaver > Chi
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_CHI)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "ability_monk_chiwave", 
			},
		
			{	-- 3	Windwalker > Chi
				["GetCurrentStacks"] = function()
					return UnitPower( "player", SPELL_POWER_CHI)
				end,
				["maxStacks"] = 5,
				["spell"] = 0,
				["icon"] = "ability_monk_chiwave",
			}
		
		},		
			
		{  -- 11 		Druid 	DRUID
			{	-- 1	Balance > Thrash (Bear) or Combo Points (Cat)
			["GetCurrentStacks"] = function()
					
					if GetShapeshiftFormID() == CAT_FORM then
						return UnitPower("player",  SPELL_POWER_COMBO_POINTS)
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return ScanAura("target", 106830, "HARMFUL")
					end
					
					return 0
					
				end,
				["maxStacks"] = 5,
				["spell"] = function()
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return 106830
					end
					
					return 0
					
				end, 
				["icon"] = function()
				
					if GetShapeshiftFormID() == CAT_FORM then
						return "Ability_DualWield"
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return "spell_druid_thrash"
					end
					
					return ""
					
				end, 
			},
		
			{	-- 2	Feral > Thrash (Bear) or Combo Points (Cat)
				["GetCurrentStacks"] = function()
					
					if GetShapeshiftFormID() == CAT_FORM then
						return UnitPower("player",  SPELL_POWER_COMBO_POINTS)
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return ScanAura("target", 106830, "HARMFUL")
					end
					
					return 0
					
				end,
				["maxStacks"] = 5,
				["spell"] = function()
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return 106830
					end
					
					return 0
					
				end, 
				["icon"] = function()
				
					if GetShapeshiftFormID() == CAT_FORM then
						return "Ability_DualWield"
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return "spell_druid_thrash"
					end
					
					return ""
					
				end, 
			},
		
			{	-- 3	Guardian > Thrash (Bear) or Combo Points (Cat)
				["GetCurrentStacks"] = function()
					
					if GetShapeshiftFormID() == CAT_FORM then
						return UnitPower("player",  SPELL_POWER_COMBO_POINTS)
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return ScanAura("target", 106830, "HARMFUL")
					end
					
					return 0
					
				end,
				["maxStacks"] = 5,
				["spell"] = function()
				
					if GetShapeshiftFormID() == BEAR_FORM then
						return 106830
					end
					
					return 0
					
				end, 
				["icon"] = function()
				
					if GetShapeshiftFormID() == CAT_FORM then
						return "Ability_DualWield"
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return "spell_druid_thrash"
					end
					
					return ""
					
				end, 
			},
			
			{	-- 4	Restoration > Thrash (Bear) or Combo Points (Cat)
				["GetCurrentStacks"] = function()
					
					if GetShapeshiftFormID() == CAT_FORM then
						return UnitPower("player",  SPELL_POWER_COMBO_POINTS)
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return ScanAura("target", 106830, "HARMFUL")
					end
					
					return 0
					
				end,
				["maxStacks"] = 5,
				["spell"] = function()
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return 106830
					end
					
					return 0
					
				end, 
				["icon"] = function()
				
					if GetShapeshiftFormID() == CAT_FORM then
						return "Ability_DualWield"
					end
					
					if GetShapeshiftFormID() == BEAR_FORM then
						return "spell_druid_thrash"
					end
					
					return ""
					
				end, 
			}
			
		},

		{	-- 12		Demon Hunter		DEMONHUNTER
			{	-- 1	Havoc > Nothing
			["GetCurrentStacks"] = function()
					return 0
				end,
				["maxStacks"] = 0,
				["spell"] = 0,
				["icon"] = "",
			},
		
			{	-- 2	Vengeance > Demon Spikes
				["GetCurrentStacks"] = function()
					
					local pain = UnitPower("player", SPELL_POWER_PAIN)
					
					if pain >= 20 then -- is able to cast Demon Spikes (TODO: Could its cost be modified? Can't find an API to draw upon that info and I'm not doing tooltip scanning just for that...)
						return GetSpellCharges(203720) -- These are the charges of the spell, not the buff (as it doesn't stack)
					end
					
					return 0
					
				end,
				["maxStacks"] = 2,
				["spell"] = 203819, -- This is the buff applied to the player (different ID)
				["icon"] = "ability_demonhunter_demonspikes", 
			},
		
		},
	
	}


-- Returns the updateFunction, maxStacks, spellID, icon for each class/spec
local function GetClassPowers(classID, specID)

	if not (classID or specID or classPowers[classID] or classPowers[classID][specID]) then return end -- Invalid parameters -> skip and let the caller deal with the nil value/error out
	
	return classPowers[classID][specID]

end

-- Update comboBar icons (Called on each buff:update event)
function Module:ACTIVE_TALENT_GROUP_CHANGED()

	local localizedClassName, class, classID = UnitClass( "player")
	--local spec = GetSpecialization()
	local specID, specName = GetSpecializationInfo(spec)

	if not (specID and classID) then return end
	--Addon:Debug(self, format("ACTIVE_TALENT_GROUP_CHANGED (Current spec: %s - %s for class %s / %s)", specID, specName, class, localizedClassName))

	-- Get info to display with the icon for this class/spec
	local powers = GetClassPowers(classID, spec)
	if not powers then -- Not a valid class/spec combination -> Skip update
		Addon:Debug(self, "Invalid parameters given when calling GetClassPowers")
		return
	end

	-- Retrieve class and spec-specific stack sizes/spells to track 

	-- This is always a function
	local GetCurrentStacks = powers["GetCurrentStacks"]

	-- These could be calculated dynamically or just a static value
	local maxStacks = (type(powers["maxStacks"]) == "function" and powers.maxStacks()) or powers["maxStacks"]
	local spellID = (type(powers["spell"] ) == "function" and powers.spell()) or powers["spell"]
	local icon = (type(powers["icon"]) == "function" and powers.icon()) or powers["icon"]

	Addon:Debug(self, format("Updated with stacks = %d, maxStacks = %d, spell = %d (%s), icon = %s", GetCurrentStacks(), maxStacks, spellID, GetSpellInfo(spellID) or "<NONE>", icon))

	-- TODO: Rework this to be more universal/reusable? It*s kind of awkward in its original design
	comboCount = maxStacks
	comboIcon = ((#icon > 0) and ("Interface\\Icons\\" .. icon)) or "" -- Only assemble path if the icon isn't <empty string> (default for "don't display an icon")
	comboSpell = spellID -- will be displayed on icon:mouseover -> set to 0 for resources that haven't a tooltip text (Combo Points, Holy Power, ...)
	comboFkt = function() -- This is the function that will be called every time the icon is supposed to update

		if GetCurrentStacks and type(GetCurrentStacks) == "function" then
			return GetCurrentStacks() or 0 -- Returns the current stacks for the respective class/spec
		end

		return 0

	end

end

-- If shapeshift forms change, so do the ComboBar icons/spells that need to be displaye
function Module:UPDATE_SHAPESHIFT_FORM()
	self:ACTIVE_TALENT_GROUP_CHANGED()
end
