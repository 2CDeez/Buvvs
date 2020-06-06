local BuvvsFrame = CreateFrame("Frame", "Buvvs", UIParent)

local bg = BuvvsFrame:CreateTexture()
bg:SetAllPoints(BuvvsFrame)
bg:SetColorTexture(0, 1, 0, 0.3)
bg:Show()

local SetPoint = BuvvsFrame.SetPoint
local ClearAllPoints = BuvvsFrame.ClearAllPoints
ClearAllPoints(BuffFrame)
SetPoint(BuffFrame, "TOPRIGHT", BuvvsFrame, "TOPRIGHT")
hooksecurefunc(BuffFrame, "SetPoint", function(frame)
	ClearAllPoints(frame)
	SetPoint(frame, "TOPRIGHT", BuvvsFrame, "TOPRIGHT")
end)

local header = BuvvsFrame:CreateFontString(nil, "OVERLAY", "TextStatusBarText")
header:SetAllPoints(BuvvsFrame)
header:SetText("Buvvs")
header:Show()

BuvvsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
BuvvsFrame:SetWidth(280)
BuvvsFrame:SetHeight(225)
BuvvsFrame:Show()
BuvvsFrame:EnableMouse(true)
BuvvsFrame:RegisterForDrag("LeftButton")
BuvvsFrame:SetMovable(true)
BuvvsFrame:SetScript("OnDragStart", function(frame) frame:StartMoving() end)
BuvvsFrame:SetScript("OnDragStop", function(frame)
	frame:StopMovingOrSizing()
	local a, _, b, c, d = frame:GetPoint()
	BuvvsOptions[1] = a
	BuvvsOptions[2] = b
	BuvvsOptions[3] = c
	BuvvsOptions[4] = d
end)

BuvvsFrame:RegisterEvent("PLAYER_LOGIN")
BuvvsFrame:SetScript("OnEvent", function(display)
	if not BuvvsOptions then
		BuvvsOptions = {"CENTER", "CENTER", 0, 0, false}
	end

	display:ClearAllPoints()
	display:SetPoint(BuvvsOptions[1], UIParent, BuvvsOptions[2], BuvvsOptions[3], BuvvsOptions[4])

	if BuvvsOptions[5] then
		bg:Hide()
		header:Hide()
		display:EnableMouse(false)
		display:SetMovable(false)
	end

	display:UnregisterEvent("PLAYER_LOGIN")
	display:SetScript("OnEvent", nil)
end)

SlashCmdList.Buvvs = function()
	if not BuvvsOptions then return end

	if not BuvvsOptions[5] then
		bg:Hide()
		header:Hide()
		BuvvsFrame:EnableMouse(false)
		BuvvsFrame:SetMovable(false)
		BuvvsOptions[5] = true
		print("|cFF33FF99Buvvs|r:", _G.LOCKED)
	else
		bg:Show()
		header:Show()
		BuvvsFrame:EnableMouse(true)
		BuvvsFrame:SetMovable(true)
		BuvvsOptions[5] = false
		print("|cFF33FF99Buvvs|r:", _G.UNLOCK)
	end
end
SLASH_Buvvs1 = "/Buvvs"
