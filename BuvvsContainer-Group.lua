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


local Type, Version = "BuvvsGroup", 3
local AceGUI  = LibStub( "AceGUI-3.0")

------------------------------------------------------------------------------------
-- Scripts
------------------------------------------------------------------------------------
local function Control_OnMouseDown( frame, ...)
	frame.obj:Fire( "OnMouseDown", ...)
end

local function Control_OnMouseUp( frame)
	frame.obj:Fire( "OnMouseUp")
end

------------------------------------------------------------------------------------
-- Methods
------------------------------------------------------------------------------------
local methods = {
	["OnAcquire"] = function( self)
	end,

	["OnRelease"] = function( self)
	end,

	["LayoutFinished"] = function( self, width, height)
		self:SetWidth( width)
		self:SetHeight( height)
	end,

	["SetGhostColor"] = function( self, color)
		self.ghost:SetColorTexture( color.r, color.g, color.b, 1)
	end,

	["SetPos"] = function( self, x, y)
		self:ClearAllPoints()
		self:SetPoint( "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
	end,

	["SetLock"] = function( self, locked)
		local frame = self.frame
		if locked then
			frame:SetMovable( false)
			frame:EnableMouse( false)
			frame:SetScript( "OnMouseDown", nil)
			frame:SetScript( "OnMouseUp",   nil)
			frame:Hide()
		else
			frame:SetScript( "OnMouseDown", Control_OnMouseDown)
			frame:SetScript( "OnMouseUp",   Control_OnMouseUp)
			frame:EnableMouse( true)
			frame:SetMovable( true)
			frame:Show()
		end
		for _,child in pairs( self.children) do
			child:SetLock( locked)
		end
	end,

	["SetBackdrop"] = function( self, backdrop)
		self.frame:SetBackdrop( backdrop)
	end,

	["SetBackdropColor"] = function( self, color)
		if type( color) == "table" then
			self.frame:SetBackdropColor( color.r, color.g, color.b)
		end
	end
}

------------------------------------------------------------------------------------
-- Constructor
------------------------------------------------------------------------------------
local function Constructor()
	local id  = AceGUI:GetNextWidgetNum( Type)
	
	local frame = CreateFrame( "Frame", Type .. id, UIParent)
	frame:SetWidth( 65)
	frame:SetHeight( 40)
	frame:SetAlpha( 1)
	frame:SetFrameStrata( "LOW")
	frame:RegisterForDrag( "LeftButton")
	frame:SetClampedToScreen( true )
	frame:Hide()
	
	local content = CreateFrame( "Frame", nil, frame)
	content:SetPoint( "TOPLEFT", frame, "TOPLEFT", 0, 0)
	content:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	
	local ghost = frame:CreateTexture( nil, "OVERLAY")
	ghost:SetBlendMode( "ADD")
	ghost:SetPoint( "TOPLEFT", frame, "TOPLEFT", 0, 0)
	ghost:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	
	local widget = {
		num     = id,
		frame   = frame,
		content = content,
		ghost   = ghost,
		drag    = drag,
		type    = Type
	}
	for method,func in pairs(methods) do
		widget[method] = func
	end
	frame.obj, content.obj = widget, widget
	
	return AceGUI:RegisterAsContainer( widget)
end

AceGUI:RegisterWidgetType( Type, Constructor, Version)
