--// Rivals Glow + Aim Lock V2 - Enhanced
--// Auto ON - Top Right - Team Skip
--// Head/Torso Selector - Strong Aim - Strong Glow
--// Auto Aim OFF by default - Auto Shoot with wall detection

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- SETTINGS
local aimEnabled = false -- Auto OFF now
local glowEnabled = true
local aimToggled = false -- Auto OFF

local aimKey = Enum.KeyCode.E

local aimStrength = 0.35
local targetPart = "Head"

local glowColor = Color3.fromRGB(0, 255, 170)
local outlineColor = Color3.fromRGB(0, 200, 255)

local highlights = {}

-- Auto Shoot Settings
local autoShootEnabled = true
local shootCooldown = 0.1
local lastShootTime = 0

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsGlowAim"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 330)
MainFrame.Position = UDim2.new(1, -310, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local function createButton(name, text, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 38)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(0, 255, 120)
    button.TextScaled = true
    button.Font = Enum.Font.GothamSemibold
    button.Parent = MainFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    return button
end

-- TITLE
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Rivals Glow + Aim Lock V2"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- BUTTONS
local GlowToggle = createButton(
    "GlowToggle",
    "Glow: ON",
    UDim2.new(0.05, 0, 0, 55)
)

local AimToggle = createButton(
    "AimToggle",
    "Aim Lock: OFF",
    UDim2.new(0.05, 0, 0, 100)
)

local AutoShootToggle = createButton(
    "AutoShootToggle",
    "Auto Shoot: ON",
    UDim2.new(0.05, 0, 0, 145)
)

local TargetToggle = createButton(
    "TargetToggle",
    "Target Part: HEAD",
    UDim2.new(0.05, 0, 0, 190)
)

local StrengthToggle = createButton(
    "StrengthToggle",
    "Aim Strength: MAX",
    UDim2.new(0.05, 0, 0, 235)
)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0, 290)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "E = Toggle Aim | Aim OFF"
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = MainFrame

-- TEAM CHECK
local function isTeammate(player)
    if player == LocalPlayer then
        return true
    end

    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end

    -- Check for friend status
    if player:IsFriendsWith(LocalPlayer.UserId) then
        return true
    end

    return false
end

-- WALL DETECTION
local function isBehindWall(targetPart)
    if not targetPart then
        return true
    end
    
    local origin = Camera.CFrame.Position
    local target = targetPart.Position
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    
    local raycastResult = workspace:Raycast(origin, (target - origin).Unit * (origin - target).Magnitude, raycastParams)
    
    if raycastResult then
        local hitPart = raycastResult.Instance
        if hitPart then
            -- Check if we hit the target or something close to it
            if hitPart:IsDescendantOf(targetPart.Parent) then
                return false -- Not behind wall
            else
                return true -- Behind wall
            end
        end
    end
    
    return false
end

-- STRONG GLOW
local function createHighlight(character)
    if highlights[character] then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "RivalsEnemyGlow"
    highlight.FillColor = glowColor
    highlight.OutlineColor = outlineColor

    highlight.FillTransparency = 0.05
    highlight.OutlineTransparency = 0

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    highlights[character] = highlight
end

local function updateGlow()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if not isTeammate(player) and player.Character then
                createHighlight(player.Character)
            else
                if player.Character and highlights[player.Character] then
                    highlights[player.Character]:Destroy()
                    highlights[player.Character] = nil
                end
            end
        end
    end
end

-- REMOVE OLD HIGHLIGHTS
local function cleanupHighlights()
    for character, highlight in pairs(highlights) do
        if not character.Parent then
            highlight:Destroy()
            highlights[character] = nil
        end
    end
end

-- TARGET FINDER
local function getTargetPart(character)
    if targetPart == "Head" then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("UpperTorso")
            or character:FindFirstChild("Torso")
            or character:FindFirstChild("HumanoidRootPart")
    end
end

local function getClosestTarget()
    local closest = nil
    local shortestDistance = math.huge

    local mousePosition = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
            and not isTeammate(player)
            and player.Character then

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = getTargetPart(player.Character)

            if humanoid and humanoid.Health > 0 and part then
                -- Skip if behind wall for shooting
                if autoShootEnabled and isBehindWall(part) then
                    continue
                end
                
                local screenPosition, onScreen =
                    Camera:WorldToViewportPoint(part.Position)

                if onScreen then
                    local distance = (
                        Vector2.new(screenPosition.X, screenPosition.Y)
                        - mousePosition
                    ).Magnitude

                    if distance < shortestDistance and distance < 800 then
                        shortestDistance = distance
                        closest = part
                    end
                end
            end
        end
    end

    return closest
end

-- AUTO SHOOT FUNCTION
local function autoShoot(targetPart)
    if not autoShootEnabled then
        return
    end
    
    local currentTime = tick()
    if currentTime - lastShootTime < shootCooldown then
        return
    end
    
    -- Check if target is not behind wall
    if isBehindWall(targetPart) then
        return
    end
    
    -- Simulate click
    local mouse = LocalPlayer:GetMouse()
    if mouse then
        mouse1click() -- Simulate left click to shoot
        lastShootTime = currentTime
    end
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    if glowEnabled then
        updateGlow()
        cleanupHighlights()
    end

    if aimEnabled and aimToggled then
        local target = getClosestTarget()

        if target then
            -- Check if target is not behind wall
            if not isBehindWall(target) then
                local screenPosition =
                    Camera:WorldToViewportPoint(target.Position)

                local mousePosition =
                    UserInputService:GetMouseLocation()

                local deltaX =
                    (screenPosition.X - mousePosition.X) * aimStrength

                local deltaY =
                    (screenPosition.Y - mousePosition.Y) * aimStrength

                if mousemoverel then
                    mousemoverel(deltaX, deltaY)
                end
                
                -- Auto shoot if enabled and target visible
                if autoShootEnabled then
                    autoShoot(target)
                end
            end
        end
    end
end)

-- BUTTON COLORS
local function updateButton(button, enabled, text)
    button.Text = text

    button.TextColor3 = enabled
        and Color3.fromRGB(0, 255, 120)
        or Color3.fromRGB(255, 80, 80)
end

-- GLOW BUTTON
GlowToggle.MouseButton1Click:Connect(function()
    glowEnabled = not glowEnabled

    updateButton(
        GlowToggle,
        glowEnabled,
        "Glow: " .. (glowEnabled and "ON" or "OFF")
    )

    if not glowEnabled then
        for _, highlight in pairs(highlights) do
            highlight:Destroy()
        end

        highlights = {}
    end
end)

-- AIM BUTTON
AimToggle.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimToggled = aimEnabled -- Sync with toggle

    updateButton(
        AimToggle,
        aimEnabled,
        "Aim Lock: " .. (aimEnabled and "ON" or "OFF")
    )
    
    StatusLabel.Text = aimEnabled 
        and "Aim Lock ACTIVE | E to toggle" 
        or "Aim Lock OFF | E to toggle"
end)

-- AUTO SHOOT BUTTON
AutoShootToggle.MouseButton1Click:Connect(function()
    autoShootEnabled = not autoShootEnabled

    updateButton(
        AutoShootToggle,
        autoShootEnabled,
        "Auto Shoot: " .. (autoShootEnabled and "ON" or "OFF")
    )
end)

-- HEAD / TORSO SWITCH
TargetToggle.MouseButton1Click:Connect(function()
    if targetPart == "Head" then
        targetPart = "Torso"
    else
        targetPart = "Head"
    end

    TargetToggle.Text = "Target Part: " .. string.upper(targetPart)
end)

-- AIM STRENGTH
StrengthToggle.MouseButton1Click:Connect(function()
    if aimStrength == 0.35 then
        aimStrength = 0.50
        StrengthToggle.Text = "Aim Strength: MAX+"
    elseif aimStrength == 0.50 then
        aimStrength = 0.20
        StrengthToggle.Text = "Aim Strength: MED"
    else
        aimStrength = 0.35
        StrengthToggle.Text = "Aim Strength: MAX"
    end
end)

-- E KEY TOGGLE
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == aimKey then
        aimToggled = not aimToggled
        aimEnabled = aimToggled -- Sync

        StatusLabel.Text = aimToggled
            and "Aim Lock ACTIVE"
            or "Aim Lock PAUSED"

        updateButton(
            AimToggle,
            aimEnabled,
            "Aim Lock: " .. (aimEnabled and "ON" or "OFF")
        )

        print("Aim Lock: " .. (aimToggled and "ON" or "OFF"))
    end
end)

-- RESPAWN CLEANUP
LocalPlayer.CharacterAdded:Connect(function()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end

    highlights = {}
end)

print("Rivals Glow + Aim Lock V2 Enhanced loaded!")
print("Default Target: HEAD")
print("Default Aim Strength: MAX")
print("Default Glow: STRONG")
print("Aim Lock: OFF (Press E to enable)")
print("Auto Shoot: ON (with wall detection)")
