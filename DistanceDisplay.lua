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
distanceDisplayFrame:SetWidth(150)
distanceDisplayFrame:SetHeight(60)
distanceDisplayFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
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
distanceText:SetFont("Fonts/FRIZQT__.TTF", 24, "OUTLINE")
distanceText:SetPoint("CENTER", distanceDisplayFrame, "CENTER")
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
        if distance then
            if UnitClass("player") == "Warrior" then
                if distance > 8 then
                    distanceText:SetTextColor(1, 0, 0) -- Red for >8 yards
                elseif distance > 5 then
                    distanceText:SetTextColor(0.54, 0.81, 0.94) -- Baby blue for 5-8 yards
                else
                    distanceText:SetTextColor(0, 1, 0) -- Green for <=5 yards
                end
            else
                if distance > 30 then
                    distanceText:SetTextColor(1, 0, 0) -- Red text
                else
                    distanceText:SetTextColor(0, 1, 0) -- Green text
                end
            end
            distanceText:SetText(string.format("%.2f yds", distance))
        else
            distanceText:SetText("--")
        end
    else
        distanceText:SetText("--")
    end
    UpdateFrameVisibility() -- Call to handle autoHide logic
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
