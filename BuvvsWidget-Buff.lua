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

local Type, Version = "BuvvsBuff", 4
local AceGUI = LibStub( "AceGUI-3.0")
local WEAPON = { "MH", "OH", "TH" }

------------------------------------------------------------------------------------
-- Scripts
------------------------------------------------------------------------------------
local function Control_OnMouseDown( frame, ...)
	frame.obj.parent:Fire( "OnMouseDown", ...)
end

local function Control_OnMouseUp( frame)
	frame.obj.parent:Fire( "OnMouseUp")
end

local function SetBuffScale( self, scale)
	local buff = self.userdata.buff
	if buff then
		buff:SetScale( scale or 1)
	end
end

------------------------------------------------------------------------------------
-- Methods
------------------------------------------------------------------------------------
local methods = {
	["OnAcquire"] = function( self)
	end,

	["OnRelease"] = function( self)
		SetBuffScale( self, 1)
		self:SetLock( true)
	end,

	["SetBuff"] = function( self, buff)
		SetBuffScale( self, 1)
		self.userdata.buff = buff
		if buff then
			buff:ClearAllPoints()
			buff:SetAllPoints( self.frame)
		end
		SetBuffScale( self, self.userdata.scale)
	end,

	["SetScale"] = function( self, scale)
		self.userdata.scale = scale
		self.frame:SetScale( scale or 1)
		SetBuffScale( self, scale)
	end,

	["SetSpell"] = function( self, spellID)
		if spellID then
			self.spell:SetText( spellID)
			self.spell:Show()
		else
			self.spell:Hide()
		end
	end,

	["SetLock"] = function( self, locked)
		if self.userdata.locked ~= locked then
			self.userdata.locked = locked
			local frame = self.frame
			if locked then
				frame:SetScript( "OnMouseDown", nil)
				frame:SetScript( "OnMouseUp",   nil)
				frame:Hide()
			else
				frame:SetScript( "OnMouseDown", Control_OnMouseDown)
				frame:SetScript( "OnMouseUp",   Control_OnMouseUp)
				frame:Show()
			end
		end
	end,

	["Initialize"] = function( self, index, filter)
		if filter then
			self.ghost:SetText( index)
		else
			self.ghost:SetText( WEAPON[index] or "??")
		end
	end
}

------------------------------------------------------------------------------------
-- Constructor
------------------------------------------------------------------------------------
local function Constructor()
	local id  = AceGUI:GetNextWidgetNum( Type)
	local name = Type .. id
	
	local frame = CreateFrame( "Button", name, UIParent)
	frame:SetAlpha( 1)
	frame:SetWidth( 32)
	frame:SetHeight( 32)
	frame:SetFrameStrata( "LOW")
	frame:Hide()
	
	local spell = frame:CreateFontString( name.."Spell", "BACKGROUND", "GameFontWhiteSmall")
	spell:SetPoint( "BOTTOM", frame, "TOP", 0, 0)
	spell:Hide()

	local ghost = frame:CreateFontString( nil, "OVERLAY", "GameFontHighlight")
	ghost:SetHeight( 10)
	ghost:SetPoint( "TOPLEFT", frame, "TOPLEFT", 0, 0)
	ghost:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

	local back = frame:CreateTexture( nil, "OVERLAY")
	back:SetColorTexture( 0, 0, 1, 1)
	back:SetBlendMode( "ADD")
	back:SetPoint( "TOPLEFT", frame, "TOPLEFT", 0, 0)
	back:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

	local widget = {
		num      = id,
		frame    = frame,
		spell    = spell,
		ghost    = ghost,
		back     = back,
		type     = Type
	}
	for method, func in pairs( methods) do
		widget[method] = func
	end
	frame.obj = widget
	
	return AceGUI:RegisterAsWidget( widget)
end

AceGUI:RegisterWidgetType( Type, Constructor, Version)
