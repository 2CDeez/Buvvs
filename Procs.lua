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

local MAJOR = "proc"

local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L      = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")
local AceGUI = LibStub( "AceGUI-3.0")

local NOTHING = {}
local UPDATE_TIME = 0.2
local MAX_BUTTON  = 16
local PROCTABLES = { -- TODO: Remove duplicate spell entries (outdated IDs) -> Don't have time to test them all right now :|
	["DEATHKNIGHT"] = {

	-- SHARED:
		[53365] = true, -- Unholy Strength
	[178819] = true, 	-- Dark Succor
	[101568] = true,	-- Dark Succor
	[222863] = true,	-- Dark Succor
	
	-- BLOOD:
	[81141] = true, -- Crimson Scourge
	
	-- FROST:
	[51124] = true, -- Killing Machine
	[59052] = true, -- Rime	
	
	-- UNHOLY:
	
	},
	["DRUID"] = {

	-- SHARED:
	-- Omen of Clarity
	[16864] = true,
	[113043] = true,
	
	-- Moment of Clarity
	[155577] = true,
	[236068] = true,
	
	-- BALANCE:
	
	-- FERAL:
	
	-- GUARDIAN:
	-- Gory Fur
	[200854] = true,
	[201671] = true,
	
	-- Galactic Guardian
	[203964] = true,
	[213708] = true,
	
	-- Gore
	[210706] = true,
	[93622] = true,
	
	-- Restoration
	[16870] = true, -- Clearcasting
	[135700] = true,
	
	},
	["HUNTER"] = {
		
		-- SHARED:
		
		-- BEAST MASTERY:
		
		-- MARKSMANSHIP:
		-- Marking Target
		
		-- SURVIVAL:
		
	},
	["MAGE"] = {
		
		-- SHARED:
		
		-- ARCANE:
		
		-- FIRE:
		-- Heating Up
		[48107] = true,
		
		-- Hot Streak
		[195283] = true,
		[48108] = true,
		
		-- Enhanced Pyrotechnics (artifact trait)
		[157642] = true,
		[157644] = true,
		
		-- Warmth of the Phoenix
		[240671] = true,
		[238091] = true,
		
		-- Pyretic Incantation (artifact trait)
		[194331] = true,
		[194329] = true,
		
		-- FROST:
		-- Brain Freeze
		[190447] = true,
		[231584] = true,
		[190446] = true,
		
		-- Fingers of Frost
		[112965] = true,
		[44544] = true,
		
	},
	["PALADIN"] = {
	
		-- SHARED:

		-- HOLY:
			[54149] = true, -- Infusion of Light
			[216411] = true, -- Divine Purpose (Holy Shock)
			[216413] = true, -- Divine Purpose (Light of Dawn)
		
		-- Protection:
		-- [85043] = true, -- Grand Crusader
		-- [85416] = true,
		
		-- Retribution:
			[209785] = true, -- The Fires of Justice
			[238996] = true, -- Righteous Verdict
			[223819] = true, -- Divine Purpose
		
	},
	["PRIEST"] = {
		
		-- ALL:
		[109142] = true, -- Twist of Fate
		
		-- DISCIPLINE:
		
		-- HOLY:
			[114255] = true, -- Surge of Light
			[196644] = true, -- Blessing of T'uure
			[197030] = true, -- Divinity
			--[196490] = true, -- Power of the Naaru (virtually active)
		
		-- SHADOW:
			[124430] = true, -- Shadowy Insight
		-- Mind Quickening (virtually active)
		
	},
	["ROGUE"] = {
	
	-- SHARED:
	
	-- ASSASSINATION:
	
	-- OUTLAW
		[195627] = true, -- Opportunity
	
	-- SUBTLETLY
	
	},
	["SHAMAN"] = {
	
	-- SHARED:
		[77762] = true, -- Lava Surge
		
	-- RESTORATION:
		-- Riptide (active)
		--[53390] = true, -- Tidal Waves (virtually active)
		-- Ancestral Vigor (virtually active)
		-- Ascendance (active)
		--[108271] = true, -- Astral Shift (active)
		-- Bloodlust / Heroism (active) -> Sense of Urgency (artifact trait)		
		[207288] = true, -- Queen Ascendant
		-- Gift of the Queen (active)
		--[79206] = true, -- Spiritwalker's Grace (active)
		-- Caress of the Tidemother (active?)
	
	-- ELEMENTAL:
		[16246] = true, -- Elemental Focus
	
	-- ENHANCEMENT:
	[201846] = true, -- Stormbringer
	-- Gathering Storms (virtually active)
	[195222] = true, -- Stormlash
	[215785] = true, -- Hot Hand	
	
	},
	["WARLOCK"] = {
	
	-- SHARED:
	
	-- AFFLICTION:
		[199281] = true, -- Compounding Horror (artifact trait)
		
	-- DEMONOLOGY:
	
	-- DESTRUCTION:
	
	},
	["WARRIOR"] = {
	
	-- SHARED:

	-- ARMS:
	[199854] = true,
	[184783] = true, -- Tactician
	[167105] = true,
	[208086] = true,
	[108126] = true,
	[164491] = true,
	[169587] = true,
	[191100] = true,
	[198804] = true, -- Colossus Smash
	
	-- FURY:
		[184362] = true, -- Enrage (virtually active?)
	-- Meat Cleaver (active)
		[215570] = true, -- Wrecking Ball
		[200986] = true, -- Odyn's Champion (artifact trait)
	[206316] = true, -- Massacre -> needs testing
	-- Frothing Berserker (virtually active)
	
	-- PROTECTION:
		[5302] = true, -- Revenge!
		[203581] = true, -- Dragon Scales (artifact trait)
		[189064] = true, -- Scales of Earth (artifact trait)

	},
	["MONK"] = {
	
	-- SHARED:
	
	-- BREWMASTER
		[195630] = true, -- Elusive Brawler
	
	-- MISTWEAVER:
	
	-- WINDWALKER:
		-- Transfer the Power (active)
		[116768] = true, -- Blackout Kick!
		[196741] = true, -- Hit Combo
	
	},
	["DEMONHUNTER"] = {
		-- SHARED:
	[208195] = true, -- Demon Soul (from Shattered Souls passive) -- TODO: Needs testing
		[203981] = true, -- Soul Fragments (from Shattered Souls passive)
	
	-- HAVOC:
		-- Blade Dance (not really a proc)
		-- Chaos Blades (active)
		-- Death Sweep (Blade Dance during Metamorphosis - not really a proc)
		-- Blur (not really a proc)
		-- Fel Barrage (not really a proc)
		-- Metamorphosis (active/Demonic talent uses the same ID)
		-- Netherwalk (active)
		-- Momentum (active)
		-- Nemesis (target?)
	
	-- VENGEANCE:
		[187827] = true, -- Metamorphosis (Artifact trait, even though the active spell is also using the same ID)
		[247253] = true, -- Blade Turning
		[212988] = true, -- Painbringer (Artifact trait)
		--[207693] = true, -- Feast of Souls (active)
		--[178740] = true, -- Immolation Aura (not really a proc)
		--[227225] = true, -- Soul Barrier (not really a proc)
		[218561] = true, -- Siphoned Power (from using Empower Wards)
		
	}
}

local Module = Addon:NewBarModule( MAJOR)
Module.filter  = "HELPFUL"
Module.color   = { r=0.2, g=0.4, b=0.2 }
Module.proName = "proc"

local procTable = NOTHING
local args = {
	option = { 
		type = "group", order = 10, name = L["General Settings"], inline = true, 
		args = {
			show     = { type = "toggle", order = 10, name = L["Enable Bar"],     desc = L["Toggle this bar and all of its icons"], width = "full" },
			sort     = { type = "select", order = 20, name = L["Sort by"],     desc = L["Set how the icons should be sorted"], get = "GetSortType", set = "SetSortType", values = "GetSortDesc" },
			timer    = { type = "select", order = 30, name = L["Timer Style"],    desc =L["Change the timer format for this bar"], values = "GetTimerDesc" },
			flashing = { type = "toggle", order = 40, name = L["Enable Flashing"], desc = L["Flash button as the buff duration approaches zero"] },
			spell    = { type = "toggle", order = 50, name = L["Show Spell ID"],    desc = L["Show each icon's spell ID in its tooltip"] },
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
			rows      = { type = "range",  order = 70, name = L["Rows"],       desc = L["Number of rows"],     set = "SetRows",     min = 1,    max = MAX_BUTTON, step = 1 },
			yPadding   = { type = "range",  order = 80, name = L["Vertical Padding"],   desc = L["Adds additional space between icons. Use negative values to reverse the direction of the bar"], set = "SetYPadding", min = -50,  max = 50,         step = 1 },
		} 
	}
}
local blizzOptions = {
	type = "group", order = 50, name = L["Procs Bar Settings"], handler = Module, get = "GetProperty", set = "SetProperty", args = args
}
local dialogOptions = {
	type = "group", order = 20, name = L["Procs Bar"], handler = Module, get = "GetProperty", set = "SetProperty", args = args,
	plugins = {
		p1 = { 
			descr = { type = "description", order = 5, name = L["Procs Bar Settings"], fontSize = "large" }
		}
	}
}

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
function Module:OnModuleInitialize()
	self:RegisterOptions( blizzOptions, L["Procs Bar"])
	self:CloneAura( "buff")
	local _, class = UnitClass( "player")
	procTable = PROCTABLES[class] or NOTHING
end

function Module:GetOptionTable()
	return dialogOptions
end

function Module:UpdateAnchors( sort)
	Addon:Debug( self, ":UpdateAnchors")
	if self.profile.show then
		if sort then
			self:SortAura()
		end
		local spell = self.profile.spell
		for i,a in pairs( self.aura) do
			local buff = self:GetUserBuff( "BuffProcButton", a.id)
			self:UpdateMasque(buff, "Procs")
			local child = self.group.children[i]
			if child and procTable[a.spellID] then
				self:UpdateUserBuff( buff, a)
				child:SetBuff( buff)
				child:SetSpell( spell and a.spellID)
			elseif child then
				self:HideUserBuff( buff)
				child:SetBuff( nil)
				child:SetSpell( nil)
			else
				self:HideUserBuff( buff)
			end
		end
	end
end

function Module:UpdateBuffAnchors()
	self:UpdateAnchors( true)
end

--function Module:UpdateEnchantAnchors()
--	self:UpdateAnchors()
--end

function Module:MoveTo( offset)
	for i,child in pairs( self.group.children) do
		child:SetBuff( nil)
	end
	for id = 1,#self.aura do
		local buff = self:GetUserBuff( "BuffProcButton", id)
		buff:Hide()
		buff.duration:Hide()
		buff:SetScript( "OnUpdate", nil)
--		buff.timeLeft = nil
	end
end

function Module:AdditionalSort( orig)
	return function( a, b) 
		local procA = a.spellID and procTable[a.spellID] or false
		local procB = b.spellID and procTable[b.spellID] or false
		if procA == procB then
			return orig( a, b)
		end
		return procA
	end
end
