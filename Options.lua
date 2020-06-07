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

local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L      = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")
local Module = Addon:NewModule( "Options", "AceEvent-3.0")

------------------------------------------------------------------------------------
-- Local
------------------------------------------------------------------------------------
local function GetProperty( info)
	local key = info[#info]
	return Module.profile[key]
end

local function SetProperty( info, value)
	Addon:Debug( "SetProperty", Module:GetName())
	local key = info[#info]
	Module.profile[key] = value
	Module:SendMessage( "BUVVS_UPDATE")
end

local function SetEnable( info, value) 
	Addon:Debug( "SetEnable", Module:GetName())
	if value ~= Addon:IsEnabled() then
		if value then
			Addon:Enable()
		else
			Addon:Disable()
		end
	end
end

local function SetDebug( info, value) 
	Addon:ToggleDebugLog( value)
	SetProperty(info, value) -- Make sure the changes are persistent, otherwise debug resets after every reloadUI/relog
end

-- LibDebugLog seems to constantly reset it despite the options table having the correct value for debug -> Overwriting their function to make sure the toggle is always set correctly
local function IsDebugLogEnabled(info, value)
	
	-- Load debug from savedVars, instead of relying on the non-persistent state of LibDebugLog
	local isDebug = GetProperty(info, value)
	
	return isDebug
end

local function IsForceDisabled()
	local unitAura = BuffFrame:IsEventRegistered( "UNIT_AURA")
	local buffFrame = BuffFrame:IsVisible()
	local enchantFrame = TemporaryEnchantFrame:IsVisible()
	return unitAura and buffFrame and enchantFrame
end

local function ForceFrames()
	BuffFrame:Show()
	BuffFrame:RegisterEvent( "UNIT_AURA")
	TemporaryEnchantFrame:Show()
	Module:SendMessage( "BUVVS_UPDATE")
end

local main = {
	type = "group", order = 10, name = L["Buvvs Configuration"], get = GetProperty, set = SetProperty, handler = Addon, 
	args = {

		description = { type = "description", order = 30,  name = L["Provides an easily customizable display for buffs, debuffs, and spell procs"], cmdHidden = true, fontSize = "large" },
		space1      = { type = "description", order = 40,  name = " ", cmdHidden = true },
		enabled     = { type = "toggle",      order = 140, name = L["Enabled"],  desc = L["Enable the addon (will disable Blizzard's default buff bars)"],  get = "IsEnabled",         set = SetEnable, width = "full" },
		debug       = { type = "toggle",      order = 150, name = L["Debug Mode"],    desc = L["Toggle debug mode (not particularly useful unless something has gone terribly wrong)"],    get = IsDebugLogEnabled, set = SetDebug,  width = "full" },
		masque = { type = "toggle", order = 165, name = L["Enable Masque Support"], desc = L["Enable styling of the buff icons via Masque addon library if present"], width = "full" },
		forceS      = { type = "description", order = 170, name = " ", cmdHidden = true },
		forceT      = { type = "description", order = 171, name = L["It appears that Blizzard's buff bars have been disabled (by another addon). Please check and make sure to disable the respective addon's options to let Buvvs handle this."],    hidden = IsForceDisabled, fontSize = "large" },
		force       = { type = "execute",     order = 172, name = L["Show Blizzard buff bars"],    desc = L["Show Blizzard's buff bars (regardless of whether or not Buvvs is enabled"], func = ForceFrames, disabled = IsForceDisabled },
		lockedS     = { type = "description", order = 199, name = " ", cmdHidden = true },
		locked      = { type = "toggle",      order = 200, name = L["Lock Bars"],     desc = L["Lock all bars in place and prevent them from being moved"],  width = "full" },
	}
}

------------------------------------------------------------------------------------
-- Class
------------------------------------------------------------------------------------
function Module:OnInitialize()
	self:BUVVS_PROFILE()
	LibStub( "AceConfig-3.0"):RegisterOptionsTable( Addon:GetName(), main)
	LibStub( "AceConfigDialog-3.0"):AddToBlizOptions( Addon:GetName(), Addon:GetName())
end

function Module:OnEnable()
	self:RegisterMessage( "BUVVS_PROFILE")
end

function Module:OnDisable()
	self:UnregisterMessage( "BUVVS_PROFILE")
end

function Module:BUVVS_PROFILE()
	self.profile = Addon.db.profile
end

function Module:GetOptionTable()
	return main
end

