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

local MAJOR = "buff"

local Addon = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L     = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")

local MAX_BUTTON = 40 -- BUFF_ACTUAL_DISPLAY = 32

local Module = Addon:NewBarModule( MAJOR)
Module.filter  = "HELPFUL"
Module.color   = { r=0.2, g=0.8, b=0.2 }
Module.proName = "buff"

local args = {
	option = { 
		type = "group", order = 10, name = L["General Settings"], inline = true, 
		args = {
			show     = { type = "toggle", order = 10, name = L["Enable Bar"],     desc = L["Toggle this bar and all of its icons"], width = "full" },
			sort     = { type = "select", order = 20, name = L["Sort by"],     desc = L["Set how the icons should be sorted"], get = "GetSortType", set = "SetSortType", values = "GetSortDesc" },
			timer    = { type = "select", order = 30, name = L["Timer Style"],    desc = L["Change the timer format for this bar"], values = "GetTimerDesc" },
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
			rows       = { type = "range",  order = 70, name = L["Rows"],       desc = L["Number of rows"],     set = "SetRows",     min = 1,    max = MAX_BUTTON, step = 1 },
			yPadding   = { type = "range",  order = 80, name = L["Vertical Padding"],   desc = L["Adds additional space between icons. Use negative values to reverse the direction of the bar"], set = "SetYPadding", min = -50,  max = 50,         step = 1 },
		} 
	}
}
local blizzOptions = {
	type = "group", order = 20, name = L["Buff Bar Settings"], handler = Module, get = "GetProperty", set = "SetProperty", args = args
}
local dialogOptions = {
	type = "group", order = 20, name = L["Buff Bar"], handler = Module, get = "GetProperty", set = "SetProperty", args = args,
	plugins = {
		p1 = { 
			descr = { type = "description", order = 5, name = L["Buff Bar Settings"], fontSize = "large" }
		}
	}
}

------------------------------------------------------------------------------------
-- Locale
------------------------------------------------------------------------------------
local function GetBuff( bar, id)
	if id < 1 then
		return ConsolidatedBuffs
	end
	if id <= BUFF_MAX_DISPLAY then
		return _G["BuffButton"..id]
	end
	return bar:GetUserBuff( "BuffUserButton", id)
end

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
function Module:OnModuleInitialize()
	self:RegisterOptions( blizzOptions, L["Buff Bar"])
	self:CloneAura( "buff")
end

function Module:GetOptionTable()
	return dialogOptions
end

function Module:UpdateAnchors( sort)
	Addon:Debug( self, ":UpdateAnchors")
	if self.profile.show then
		self:SortAura()
		-- MOD
		-- local cons = ConsolidatedBuffs:IsVisible() / MOD
		local spell = self.profile.spell
		for i,child in pairs( self.group.children) do
			local a = nil
			if not cons then
				a = self.aura[i]
			elseif i > 1 then
				a = self.aura[i - 1]
			end
			local buff = GetBuff( self, a and a.id or 0)
			self:UpdateMasque(buff, "Buffs")
			local hide = cons and a and a.consolidate
			if hide then
				buff = nil
			elseif a and a.id > BUFF_MAX_DISPLAY then
				if hide then
					self:HideUserBuff( buff)
				else
					self:UpdateUserBuff( buff, a)
				end
			end
			child:SetBuff( buff)
			child:SetSpell( spell and a and a.spellID)
		end
	end
end

function Module:UpdateBuffAnchors()
	self:UpdateAnchors()
end

function Module:MoveTo( offset)
	for i,child in pairs( self.group.children) do
		child:SetBuff( nil)
	end
	local count = 1
	local last, first
	--if ConsolidatedBuffs:IsVisible() then
	if false then
		ConsolidatedBuffs:ClearAllPoints()
		ConsolidatedBuffs:SetPoint( "TOPRIGHT", BuffFrame, "TOPRIGHT", 0, offset)
		count = 2
		last = ConsolidatedBuffs
		first = ConsolidatedBuffs
	end
	for id = 1,BUFF_ACTUAL_DISPLAY do
		local buff = GetBuff( self, id)
		if buff and not buff.consolidated then
			buff:ClearAllPoints()
			if last and first then
				buff:SetPoint( "TOPRIGHT", last, "TOPLEFT", -5, 0 )
			elseif first then
				buff:SetPoint( "TOPRIGHT", first, "BOTTOMRIGHT", 0, -BUFF_ROW_SPACING)
				first = buff
			else
				buff:SetPoint( "TOPRIGHT", BuffFrame, "TOPRIGHT", 0, offset)
				first = buff
			end
			last = buff;
			count = count + 1
			if count > BUFFS_PER_ROW then
				count = 1
				last = nil
			end
		end
	end
	for id = BUFF_MAX_DISPLAY+1,#self.aura do
		local buff = GetBuff( self, id)
		buff:Hide()
		buff.duration:Hide()
		buff:SetScript( "OnUpdate", nil)
		buff.timeLeft = nil
	end
end

-- MOD (Consolidated buff sorting)
function Module:AdditionalSort( orig)
	return function( a, b) 
		local cons = false
		local consA = cons and a.consolidate or false
		local consB = cons and b.consolidate or false
		if consA == consB then
			return orig( a, b)
		end
		return consB
	end
end

--[[
function Module:AdditionalSort( orig)
	return function( a, b) 
		local cons = ConsolidatedBuffs:IsVisible()
		local consA = cons and a.consolidate or false
		local consB = cons and b.consolidate or false
		if consA == consB then
			return orig( a, b)
		end
		return consB
	end
end
]]--
