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

local MAJOR = "debuff"

local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L      = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")

local UPDATE_TIME = 0.2
local MAX_BUTTON  = 16 -- DEBUFF_ACTUAL_DISPLAY = 16

local Module = Addon:NewBarModule( MAJOR)
Module.filter  = "HARMFUL"
Module.color   = { r=0.8, g=0.2, b=0.2 }
Module.proName = "debuff"

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
	type = "group", order = 30, name = L["Debuff Bar Settings"], handler = Module, get = "GetProperty", set = "SetProperty", args = args
}
local dialogOptions = {
	type = "group", order = 20, name = L["Debuff Bar"] , handler = Module, get = "GetProperty", set = "SetProperty", args = args,
	plugins = {
		p1 = { 
			descr = { type = "description", order = 5, name = L["Debuff Bar Settings"], fontSize = "large" }
		}
	}
}
local pivot = {}

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
function Module:OnModuleInitialize()
	self:RegisterOptions( blizzOptions, L["Debuff Bar"] )
	self:CloneAura( "debuff")
	for k in pairs( self.aura) do
		pivot[k] = k
	end
end

function Module:GetOptionTable()
	return dialogOptions
end

function Module:UpdateAnchors( sort)
	Addon:Debug( self, ":UpdateAnchors")
	local profile = self.profile
	if profile.show then
		self:SortAura()
		for i,child in pairs( self.group.children) do
			local a = self.aura[i]
			pivot[a.id] = i
			local buff = _G["DebuffButton"..a.id]
			self:UpdateMasque(buff, "Debuffs")
			child:SetBuff( buff)
		end
	end
end

function Module:UpdateBuffAnchors()
	self:UpdateAnchors()
end

function Module:UpdateDebuffAnchors( buttonName, index)
	if self.profile.show then
		local i = pivot[index]
		local child = self.group.children[i]
		local buff  = _G["DebuffButton"..index]
		child:SetBuff( buff)
	end
end

function Module:MoveTo( offset)
	for i,child in pairs( self.group.children) do
		child:SetBuff( nil)
	end
	local numBuffs = BUFF_ACTUAL_DISPLAY + BuffFrame.numEnchants
	
	-- MOD: Consolidated buffs were removed. This is no longer needed
	-- if BuffFrame.numConsolidated > 0 then
	--	numBuffs = numBuffs - BuffFrame.numConsolidated + 1
	--end
	-- /MOD
	local rows = math.ceil( numBuffs / BUFFS_PER_ROW) + 1
	local height = TempEnchant1:GetHeight()	+ BUFF_ROW_SPACING
	local count = 1
	local last, first
	for i = 1,#self.aura do
		local buff = _G["DebuffButton"..i]
		if buff then
			buff:ClearAllPoints()
			if last and first then
				buff:SetPoint( "TOPRIGHT", last, "TOPLEFT", -5, 0 )
			elseif first then
				buff:SetPoint( "TOPRIGHT", first, "BOTTOMRIGHT", 0, -BUFF_ROW_SPACING)
				first = buff
			else
				buff:SetPoint( "TOPRIGHT", BuffFrame, "TOPRIGHT", 0, offset - rows * height)
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
