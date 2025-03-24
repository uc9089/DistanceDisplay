-- Distance Display Addon for Turtle WoW

-- Add autoHide to the saved variables
DistanceDisplaySettings = DistanceDisplaySettings or {
    point = "CENTER",
    xOfs = 0,
    yOfs = 0,
    locked = false,
    hidden = false,
    scale = 0.75,
    autoHide = false -- Default: autoHide is off
}

-- Create a global namespace
DistanceDisplay = DistanceDisplay or {}

-- Create the main frame for distance display
local distanceDisplayFrame = CreateFrame("Frame", "DistanceDisplayFrame", UIParent)
distanceDisplayFrame:SetWidth(90)
distanceDisplayFrame:SetHeight(30)
distanceDisplayFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 1, right = 1, top = 1, bottom = 1 },
})
distanceDisplayFrame:SetBackdropColor(0, 0, 0, 0.8)

distanceDisplayFrame:EnableMouse(true)
distanceDisplayFrame:SetMovable(true)
distanceDisplayFrame:RegisterForDrag("LeftButton")

-- Set up dragging
distanceDisplayFrame:SetScript("OnDragStart", function()
    if not DistanceDisplaySettings.locked then
        distanceDisplayFrame:StartMoving()
    end
end)

distanceDisplayFrame:SetScript("OnDragStop", function()
    distanceDisplayFrame:StopMovingOrSizing()
    local point, _, _, xOfs, yOfs = distanceDisplayFrame:GetPoint()
    DistanceDisplaySettings.point = point
    DistanceDisplaySettings.xOfs = xOfs
    DistanceDisplaySettings.yOfs = yOfs
end)

-- Add text to display distance
local distanceText = distanceDisplayFrame:CreateFontString(nil, "OVERLAY")
distanceText:SetFont("Interface\\AddOns\\HealersMate\\fonts\\BigNoodleTitling.ttf", 18, "OUTLINE")
distanceText:SetPoint("CENTER", distanceDisplayFrame, "CENTER")
distanceText:SetTextColor(1, 1, 1)
distanceText:SetText("--")

-- Update visibility based on settings and autoHide
local function UpdateFrameVisibility()
    if DistanceDisplaySettings.hidden then
        distanceDisplayFrame:Hide()
    elseif DistanceDisplaySettings.autoHide and not UnitExists("target") then
        distanceDisplayFrame:Hide()
    else
        distanceDisplayFrame:Show()
    end
end

-- Update frame scale
local function UpdateFrameScale(scale)
    distanceDisplayFrame:SetScale(scale)
end

-- Adjust distance for melee range issues
local function GetAdjustedDistance(target)
    local distance = UnitXP("distanceBetween", "player", target)
    if distance and distance <= 10 then
        distance = distance
    end
    return distance
end

-- Event handling for distance updates
local function UpdateDistance()
    local target = "target"
    if UnitExists(target) then
        local distance = UnitXP("distanceBetween", "player", target)
		if distance == nil then
			distanceText:SetText("--")
			distanceDisplayFrame:SetBackdropColor(0, 0, 0, 0.8)
			
        elseif distance < 5 then
            distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(0, 0, 1, 0.95)
		elseif distance > 5 and distance < 8 then
            distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(0.2, 0.5, 1, 0.95)
		
		elseif distance > 8 and distance < 20 then
            distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(0.34, 0.7, 1, 0.95)

		elseif distance > 20 and distance < 30 then
            distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(0, 0.86, 0, 0.95)

		elseif distance > 30 and distance < 35 then
            distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(0.7, 0.86, 0, 0.95)

		elseif distance > 35 and distance < 41 then
            distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(1, 1, 0, 0.95)

		else
			distanceText:SetText(string.format("%.2f yds", distance))
			distanceDisplayFrame:SetBackdropColor(1, 0, 0, 0.3)

		end

    else
        distanceText:SetText("--")
		distanceDisplayFrame:SetBackdropColor(0, 0, 0, 0.8)
    end
    UpdateFrameVisibility() -- Call to handle autoHide logic
end

local function UpdateSight()
local target = "target"
	if UnitExists(target) then
		local los = UnitXP("inSight", "player", target)
		if los == true then
			distanceText:SetTextColor(1, 1, 1)
		else
			distanceText:SetTextColor(1, 0.4, 0.4)
		end
	end
end

-- Update /dd command to handle autohide toggle
SLASH_DD1 = "/dd"
SlashCmdList["DD"] = function(input)
    if input == "lock" then
        DistanceDisplaySettings.locked = true
        print("Distance Display: Frame locked.")
    elseif input == "unlock" then
        DistanceDisplaySettings.locked = false
        print("Distance Display: Frame unlocked.")
    elseif input == "hide" then
        DistanceDisplaySettings.hidden = true
        UpdateFrameVisibility()
        print("Distance Display: Frame hidden.")
    elseif input == "show" then
        DistanceDisplaySettings.hidden = false
        UpdateFrameVisibility()
        print("Distance Display: Frame shown.")
    elseif input == "autohide" then
        DistanceDisplaySettings.autoHide = not DistanceDisplaySettings.autoHide
        print("Distance Display: Auto-hide is now " .. (DistanceDisplaySettings.autoHide and "enabled." or "disabled."))
        UpdateFrameVisibility()
    else
        local scale = tonumber(input)
        if scale and scale >= 0.1 and scale <= 1.0 then
            DistanceDisplaySettings.scale = scale
            distanceDisplayFrame:SetScale(scale)
            print("Distance Display: Frame scale set to " .. (scale * 100) .. "%.")
        else
            print("Distance Display Commands:")
            print("  lock - Lock the frame.")
            print("  unlock - Unlock the frame.")
            print("  hide - Hide the frame.")
            print("  show - Show the frame.")
            print("  autohide - Toggle auto-hide when no target is selected.")
            print("  <scale> - Set scale (0.1 to 1.0). For example, /dd 0.5")
        end
    end
end

-- Register events for real-time updates
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function()
    UpdateDistance()
	UpdateSight()
end)
updateFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

-- Initialize settings and position
local function InitializeDistanceDisplay()
    distanceDisplayFrame:SetPoint(
        DistanceDisplaySettings.point,
        UIParent,
        DistanceDisplaySettings.point,
        DistanceDisplaySettings.xOfs,
        DistanceDisplaySettings.yOfs
    )
    distanceDisplayFrame:SetScale(DistanceDisplaySettings.scale)
    UpdateFrameVisibility()
    print("Distance Display: Loaded and initialized.")
end

-- Hook into PLAYER_LOGIN to ensure settings are applied
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", InitializeDistanceDisplay)
