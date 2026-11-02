-- FROST BOOST FPS - Roblox Studio LocalScript
-- Place in StarterPlayer > StarterPlayerScripts.
-- Client-side visual/performance settings for your own Roblox experience.
-- Kill-feed styling only affects TextLabels/TextButtons named "KillFeedLabel"
-- or descendants of a GUI named "KillFeed" in this experience.

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COLORS = {
    White = Color3.fromRGB(245, 245, 245),
    Red = Color3.fromRGB(255, 80, 80),
    Blue = Color3.fromRGB(80, 155, 255),
    Green = Color3.fromRGB(80, 225, 135),
    Purple = Color3.fromRGB(190, 110, 255),
    Gold = Color3.fromRGB(255, 205, 70),
    Cyan = Color3.fromRGB(65, 225, 255),
}

local selectedTagColor = COLORS.White
local rainbowTag = false
local rainbowFeed = false
local feedColor = COLORS.White
local aliasText = "FROST"
local feedEnabled = false
local originalFeedText = {}
local running = true

-- Lightweight client-side graphics options.
local originalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Brightness = Lighting.Brightness,
}
local savedEffects = {}

local function optimizeGraphics(enabled)
    if enabled then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100000
        for _, item in ipairs(Workspace:GetDescendants()) do
            if item:IsA("ParticleEmitter") or item:IsA("Trail")
                or item:IsA("Smoke") or item:IsA("Fire")
                or item:IsA("Sparkles") then
                savedEffects[item] = item.Enabled
                item.Enabled = false
            end
        end
    else
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        Lighting.FogEnd = originalLighting.FogEnd
        for item, wasEnabled in pairs(savedEffects) do
            if item and item.Parent then
                pcall(function() item.Enabled = wasEnabled end)
            end
        end
        table.clear(savedEffects)
    end
end

-- Create a local-only nameplate above your own character.
local nameBillboard
local nameText
local function makeNameplate(character)
    if nameBillboard then nameBillboard:Destroy() end
    local head = character:FindFirstChild("Head") or character:WaitForChild("Head", 5)
    if not head then return end

    nameBillboard = Instance.new("BillboardGui")
    nameBillboard.Name = "FrostLocalNameplate"
    nameBillboard.Size = UDim2.fromOffset(180, 34)
    nameBillboard.StudsOffset = Vector3.new(0, 2.6, 0)
    nameBillboard.AlwaysOnTop = true
    nameBillboard.Adornee = head
    nameBillboard.Parent = playerGui

    nameText = Instance.new("TextLabel")
    nameText.Name = "NameText"
    nameText.Size = UDim2.fromScale(1, 1)
    nameText.BackgroundTransparency = 1
    nameText.Text = player.DisplayName
    nameText.TextColor3 = selectedTagColor
    nameText.TextStrokeTransparency = 0.25
    nameText.Font = Enum.Font.GothamBold
    nameText.TextScaled = true
    nameText.Parent = nameBillboard
end

local function setTagColor(color)
    selectedTagColor = color
    rainbowTag = false
    if nameText then nameText.TextColor3 = color end
end

-- Only targets this game's explicitly named kill-feed labels.
local function isKillFeedLabel(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton")) then
        return false
    end
    if obj.Name == "KillFeedLabel" then return true end
    local ancestor = obj.Parent
    while ancestor and ancestor ~= playerGui do
        if ancestor.Name == "KillFeed" then return true end
        ancestor = ancestor.Parent
    end
    return false
end

local function applyFeedStyle()
    for _, obj in ipairs(playerGui:GetDescendants()) do
        if isKillFeedLabel(obj) then
            if originalFeedText[obj] == nil then
                originalFeedText[obj] = obj.Text
            end
            local original = originalFeedText[obj]
            local updated = original
            if aliasText ~= "" then
                for _, other in ipairs(Players:GetPlayers()) do
                    if other ~= player then
                        for _, oldName in ipairs({other.Name, other.DisplayName}) do
                            if oldName and oldName ~= "" then
                                local escaped = oldName:gsub("([^%w])", "%%%1")
                                updated = updated:gsub(escaped, aliasText)
                            end
                        end
                    end
                end
            end
            obj.Text = updated
            if not rainbowFeed then obj.TextColor3 = feedColor end
        end
    end
end

local function restoreFeed()
    for obj, oldText in pairs(originalFeedText) do
        if obj and obj.Parent then
            pcall(function() obj.Text = oldText end)
        end
    end
    table.clear(originalFeedText)
end

-- UI
local gui = Instance.new("ScreenGui")
gui.Name = "FrostBoostStudioUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.Size = UDim2.fromOffset(285, 430)
panel.Position = UDim2.new(0, 18, 0.25, 0)
panel.BackgroundColor3 = Color3.fromRGB(18, 23, 34)
panel.BorderSizePixel = 0
panel.Active = true
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(85, 175, 255)
stroke.Thickness = 1.5
stroke.Parent = panel

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1, -48, 0, 42)
header.Position = UDim2.fromOffset(12, 0)
header.BackgroundTransparency = 1
header.Text = "❄ FROST BOOST FPS"
header.TextColor3 = Color3.fromRGB(220, 240, 255)
header.Font = Enum.Font.GothamBold
header.TextSize = 16
header.TextXAlignment = Enum.TextXAlignment.Left
header.Parent = panel

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 30)
close.Position = UDim2.new(1, -42, 0, 6)
close.Text = "×"
close.TextSize = 22
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(155, 55, 65)
close.Parent = panel
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(10, 48)
scroll.Size = UDim2.new(1, -20, 1, -58)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.CanvasSize = UDim2.fromOffset(0, 700)
scroll.Parent = panel

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 7)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroll

local function makeButton(text, callback, height)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -4, 0, height or 34)
    button.BackgroundColor3 = Color3.fromRGB(35, 48, 68)
    button.TextColor3 = Color3.fromRGB(235, 245, 255)
    button.Font = Enum.Font.GothamSemibold
    button.TextSize = 13
    button.Text = text
    button.AutoButtonColor = true
    button.Parent = scroll
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)
    button.Activated:Connect(function() callback(button) end)
    return button
end

local function makeSection(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -4, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(105, 195, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = scroll
end

local function makeColorButton(label, color, callback)
    local button = makeButton(label, callback, 30)
    button.BackgroundColor3 = color
    button.TextColor3 = Color3.fromRGB(20, 25, 35)
end

makeSection("PERFORMANCE")
local optimizeButton = makeButton("Enable FPS-Friendly Graphics", function()
    optimizeGraphics(true)
end)
makeButton("Restore Graphics", function()
    optimizeGraphics(false)
end)

makeSection("MY LOCAL NAMETAG")
makeButton("Rainbow Nametag: OFF", function(button)
    rainbowTag = not rainbowTag
    button.Text = "Rainbow Nametag: " .. (rainbowTag and "ON" or "OFF")
    if not rainbowTag and nameText then nameText.TextColor3 = selectedTagColor end
end)
for name, color in pairs(COLORS) do
    makeColorButton("Nametag: " .. name, color, function()
        setTagColor(color)
    end)
end

makeSection("KILL FEED — YOUR GAME'S GUI ONLY")
local aliasBox = Instance.new("TextBox")
aliasBox.Size = UDim2.new(1, -4, 0, 34)
aliasBox.BackgroundColor3 = Color3.fromRGB(30, 39, 54)
aliasBox.TextColor3 = Color3.new(1, 1, 1)
aliasBox.PlaceholderText = "Replacement name (e.g. FROST)"
aliasBox.Text = aliasText
aliasBox.ClearTextOnFocus = false
aliasBox.Font = Enum.Font.Gotham
aliasBox.TextSize = 13
aliasBox.Parent = scroll
Instance.new("UICorner", aliasBox).CornerRadius = UDim.new(0, 8)
aliasBox.FocusLost:Connect(function()
    aliasText = aliasBox.Text:sub(1, 24)
    if feedEnabled then applyFeedStyle() end
end)

makeButton("Customize Kill Feed: ON/OFF", function(button)
    feedEnabled = not feedEnabled
    button.Text = "Customize Kill Feed: " .. (feedEnabled and "ON" or "OFF")
    if feedEnabled then applyFeedStyle() else restoreFeed() end
end)
makeButton("Rainbow Kill Feed: ON/OFF", function(button)
    rainbowFeed = not rainbowFeed
    button.Text = "Rainbow Kill Feed: " .. (rainbowFeed and "ON" or "OFF")
    if not rainbowFeed then
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if isKillFeedLabel(obj) then obj.TextColor3 = feedColor end
        end
    end
end)
for _, name in ipairs({"White", "Red", "Blue", "Green", "Purple", "Gold", "Cyan"}) do
    makeColorButton("Feed: " .. name, COLORS[name], function()
        feedColor = COLORS[name]
        rainbowFeed = false
        if feedEnabled then applyFeedStyle() end
    end)
end

-- Drag panel with mouse or touch.
local dragging = false
local dragStart
local startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(46, 46)
reopen.Position = UDim2.new(0, 14, 0.65, 0)
reopen.Text = "❄"
reopen.TextSize = 24
reopen.BackgroundColor3 = Color3.fromRGB(30, 90, 145)
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.Visible = false
reopen.Parent = gui
Instance.new("UICorner", reopen).CornerRadius = UDim.new(1, 0)

close.Activated:Connect(function()
    panel.Visible = false
    reopen.Visible = true
end)
reopen.Activated:Connect(function()
    panel.Visible = true
    reopen.Visible = false
end)

local function onCharacter(character)
    task.wait(0.4)
    makeNameplate(character)
end
if player.Character then task.spawn(onCharacter, player.Character) end
player.CharacterAdded:Connect(onCharacter)

-- Animate rainbow effects and refresh supported feed labels as they appear.
local heartbeatConn = RunService.RenderStepped:Connect(function(dt)
    if rainbowTag and nameText and nameText.Parent then
        nameText.TextColor3 = Color3.fromHSV((os.clock() * 0.22) % 1, 1, 1)
    end
    if rainbowFeed and feedEnabled then
        local color = Color3.fromHSV((os.clock() * 0.22) % 1, 1, 1)
        for _, obj in ipairs(playerGui:GetDescendants()) do
            if isKillFeedLabel(obj) then obj.TextColor3 = color end
        end
    end
end)

local descendantConn = playerGui.DescendantAdded:Connect(function(obj)
    if feedEnabled then
        task.defer(function()
            if obj.Parent and isKillFeedLabel(obj) then applyFeedStyle() end
        end)
    end
end)

script.Destroying:Connect(function()
    running = false
    heartbeatConn:Disconnect()
    descendantConn:Disconnect()
    optimizeGraphics(false)
    restoreFeed()
    if nameBillboard then nameBillboard:Destroy() end
    gui:Destroy()
end)
