-- LevittESPHub V3.0 PREMIUM
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimEnabled = false
local glowEnabled = true
local aimToggled = false
local menuVisible = true

local aimKey = Enum.KeyCode.E
local menuKey = Enum.KeyCode.Tab

local aimStrength = 0.35
local targetPart = "Head"

local glowColor = Color3.fromRGB(255, 255, 255)  -- White glow
local outlineColor = Color3.fromRGB(180, 180, 180) -- Silver outline

local highlights = {}

local autoShootEnabled = true
local shootCooldown = 0.1
local lastShootTime = 0

local blacklistedPlayers = {
    ["MountainLion_01"] = true,
    ["BigB3llyBilly"] = true,
    ["EPICfan100"] = true,
    ["EPIC_GAMER3912"] = true,
    ["Yesvoice"] = true,
    ["timmmmmmmmmytimmmmmy"] = true
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LevittESPHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame with metallic look
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 360)
MainFrame.Position = UDim2.new(1, -340, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

-- Metallic gradient effect
local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(15, 15, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 45))
})
Gradient.Rotation = 90
Gradient.Parent = MainFrame

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Metallic border
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(200, 200, 210)
UIStroke.Thickness = 2
UIStroke.Transparency = 0.1
UIStroke.Parent = MainFrame

-- Inner shadow effect
local InnerGlow = Instance.new("Frame")
InnerGlow.Size = UDim2.new(1, -8, 1, -8)
InnerGlow.Position = UDim2.new(0, 4, 0, 4)
InnerGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
InnerGlow.BackgroundTransparency = 0.95
InnerGlow.BorderSizePixel = 0
InnerGlow.ZIndex = 0
InnerGlow.Parent = MainFrame

local InnerCorner = Instance.new("UICorner")
InnerCorner.CornerRadius = UDim.new(0, 10)
InnerCorner.Parent = InnerGlow

local function createButton(name, text, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.92, 0, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(220, 220, 230)
    button.TextScaled = true
    button.Font = Enum.Font.GothamSemibold
    button.Parent = MainFrame

    -- Metallic button gradient
    local buttonGradient = Instance.new("UIGradient")
    buttonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 50)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 30)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 55))
    })
    buttonGradient.Rotation = 45
    buttonGradient.Parent = button

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    -- Metallic button border
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(150, 150, 160)
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)

    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        button.TextColor3 = Color3.fromRGB(220, 220, 230)
    end)

    return button
end

-- Title Bar with metallic finish
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 70)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 30, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(55, 55, 65))
})
TitleGradient.Rotation = 90
TitleGradient.Parent = TitleBar

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

-- Chrome line under title
local ChromeLine = Instance.new("Frame")
ChromeLine.Size = UDim2.new(1, -20, 0, 2)
ChromeLine.Position = UDim2.new(0, 10, 1, -2)
ChromeLine.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
ChromeLine.BorderSizePixel = 0
ChromeLine.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "LEVITT ESP HUB"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBlack
Title.Parent = TitleBar

-- Premium badge
local VersionBadge = Instance.new("TextLabel")
VersionBadge.Size = UDim2.new(0.25, 0, 0.6, 0)
VersionBadge.Position = UDim2.new(0.73, 0, 0.2, 0)
VersionBadge.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
VersionBadge.Text = "V3.0"
VersionBadge.TextColor3 = Color3.fromRGB(10, 10, 12)
VersionBadge.TextScaled = true
VersionBadge.Font = Enum.Font.GothamBlack
VersionBadge.Parent = TitleBar

local BadgeCorner = Instance.new("UICorner")
BadgeCorner.CornerRadius = UDim.new(0, 6)
BadgeCorner.Parent = VersionBadge

-- Diamond icon (premium touch)
local DiamondIcon = Instance.new("TextLabel")
DiamondIcon.Size = UDim2.new(0, 25, 0, 25)
DiamondIcon.Position = UDim2.new(0, 290, 0, 10)
DiamondIcon.BackgroundTransparency = 1
DiamondIcon.Text = "◆"
DiamondIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
DiamondIcon.TextScaled = true
DiamondIcon.Font = Enum.Font.GothamBlack
DiamondIcon.Parent = MainFrame

local GlowToggle = createButton(
    "GlowToggle",
    "ESP GLOW: ON",
    UDim2.new(0.04, 0, 0, 60)
)

local AimToggle = createButton(
    "AimToggle",
    "AIM LOCK: OFF",
    UDim2.new(0.04, 0, 0, 108)
)

local AutoShootToggle = createButton(
    "AutoShootToggle",
    "AUTO SHOOT: ON",
    UDim2.new(0.04, 0, 0, 156)
)

local TargetToggle = createButton(
    "TargetToggle",
    "TARGET: HEAD",
    UDim2.new(0.04, 0, 0, 204)
)

local StrengthToggle = createButton(
    "StrengthToggle",
    "STRENGTH: MAX",
    UDim2.new(0.04, 0, 0, 252)
)

-- Status bar with metallic look
local StatusBar = Instance.new("Frame")
StatusBar.Size = UDim2.new(0.92, 0, 0, 30)
StatusBar.Position = UDim2.new(0.04, 0, 0, 310)
StatusBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
StatusBar.BorderSizePixel = 0
StatusBar.Parent = MainFrame

local StatusGradient = Instance.new("UIGradient")
StatusGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 45)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 20, 25)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 50))
})
StatusGradient.Rotation = 45
StatusGradient.Parent = StatusBar

local StatusCorner = Instance.new("UICorner")
StatusCorner.CornerRadius = UDim.new(0, 8)
StatusCorner.Parent = StatusBar

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 1, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "◆ LEVITT ESP HUB | E = AIM | TAB = MENU"
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Parent = StatusBar

-- Functionality (unchanged from before)
local function isBlacklisted(player)
    return blacklistedPlayers[player.Name] == true
end

local function isTeammate(player)
    
    if player == LocalPlayer then
        return true
    end
    

    if player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            return true
        end
        

        if player.Team.TeamColor and LocalPlayer.Team.TeamColor then
            if player.Team.TeamColor == LocalPlayer.Team.TeamColor then
                return true
            end
        end
    end
    

    if player:IsFriendsWith(LocalPlayer.UserId) then
        return true
    end
    

    local character = player.Character
    if character then

        if character:GetAttribute("Team") then
            local localTeam = LocalPlayer.Character and LocalPlayer.Character:GetAttribute("Team")
            if character:GetAttribute("Team") == localTeam then
                return true
            end
        end
        
 
        local teamTag = character:FindFirstChild("TeamTag") or character:FindFirstChild("TeamName")
        if teamTag then
            local localTag = LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("TeamTag") or LocalPlayer.Character:FindFirstChild("TeamName"))
            if localTag and teamTag.Value == localTag.Value then
                return true
            end
        end
    end
    
 
    if player:GetAttribute("Team") then
        if player:GetAttribute("Team") == LocalPlayer:GetAttribute("Team") then
            return true
        end
    end
    

    if player:FindFirstChild("leaderstats") then
        local leaderstats = player.leaderstats
        local teamStat = leaderstats:FindFirstChild("Team") or leaderstats:FindFirstChild("TeamName")
        if teamStat and LocalPlayer.leaderstats then
            local localTeamStat = LocalPlayer.leaderstats:FindFirstChild("Team") or LocalPlayer.leaderstats:FindFirstChild("TeamName")
            if localTeamStat and teamStat.Value == localTeamStat.Value then
                return true
            end
        end
    end
    

    if character then
        local teamIndicator = character:FindFirstChild("TeamIndicator") or 
                             character:FindFirstChild("TeamColor") or
                             character:FindFirstChild("Team")
        if teamIndicator then
            local localIndicator = LocalPlayer.Character and 
                                 (LocalPlayer.Character:FindFirstChild("TeamIndicator") or 
                                  LocalPlayer.Character:FindFirstChild("TeamColor") or
                                  LocalPlayer.Character:FindFirstChild("Team"))
            if localIndicator and teamIndicator.Value == localIndicator.Value then
                return true
            end
        end
    end
    

    return false
end


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

            if hitPart:IsDescendantOf(targetPart.Parent) then
                return false
            else
                return true
            end
        end
    end
    
    return false
end


local function createHighlight(character)
    if highlights[character] then
        return
    end

    local highlight = Instance.new("Highlight")

    highlight.Name = "LevittESPGlow"
    highlight.FillColor = glowColor
    highlight.OutlineColor = outlineColor

    highlight.FillTransparency = 0.1
    highlight.OutlineTransparency = 0

    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character

    highlights[character] = highlight
end

local function updateGlow()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isBlacklisted(player) then
            if not isTeammate(player) and player.Character then
                createHighlight(player.Character)
            else
                if player.Character and highlights[player.Character] then
                    highlights[player.Character]:Destroy()
                    highlights[player.Character] = nil
                end
            end
        elseif isBlacklisted(player) and player.Character and highlights[player.Character] then

            highlights[player.Character]:Destroy()
            highlights[player.Character] = nil
        end
    end
end


local function cleanupHighlights()
    for character, highlight in pairs(highlights) do
        if not character.Parent then
            highlight:Destroy()
            highlights[character] = nil
        end
    end
end


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
            and not isBlacklisted(player) 
            and player.Character then

            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            local part = getTargetPart(player.Character)

            if humanoid and humanoid.Health > 0 and part then

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


local function autoShoot(targetPart)
    if not autoShootEnabled then
        return
    end
    
    local currentTime = tick()
    if currentTime - lastShootTime < shootCooldown then
        return
    end
    

    if isBehindWall(targetPart) then
        return
    end
    

    local mouse = LocalPlayer:GetMouse()
    if mouse then
        mouse1click()
        lastShootTime = currentTime
    end
end


RunService.RenderStepped:Connect(function()
    if glowEnabled then
        updateGlow()
        cleanupHighlights()
    end

    if aimEnabled and aimToggled then
        local target = getClosestTarget()

        if target then

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
                

                if autoShootEnabled then
                    autoShoot(target)
                end
            end
        end
    end
end)


local function updateButton(button, enabled, text)
    button.Text = text

    button.TextColor3 = enabled
        and Color3.fromRGB(255, 255, 255)
        or Color3.fromRGB(150, 150, 160)
end


GlowToggle.MouseButton1Click:Connect(function()
    glowEnabled = not glowEnabled

    updateButton(
        GlowToggle,
        glowEnabled,
        "ESP GLOW: " .. (glowEnabled and "ON" or "OFF")
    )

    if not glowEnabled then
        for _, highlight in pairs(highlights) do
            highlight:Destroy()
        end

        highlights = {}
    end
end)


AimToggle.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    aimToggled = aimEnabled

    updateButton(
        AimToggle,
        aimEnabled,
        "AIM LOCK: " .. (aimEnabled and "ON" or "OFF")
    )
    
    StatusLabel.Text = aimEnabled 
        and "◆ LEVITT ESP HUB | AIM LOCK ACTIVE" 
        or "◆ LEVITT ESP HUB | AIM LOCK OFF"
end)


AutoShootToggle.MouseButton1Click:Connect(function()
    autoShootEnabled = not autoShootEnabled

    updateButton(
        AutoShootToggle,
        autoShootEnabled,
        "AUTO SHOOT: " .. (autoShootEnabled and "ON" or "OFF")
    )
end)


TargetToggle.MouseButton1Click:Connect(function()
    if targetPart == "Head" then
        targetPart = "Torso"
    else
        targetPart = "Head"
    end

    TargetToggle.Text = "TARGET: " .. string.upper(targetPart)
end)


StrengthToggle.MouseButton1Click:Connect(function()
    if aimStrength == 0.35 then
        aimStrength = 0.50
        StrengthToggle.Text = "STRENGTH: MAX+"
    elseif aimStrength == 0.50 then
        aimStrength = 0.20
        StrengthToggle.Text = "STRENGTH: MED"
    else
        aimStrength = 0.35
        StrengthToggle.Text = "STRENGTH: MAX"
    end
end)


UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == aimKey then
        aimToggled = not aimToggled
        aimEnabled = aimToggled

        StatusLabel.Text = aimToggled
            and "◆ LEVITT ESP HUB | AIM LOCK ACTIVE"
            or "◆ LEVITT ESP HUB | AIM LOCK PAUSED"

        updateButton(
            AimToggle,
            aimEnabled,
            "AIM LOCK: " .. (aimEnabled and "ON" or "OFF")
        )

        print("[LevittESPHub] Aim Lock: " .. (aimToggled and "ON" or "OFF"))
    end
    

    if input.KeyCode == menuKey then
        menuVisible = not menuVisible
        MainFrame.Visible = menuVisible
        print("[LevittESPHub] Menu: " .. (menuVisible and "SHOWN" or "HIDDEN"))
    end
end)


LocalPlayer.CharacterAdded:Connect(function()
    for _, highlight in pairs(highlights) do
        highlight:Destroy()
    end

    highlights = {}
end)

print("==========================================")
print("  ◆ LEVITT ESP HUB V3.0 PREMIUM ◆")
print("  Metallic Black & White Edition")
print("  E = Toggle Aim | Tab = Toggle Menu")
print("==========================================")
