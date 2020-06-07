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

local L = LibStub("AceLocale-3.0"):GetLocale("Buvvs", false)

------------------------------------------------------------------------------------
-- Class
------------------------------------------------------------------------------------
local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local Module = Addon:NewModule( "Profile", "AceEvent-3.0")

function Module:OnInitialize()
	local db = Addon.db
	self.profile = LibStub( "AceDBOptions-3.0"):GetOptionsTable( db)
	LibStub( "AceConfig-3.0"):RegisterOptionsTable( "Buvvs_Profile", self.profile)
	LibStub( "AceConfigDialog-3.0"):AddToBlizOptions( "Buvvs_Profile", L["Profiles"], Addon:GetName())
	db.RegisterCallback( self, "OnNewProfile")
	db.RegisterCallback( self, "OnProfileChanged")
	db.RegisterCallback( self, "OnProfileCopied")
	db.RegisterCallback( self, "OnProfileReset")
	db.RegisterCallback( self, "OnProfileDeleted")
end

function Module:GetOptionTable()
	return self.profile
end

------------------------------------------------------------------------------------
-- Profile
------------------------------------------------------------------------------------
function Module:OnNewProfile( event, db, name)
	self:SendMessage( "BUVVS_PROFILE")
	Addon:Print( format(L["Created profile %s"], name))
end

function Module:OnProfileChanged( event, db, name)
	self:SendMessage( "BUVVS_PROFILE")
	Addon:Print( format(L["Loaded profile %s"], name))
end

function Module:OnProfileCopied( event, db, name)
	self:SendMessage( "BUVVS_PROFILE")
	Addon:Print( format( L["Copied profile %s"], name))
end

function Module:OnProfileReset( event, db)
	self:SendMessage( "BUVVS_PROFILE")
	Addon:Print( format( L["Reset profile %s"], db:GetCurrentProfile()))
end

function Module:OnProfileDeleted( event, db, name)
	Addon:Print( format( L["Deleted profile %s"], name))
end
