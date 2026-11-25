--// Glow + Aim Lock for Rivals (Auto ON - Top Right - Team Skip)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local aimEnabled = true
local glowEnabled = true
local aimToggled = true
local aimKey = Enum.KeyCode.E

-- GUI (Top Right)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RivalsGlowAim"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 290, 0, 190)
MainFrame.Position = UDim2.new(1, -310, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "Rivals Glow + Aim Lock"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = TitleBar

-- Glow Toggle
local GlowToggle = Instance.new("TextButton")
GlowToggle.Size = UDim2.new(0.9, 0, 0, 38)
GlowToggle.Position = UDim2.new(0.05, 0, 0.3, 0)
GlowToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
GlowToggle.Text = "Glow: ON"
GlowToggle.TextColor3 = Color3.fromRGB(0, 255, 120)
GlowToggle.TextScaled = true
GlowToggle.Font = Enum.Font.GothamSemibold
GlowToggle.Parent = MainFrame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 10)
GlowCorner.Parent = GlowToggle

-- Aim Toggle
local AimToggle = Instance.new("TextButton")
AimToggle.Size = UDim2.new(0.9, 0, 0, 38)
AimToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
AimToggle.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
AimToggle.Text = "Aim Lock (E Toggle): ON"
AimToggle.TextColor3 = Color3.fromRGB(0, 255, 120)
AimToggle.TextScaled = true
AimToggle.Font = Enum.Font.GothamSemibold
AimToggle.Parent = MainFrame

local AimCorner = Instance.new("UICorner")
AimCorner.CornerRadius = UDim.new(0, 10)
AimCorner.Parent = AimToggle

local highlights = {}

local function isTeammate(plr)
    if plr == LocalPlayer then return true end
    if plr.Team and LocalPlayer.Team and plr.Team == LocalPlayer.Team then
        return true
    end
    return false
end

local function createHighlight(char)
    if highlights[char] then return end
    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(0, 255, 170)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency = 0.35
    highlight.OutlineTransparency = 0
    highlight.Parent = char
    highlights[char] = highlight
end

local function updateGlow()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and player.Character then
            if not highlights[player.Character] then
                createHighlight(player.Character)
            end
        end
    end
end

local function getClosestRootPart()
    local closest = nil
    local shortestDist = math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if distance < shortestDist and distance < 800 then
                        shortestDist = distance
                        closest = root
                    end
                end
            end
        end
    end
    return closest
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    if glowEnabled then
        updateGlow()
    end

    if aimToggled and aimEnabled then
        local targetRoot = getClosestRootPart()
        if targetRoot then
            local targetPos = Camera:WorldToViewportPoint(targetRoot.Position)
            local mousePos = UserInputService:GetMouseLocation()

            local deltaX = (targetPos.X - mousePos.X) * 0.16
            local deltaY = (targetPos.Y - mousePos.Y) * 0.16

            mousemoverel(deltaX, deltaY)
        end
    end
end)

-- Button Toggles
GlowToggle.MouseButton1Click:Connect(function()
    glowEnabled = not glowEnabled
    GlowToggle.Text = "Glow: " .. (glowEnabled and "ON" or "OFF")
    GlowToggle.TextColor3 = glowEnabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
end)

AimToggle.MouseButton1Click:Connect(function()
    aimEnabled = not aimEnabled
    AimToggle.Text = "Aim Lock (E Toggle): " .. (aimEnabled and "ON" or "OFF")
    AimToggle.TextColor3 = aimEnabled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 80, 80)
end)

-- E Toggle for Aimbot
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == aimKey then
        aimToggled = not aimToggled
        print("Aim Lock Toggled: " .. (aimToggled and "ON" or "OFF"))
    end
end)

-- Cleanup
LocalPlayer.CharacterAdded:Connect(function()
    highlights = {}
end)

print("✅ Rivals Glow + Aim Lock loaded (Auto ON - Team Skip)")
print("GUI in top right | Press E to toggle aimbot")
