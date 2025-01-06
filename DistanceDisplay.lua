-- Distance Display Addon for Turtle WoW

-- Saved Variables
DistanceDisplaySettings = DistanceDisplaySettings or {
    point = "CENTER",
    xOfs = 0,
    yOfs = 0,
    locked = false,
    hidden = false,
    scale = 0.75
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

-- Update visibility based on settings
local function UpdateFrameVisibility()
    if DistanceDisplaySettings.hidden then
        distanceDisplayFrame:Hide()
    else
        distanceDisplayFrame:Show()
    end
end

-- Update frame scale
local function UpdateFrameScale(scale)
    distanceDisplayFrame:SetScale(scale)
end

-- Event handling for distance updates
local function UpdateDistance()
    local target = "target"
    if UnitExists(target) then
        local distance = UnitXP("distanceBetween", "player", target)
        if distance then
            if distance > 30 then
                distanceText:SetTextColor(1, 0, 0) -- Red text
            else
                distanceText:SetTextColor(0, 1, 0) -- Green text
            end
            distanceText:SetText(string.format("%.2f yds", distance))
        else
            distanceText:SetText("--")
        end
    else
        distanceText:SetText("--")
    end
end

-- Slash command handler
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
    else
        local scale = tonumber(input)
        if scale and scale >= 0.1 and scale <= 1.0 then
            DistanceDisplaySettings.scale = scale
            UpdateFrameScale(scale)
            print("Distance Display: Frame scale set to " .. (scale * 100) .. "%.")
        else
            print("Distance Display Commands:")
            print("  lock - Lock the frame.")
            print("  unlock - Unlock the frame.")
            print("  hide - Hide the frame.")
            print("  show - Show the frame.")
            print("  <scale> - Set scale (0.1 to 1.0). For example, /dd 0.5")
        end
    end
end


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

-- Register events for real-time updates
local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function()
    UpdateDistance()
end)
updateFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

-- Addon loaded message
print("Distance Display: Type /distdisplay for commands.")
