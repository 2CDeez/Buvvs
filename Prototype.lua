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

local MAJOR = "prototype"

local Addon  = LibStub( "AceAddon-3.0"):GetAddon( "Buvvs")
local L      = LibStub( "AceLocale-3.0"):GetLocale( "Buvvs")
local AceGUI = LibStub( "AceGUI-3.0")
local Masque = LibStub("Masque", true)
local NOTHING = {}
local TIMER_DESC = {
	L["Default (Blizzard Style)"],
	L["Short (XXm)"],
	L["Full (XX:XX)"],
}
local SORT_DESC = {
	L["Default (Blizzard Style)"],
	L["Name"] .. " (" .. L["Ascending"] .. ")",
	L["Name"].. " (" .. L["Descending"] .. ")",
	L["Time left"] .. " (" .. L["Ascending"] .. ")",
	L["Time left"] .. " (" .. L["Descending"] .. ")",
	L["Duration"] .. " (" .. L["Ascending"] .. ")",
	L["Duration"] .. " (" .. L["Descending"] .. ")",
}
local SORT_TYPES = {
	["none"]   = 1,
	["alpha"]  = 2,
	["revert"] = 3,
	["inc"]    = 4,
	["dec"]    = 5,
	["durationasc"]  = 6,
	["durationdesc"] = 7,
}

-- Lookup Masque groups (to translate between the official Masque group names and the ones that Buvvs uses internally) -> Use these to keep settings consistent even if group names change
local masqueLUT = {
	combo = "Combos",
	buff = "Buffs",
	debuff = "Debuffs",
	proc = "Procs",
	weapon = "Enchants",
}


------------------------------------------------------------------------------------
-- Sorting
------------------------------------------------------------------------------------
local function SortNone( a, b)
	return a.id < b.id
end

local function SortNameAsc( a, b)
	if a.name and b.name then return a.name < b.name end
	if a.name then return true end
	if b.name then return false end
	return a.id < b.id
end

local function SortNameDesc( a, b)
	if a.name and b.name then return a.name > b.name end
	if a.name then return true end
	if b.name then return false end
	return a.id < b.id
end

local function SortTimeLeftAsc( a, b)
	if a.name and b.name then
		if a.timeLeft and b.timeLeft then return a.timeLeft < b.timeLeft end
		if a.timeLeft then return true end
		if b.timeLeft then return false end
		return a.name < b.name
	end
	if a.name then return true end
	if b.name then return false end
	return a.id < b.id
end

local function SortTimeLeftDesc( a, b)
	if a.name and b.name then
		if a.timeLeft and b.timeLeft then return a.timeLeft > b.timeLeft end
		if a.timeLeft then return false end
		if b.timeLeft then return true end
		return a.name < b.name
	end
	if a.name then return true end
	if b.name then return false end
	return a.id < b.id
end

local function SortDurationAsc( a, b)
	if a.name and b.name then
		if a.duration and b.duration then return a.duration < b.duration end
		if a.duration then return true end
		if b.duration then return false end
		return a.name < b.name
	end
	if a.name then return true end
	if b.name then return false end
	return a.id < b.id
end

local function SortDurationDesc( a, b)
	if a.name and b.name then
		if a.duration and b.duration then return a.duration > b.duration end
		if a.duration then return true end
		if b.duration then return false end
		return a.name < b.name
	end
	if a.name then return true end
	if b.name then return false end
	return a.id < b.id
end

------------------------------------------------------------------------------------
-- Script
------------------------------------------------------------------------------------
local function Bar_OnMouseDown( group, event, button)
	Addon:Debug( "Bar_OnMouseDown", button)
	group.frame:StartMoving()
end

local function Bar_OnMouseUp( group)
	Addon:Debug( "Bar_OnMouseUp")
	group.frame:StopMovingOrSizing()
	local profile = group:GetUserData( "profile")
	profile.xPos = group.frame:GetLeft()
	profile.yPos = group.frame:GetBottom()
end

------------------------------------------------------------------------------------
-- Locale
------------------------------------------------------------------------------------
local function Renumber( bar)
	local group = bar.group
	local max = bar.profile.number
	while #group.children > max do
		local child = tremove( group.children)
		AceGUI:Release( child)
	end
	local n = #group.children + 1
	for i = n,max do
		local child = AceGUI:Create( "BuvvsBuff")
		child:Initialize( i, bar.filter)
		group:AddChild( child)
	end
	group:DoLayout()
end

local function UpdateBar( bar)
	if not Addon:IsEnabled() then
		Addon:Debug( "UpdateBar1")
		bar.group:SetPos( bar.profile.xPos, bar.profile.yPos)
		bar.group:SetLock( true)
		bar:MoveTo( 0)
	elseif bar.profile.show then
		Addon:Debug( "UpdateBar2")
		Renumber( bar)
		local locked = bar:IsLocked()
	--	if locked then // Disabled this, because the frames aren't shown initially when unlocked after a relog/reloadUI
			bar.group:SetPos( bar.profile.xPos, bar.profile.yPos)
	--	end
		bar.group:SetLock( locked)
		bar:UpdateAnchors( true)
	else
		Addon:Debug( "UpdateBar3")
		bar.group:SetPos( bar.profile.xPos, bar.profile.yPos)
		bar.group:SetLock( true)
		bar:MoveTo( 1000)
	end
end

local function UpdateProfile( bar)
	Addon:Debug( "UpdateProfile")
	bar.profile = Addon.db.profile[bar.proName]
	
	if Masque then -- Update skins (to update groups with newly added/removed buttons)
		local style = bar.profile.style or NOTHING
		Addon:Debug("Masque update for category: " .. bar.proName .. " -> lookup results in group name: " .. (masqueLUT[bar.proName] or "<all>"))
		Masque:Group("Buvvs", masqueLUT[bar.proName]):ReSkin() -- defaults to nil = All groups (set via Masque API)
	end

	bar.group:SetUserData( "profile", bar.profile)
end

local function CreateSortFkt( bar, orig)
	return bar.AdditionalSort and bar:AdditionalSort( orig) or orig
end

------------------------------------------------------------------------------------
-- Main
------------------------------------------------------------------------------------
local prototype = {
	["OnInitialize"] = function( self)
		local group = AceGUI:Create( "BuvvsGroup")
		group:SetLayout( "BuffBar")
		group:SetGhostColor( self.color)
		group:SetCallback( "OnMouseDown", Bar_OnMouseDown)
		group:SetCallback( "OnMouseUp",   Bar_OnMouseUp)
		self.group = group
		self.aura = {}
		self.profile = Addon.db.profile[self.proName]
		self.sortFkt = {
			none         = CreateSortFkt( self, SortNone),
			alpha        = CreateSortFkt( self, SortNameAsc),
			revert       = CreateSortFkt( self, SortNameDesc),
			inc          = CreateSortFkt( self, SortTimeLeftAsc),
			dec          = CreateSortFkt( self, SortTimeLeftDesc),
			durationasc  = CreateSortFkt( self, SortDurationAsc),
			durationdesc = CreateSortFkt( self, SortDurationDesc)
		}
		if type( self.OnModuleInitialize) == "function" then
			self:OnModuleInitialize()
		end
	end,
	
	["OnEnable"] = function( self)
		Addon:Debug( self, ":OnEnable")
		UpdateProfile( self)
		if type( self.OnModuleEnable) == "function" then
			self:OnModuleEnable()
		end
		UpdateBar( self)
		self:RegisterMessage( "Buvvs_UPDATE")
		self:RegisterMessage( "Buvvs_PROFILE")
	end,
	
	["OnDisable"] = function( self)
		Addon:Debug( self, ":OnDisable")
		self:UnregisterMessage( "Buvvs_UPDATE")
		self:UnregisterMessage( "Buvvs_PROFILE")
		UpdateBar( self)
		if type( self.OnModuleDisable) == "function" then
			self:OnModuleDisable()
		end
	end,
	
	["Buvvs_UPDATE"] = function( self)
		Addon:Debug( self, ":Buvvs_UPDATE")
		UpdateBar( self)
	end,

	["Buvvs_PROFILE"] = function( self)
		Addon:Debug( self, ":Buvvs_PROFILE")
		UpdateProfile( self)
		UpdateBar( self)
	end,

	--- Adds the buff's button to Masque if it hasn't been added already
	["UpdateMasque"] = function( self, buff, groupName)
		
		if not groupName then -- Can't add button, as it isn't part of a valid group (this will likely only happen if the function is called from legacy code and I missed updating it from Bison's original LBF update routine)
			Addon:Debug(self, "Can't update button style via Masque because no valid group name was provided for it")
			return
		end
		
		if Masque and buff then -- Register button with Masque
		
			groupName = groupName or masqueLUT[self.proName] -- Override the given group name if the button has another saved in its object table -> I guess this is a bit excessive, but I'm not 100% sure if the old Bison code handles the group names properly otherwise... TODO: Remove if not needed and use only the "proName" (ugh)?
		
			if Addon.db.profile.masque then -- Masque styling is enabled
				if not buff.isHandledByMasque then -- Button wasn't yet added to Masque -> Register it
					Masque:Group( "Buvvs", groupName):AddButton( buff)
					buff.isHandledByMasque = true
				end
			else -- Styling is disabled
				if buff.isHandledByMasque then -- Button was previously added to Masque -> Unregister it
					Masque:Group( "Buvvs", groupName):RemoveButton( buff)
					buff.isHandledByMasque = nil
				end
			end
		end
		if buff then -- Save group name in the button's container object (? - this part is from the old Bison and I haven't changed it)
			buff.proName = self.proName
		end
	end,

	["RegisterOptions"] = function( self, options, menuName)
		local modName = "Buvvs_"..self.proName
		LibStub( "AceConfig-3.0"):RegisterOptionsTable( modName, options)
		LibStub( "AceConfigDialog-3.0"):AddToBlizOptions( modName, menuName, Addon:GetName())
	end,

	["GetUserBuff"] = function( self, user, id)
		local name = user..id
		local buff = _G[name]
		if not buff then
			buff = CreateFrame( "Button", name, BuffFrame, "AuraButtonTemplate")
			buff.parent = BuffFrame
			buff:SetID( id)
			buff.unit = PlayerFrame.unit
			buff.filter = self.filter
			buff:SetAlpha( 1.0)
	--		local back = buff:CreateTexture( nil, "OVERLAY")
	--		back:SetColorTexture( 0, 0, 1, 1)
	--		back:SetBlendMode( "ADD")
	--		back:SetPoint( "TOPLEFT", buff, "TOPLEFT", 0, 0)
	--		back:SetPoint( "BOTTOMRIGHT", buff, "BOTTOMRIGHT", 0, 0)
		end
		return buff
	end,
	
	["UpdateUserBuff"] = function( self, buff, aura)
		if not buff then
			return
		elseif aura.name then
			buff:Show()
			if aura.timeLeft then
				if SHOW_BUFF_DURATIONS == "1" then
					buff.duration:Show()
				else
					buff.duration:Hide()
				end
				if not buff.timeLeft then
					Addon:Debug("AuraButton_OnUpdate for frame " .. buff:GetName() .. " with duration:GetName() = " .. buff.duration:GetName() .. ", aura.timeLeft = " .. aura.timeLeft .. ", aura.name = " .. aura.name)
					buff.timeMod = 0 -- Necessary to avoid breaking AuraButton_OnUpdate, as regular buff icons have this value (TODO: It could be used to change the accuracy, e.g. timeMod = 0.001 -> display as milliseconds, but then it is formatted in the usual hh:mm format)
					buff:SetScript( "OnUpdate", AuraButton_OnUpdate)
				end
				buff.timeLeft = aura.timeLeft
				buff.expirationTime = aura.expiration
			else
				buff.duration:Hide()
				buff:SetScript( "OnUpdate", nil)
				buff.timeLeft = nil
			end
			local icon = _G[buff:GetName().."Icon"]
			if icon then
				icon:SetTexture( aura.texture)
			end
			if aura.count > 1 then
				buff.count:SetText( aura.count)
				buff.count:Show()
			else
				buff.count:Hide()
			end
			if GameTooltip:IsOwned( buff) then
				GameTooltip:SetUnitAura( PlayerFrame.unit, aura.id, aura.filter)
			end
		else
			self:HideUserBuff( buff)
		end	
	end,

	["HideUserBuff"] = function( self, buff)
		if buff then
			buff:Hide()
			buff.duration:Hide()
			buff:SetScript( "OnUpdate", nil)
			buff.timeLeft = nil
		end
	end,

	["CloneAura"] = function( self, name)
		Addon:CloneAura( self.aura, name)
	end,

	["SortAura"] = function( self, name)
		table.sort( self.aura, self:GetSort())
	end,

	["IsLocked"] = function( self)
		return Addon.db.profile.locked
	end,
	
	["GetSort"] = function( self)
		local sort = self.profile.sort
		return self.sortFkt[sort] or SortNone
	end,

	["GetProperty"] = function( self, info)
		local key = info[#info]
		return self.profile[key]
	end,
	
	["SetProperty"] = function( self, info, value)
		local key = info[#info]
		self.profile[key] = value
		UpdateBar( self)
	end,
	
	["SetScale"] = function( self, info, value)
		value = tonumber( value)
		if value and value > 0 and value <= 2 then
			self.profile.scale = value
			UpdateBar( self)
		end
	end,
	
	["SetCols"] = function( self, info, value)
		local maxButton = info.option.max or 16
		value = tonumber( value)
		if value and value > 0 and value <= maxButton then
			value = math.floor( value)
			self.profile.cols = value
			self.profile.rows = math.ceil( self.profile.number / value)
			UpdateBar( self)
		end
	end,
	
	["SetRows"] = function( self, info, value)
		local maxButton = info.option.max or 16
		value = tonumber( value)
		if value and value > 0 and value <= maxButton then
			value = math.floor( value)
			self.profile.cols = math.ceil( self.profile.number / value)
			self.profile.rows = value
			UpdateBar( self)
		end
	end,
	
	["SetNumber"] = function( self, info, value)
		local maxButton = info.option.max or 16
		value = tonumber( value)
		if value and value > 0 and value <= maxButton then
			value = math.floor( value)
			self.profile.number = math.floor( value)
			self.profile.cols   = math.ceil( self.profile.number / self.profile.rows)
			self.profile.rows   = math.ceil( self.profile.number / self.profile.cols)
			UpdateBar( self)
		end
	end,
	
	["SetXPadding"] = function( self, info, value)
		local min = info.option.min or -20
		local max = info.option.max or 20
		value = tonumber( value)
		if value and value >= min and value <= max then
			self.profile.xPadding = math.floor( value)
			UpdateBar( self)
		end
	end,
	
	["SetYPadding"] = function( self, info, value)
		local min = info.option.min or -50
		local max = info.option.max or 50
		value = tonumber( value)
		if value and value >= min and value <= max then
			self.profile.yPadding = math.floor( value)
			UpdateBar( self)
		end
	end,
	
	["SetBigger"] = function( self, info, value)
		local min = info.option.min or 1
		local max = info.option.max or 2
		value = tonumber( value)
		if value and value >= min and value <= max then
			self.profile.bigger = value
			UpdateBar( self)
		end
	end,
	
	["GetTimerDesc"] = function( self)
		return TIMER_DESC
	end,
	
	["GetSortDesc"] = function( self)
		return SORT_DESC
	end,
	
	["GetSortType"] = function( self)
		return SORT_TYPES[self.profile.sort]
	end,
	
	["SetSortType"] = function( self, info, value)
		for k,v in pairs(SORT_TYPES) do
			if v == value then
				self.profile.sort = k
				UpdateBar( self)
				break
			end
		end
	end,
}
------------------------------------------------------------------------------------
-- Class
------------------------------------------------------------------------------------
function Addon:NewBarModule( name, ...)
	if self:GetModule( name, true) then
		error( "can not register double module: "..name, 2)
	end
	return self:NewModule( name, prototype, "AceEvent-3.0", ...)
end

------------------------------------------------------------------------------------
-- Layout
------------------------------------------------------------------------------------
AceGUI:RegisterLayout( "BuffBar", function( content, children)
	local profile = content.obj:GetUserData( "profile") or NOTHING
	local xPadding = -profile.xPadding or 0
	local yPadding = -profile.yPadding or 0
	local horizontal = profile.horizontal
	local scale  = profile.scale or 1.0
	local bigger = (profile.bigger or 1.0) * scale
	local cols = profile.cols or 10
	local rows = profile.rows or 4
	local last, first
	local width = 0
	local height = 0
	local i = 1
	local max = horizontal and cols or rows
	for k,child in pairs( children) do
		local frame = child.frame
		frame:ClearAllPoints()
		if last and first then
			if horizontal then
				if xPadding > 0 then
					frame:SetPoint( "LEFT", last, "RIGHT", xPadding, 0)
				else
					frame:SetPoint( "RIGHT", last, "LEFT", xPadding, 0)
				end
			else
				if yPadding > 0 then
					frame:SetPoint( "BOTTOM", last, "TOP", 0, yPadding)
				else
					frame:SetPoint( "TOP", last, "BOTTOM", 0, yPadding)
				end
			end
		elseif first then
			if horizontal then
				if yPadding > 0 then
					frame:SetPoint( "BOTTOM", first, "TOP", 0, yPadding)
				else
					frame:SetPoint( "TOP", first, "BOTTOM", 0, yPadding)
				end
			else
				if xPadding > 0 then
					frame:SetPoint( "LEFT", first, "RIGHT", xPadding, 0)
				else
					frame:SetPoint( "RIGHT", first, "LEFT", xPadding, 0)
				end
			end
			first = frame
		else
			if xPadding > 0 then
				if yPadding > 0 then
					frame:SetPoint( "BOTTOMLEFT", content)
				else
					frame:SetPoint( "TOPLEFT", content)
				end
			else
				if yPadding > 0 then
					frame:SetPoint( "BOTTOMRIGHT", content)
				else
					frame:SetPoint( "TOPRIGHT", content)
				end
			end
			first = frame
		end
		last = frame
		if child.SetScale then
			child:SetScale( child:GetUserData( "bigger") and bigger or scale)
		end
		if child.DoLayout then
			child:DoLayout()
		end
		width  = math.max( width, frame.width or frame:GetWidth() or 0)
		height = math.max( height, frame.height or frame:GetHeight() or 0)
		i = i + 1
		if i > max then
			i = 1
			last = nil
		end
	end
	content.obj:LayoutFinished( scale * cols * (width + abs(xPadding)), scale * rows * (height + abs(yPadding)))
end)
