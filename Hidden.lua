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

local MAJOR = "hidden"

local Addon    = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L        = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")
local AceGUI   = LibStub( "AceGUI-3.0")

local PANE_BACKDROP  = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
}
local MAX_BUTTON = 32

local Module = Addon:NewBarModule( MAJOR, "AceHook-3.0")
Module.filter  = "HELPFUL"
Module.color   = { r=0.4, g=0.4, b=0.2 }
Module.hideOnLock = true
Module.proName = "hidden"

local args = {
	option = { 
		type = "group", order = 10, name = L["General Settings"], inline = true, 
		args = {
			show     = { type = "toggle", order = 10, name = L["Enable Bar"],     desc = L["Toggle this bar and all of its icons"]},
			sort     = { type = "select", order = 40, name = L["Sort by"],     desc = L["Set how the icons should be sorted"], get = "GetSortType", set = "SetSortType", values = "GetSortDesc" },
		} 
	},
	layout = { 
		type = "group", order = 20, name = L["Appearance and Behaviour"], inline = true, 
		args = {
			horizontal = { type = "toggle", order = 10, name = L["Horizontal Alignment"], desc = L["Align buff icons horizontally before moving to a new row"]},
			number     = { type = "range",  order = 20, name = L["Size"],     desc = L["Number of buttons to display on this bar"],   set = "SetNumber",   min = 1,    max = MAX_BUTTON, step = 1 },
			scale      = { type = "range",  order = 40, name = L["Scale Factor"],      desc = L["Scale all buff icons by this factor"],    set = "SetScale",    min = 0.01, max = 2,          step = 0.01, isPercent = true },
			cols       = { type = "range",  order = 50, name = L["Columns"],       desc = L["Number of colums"],     set = "SetCols",     min = 1,    max = MAX_BUTTON, step = 1 },
			xPadding   = { type = "range",  order = 60, name = L["Horizontal Padding"],   desc = L["Adds additional space between icons. Use negative values to reverse the direction of the bar"], set = "SetXPadding", min = -20,  max = 20,         step = 1 },
			rows       = { type = "range",  order = 70, name = L["Rows"],       desc = L["Number of rows"],     set = "SetRows",     min = 1,    max = MAX_BUTTON, step = 1 },
			yPadding   = { type = "range",  order = 80, name = L["Vertical Padding"],   desc = L["Adds additional space between icons. Use negative values to reverse the direction of the bar"], set = "SetYPadding", min = -50,  max = 50,         step = 1 },
		} 
	}
}
local blizzOptions = {
	type = "group", order = 60, name = L["Consolidate Buffs"], handler = Module, get = "GetProperty", set = "SetProperty", args = args
}
local dialogOptions = {
	type = "group", order = 20, name = L["Hidden"], handler = Module, get = "GetProperty", set = "SetProperty", args = args,
	plugins = {
		p1 = { 
			descr = { type = "description", order = 5, name = L["Consolidate Buffs"], fontSize = "large" }
		}
	}
}

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
function Module:OnModuleInitialize()
	self:RegisterOptions( blizzOptions, L["Hidden"])
	self:CloneAura( "buff")
end

function Module:OnModuleEnable()
	self:SetVisible( false)
end

function Module:GetOptionTable()
	return dialogOptions
end

function Module:UpdateAnchors( sort)
	self:MoveTo()
end

function Module:UpdateBuffAnchors()
	self:MoveTo()
end

function Module:MoveTo()
--	Addon:Debug( self, ":MoveTo")
	if ConsolidatedBuffs:IsVisible() then
		self:SortAura()
		local count = 1
		local last, first
		for i,child in pairs( self.group.children) do
			local a = self.aura[i]
			local buff = _G["BuffButton"..a.id]
			if buff and a.consolidate then
				buff:ClearAllPoints()
				if last and first then
					buff:SetPoint( "TOPRIGHT", last, "TOPLEFT", -5, 0 )
				elseif first then
					buff:SetPoint( "TOPRIGHT", first, "BOTTOMRIGHT", 0, -BUFF_ROW_SPACING)
					first = buff
				else
					buff:SetPoint( "TOPRIGHT", ConsolidatedBuffsContainer, "TOPRIGHT", 0, 0)
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
	end
end

function Module:AdditionalSort( orig)
	return function( a, b) 
		local consA = a.consolidate or false
		local consB = b.consolidate or false
		if consA == consB then
			return orig( a, b)
		end
		return consA
	end
end
