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

local MAJOR = "weapon"

local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L      = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")

local UPDATE_TIME = 0.2
local MAX_BUTTON  = 3

local Module = Addon:NewBarModule( MAJOR)
Module.color   = { r=0.2, g=0.2, b=0.2 }
Module.proName = "weapon"

local args = {
	option = { 
		type = "group", order = 10, name = L["General Settings"], inline = true, 
		args = {
			show     = { type = "toggle", order = 10, name = L["Enable Bar"],     desc = L["Toggle this bar and all of its icons"], width = "full" },
			sort     = { type = "select", order = 20, name = L["Sort by"],     desc = L["Set how the icons should be sorted"], get = "GetSortType", set = "SetSortType", values = "GetSortDesc" },
			timer    = { type = "select", order = 30, name = L["Timer Style"],    desc =L["Change the timer format for this bar"], values = "GetTimerDesc" },
			flashing = { type = "toggle", order = 40, name = L["Enable Flashing"], desc = L["Flash button as the buff duration approaches zero"] },
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
	type = "group", order = 40, name = L["Weapon Enchants"], handler = Module, get = "GetProperty", set = "SetProperty", args = args
}
local dialogOptions = {
	type = "group", order = 20, name = L["Weapon Enchants Bar"], handler = Module, get = "GetProperty", set = "SetProperty", args = args,
	plugins = {
		p1 = { 
			descr = { type = "description", order = 5, name = L["Weapon Enchants"], fontSize = "large" }
		}
	}
}

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
function Module:OnModuleInitialize()
	self:RegisterOptions( blizzOptions, L["Weapon Enchants Bar"])
	self:CloneAura( "weapon")
end

function Module:GetOptionTable()
	return dialogOptions
end

function Module:UpdateAnchors( sort)
--	Addon:Debug( self, ":UpdateAnchors")
	if self.profile.show then
		self:SortAura()
		for i,child in pairs( self.group.children) do
			local a = self.aura[i]
			local buff = _G["TempEnchant"..a.id]
			-- self:UpdateLBF( buff)
				-- MOD
			self:UpdateMasque(buff)
			-- /MOD
			child:SetBuff( buff)
		end
	end
end

function Module:UpdateEnchantAnchors()
	self:UpdateAnchors()
end

function Module:MoveTo( offset)
	local count = 1
	local last, first
	for i = 1,#self.aura do
		local buff = _G["TempEnchant"..i]
		if buff then
			buff:ClearAllPoints()
			if last and first then
				buff:SetPoint( "TOPRIGHT", last, "TOPLEFT", -5, 0 )
			elseif first then
				buff:SetPoint( "TOPRIGHT", first, "BOTTOMRIGHT", 0, -BUFF_ROW_SPACING)
				first = buff
			else
				buff:SetPoint( "TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, offset)
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
