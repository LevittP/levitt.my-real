-- Break In Story 1 Item GUI
-- Aesthetic: Dark theme with neon accents

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Item list for Break In Story 1
local items = {
    "Apple",
    "Cookie",
    "Lollipop",
    "Pie"
}

-- Create main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BreakInItemGUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

-- Create main frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 450)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add rounded corners to main frame
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = mainFrame

-- Add subtle shadow effect
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.Size = UDim2.new(1, 20, 1, 20)
shadow.Position = UDim2.new(0, -10, 0, -10)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://5028857084"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(24, 24, 276, 276)
shadow.Parent = mainFrame

-- Create header/title bar
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ Break In Item Grabber"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.BackgroundTransparency = 0.3
closeButton.Text = "✕"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold
closeButton.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Minimize button
local minimizeButton = Instance.new("TextButton")
minimizeButton.Name = "MinimizeButton"
minimizeButton.Size = UDim2.new(0, 30, 0, 30)
minimizeButton.Position = UDim2.new(1, -70, 0, 5)
minimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 255)
minimizeButton.BackgroundTransparency = 0.3
minimizeButton.Text = "−"
minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeButton.TextSize = 14
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.Parent = header

local minimizeCorner = Instance.new("UICorner")
minimizeCorner.CornerRadius = UDim.new(0, 8)
minimizeCorner.Parent = minimizeButton

-- Create ScrollFrame for items
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ItemList"
scrollFrame.Size = UDim2.new(1, -20, 1, -150)
scrollFrame.Position = UDim2.new(0, 10, 0, 50)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
scrollFrame.ScrollBarImageTransparency = 0.5
scrollFrame.Parent = mainFrame

-- Create UIListLayout for items
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollFrame

-- Function to create item buttons
local function createItemButton(itemName)
    local button = Instance.new("TextButton")
    button.Name = itemName .. "Button"
    button.Size = UDim2.new(1, -10, 0, 40)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    button.BackgroundTransparency = 0.3
    button.Text = "🎁 " .. itemName
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    button.Font = Enum.Font.Gotham
    button.AutoButtonColor = true
    button.Parent = scrollFrame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = button

    -- Hover effect
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(60, 60, 90),
            BackgroundTransparency = 0.1
        }):Play()
    end)

    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 65),
            BackgroundTransparency = 0.3
        }):Play()
    end)

    -- Give item on click
    button.MouseButton1Click:Connect(function()
        local args = { itemName }
        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("GiveTool"):FireServer(unpack(args))
        
        -- Visual feedback
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        }):Play()
        
        task.wait(0.1)
        TweenService:Create(button, TweenInfo.new(0.1), {
            BackgroundColor3 = Color3.fromRGB(45, 45, 65)
        }):Play()
    end)

    return button
end

-- Create buttons for all items
local buttons = {}
for _, itemName in ipairs(items) do
    buttons[itemName] = createItemButton(itemName)
end

-- Create Gun button
local gunButton = Instance.new("TextButton")
gunButton.Name = "GunButton"
gunButton.Size = UDim2.new(1, -20, 0, 40)
gunButton.Position = UDim2.new(0, 10, 1, -100)
gunButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
gunButton.BackgroundTransparency = 0.2
gunButton.Text = "🔫 Give Gun"
gunButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gunButton.TextSize = 14
gunButton.Font = Enum.Font.GothamBold
gunButton.AutoButtonColor = true
gunButton.Parent = mainFrame

local gunCorner = Instance.new("UICorner")
gunCorner.CornerRadius = UDim.new(0, 8)
gunCorner.Parent = gunButton

-- Hover effect for gun button
gunButton.MouseEnter:Connect(function()
    TweenService:Create(gunButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        BackgroundTransparency = 0.1
    }):Play()
end)

gunButton.MouseLeave:Connect(function()
    TweenService:Create(gunButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        BackgroundTransparency = 0.2
    }):Play()
end)

-- Give gun on click
gunButton.MouseButton1Click:Connect(function()
    local args = { "Gun" }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("GiveTool"):FireServer(unpack(args))
    
    -- Visual feedback
    TweenService:Create(gunButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    }):Play()
    
    task.wait(0.1)
    TweenService:Create(gunButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    }):Play()
end)

-- Create Energy button
local energyButton = Instance.new("TextButton")
energyButton.Name = "EnergyButton"
energyButton.Size = UDim2.new(1, -20, 0, 40)
energyButton.Position = UDim2.new(0, 10, 1, -50)
energyButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
energyButton.BackgroundTransparency = 0.2
energyButton.Text = "⚡ Lose 10 Energy"
energyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
energyButton.TextSize = 14
energyButton.Font = Enum.Font.GothamBold
energyButton.AutoButtonColor = true
energyButton.Parent = mainFrame

local energyCorner = Instance.new("UICorner")
energyCorner.CornerRadius = UDim.new(0, 8)
energyCorner.Parent = energyButton

-- Hover effect for energy button
energyButton.MouseEnter:Connect(function()
    TweenService:Create(energyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 200, 0),
        BackgroundTransparency = 0.1
    }):Play()
end)

energyButton.MouseLeave:Connect(function()
    TweenService:Create(energyButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 170, 0),
        BackgroundTransparency = 0.2
    }):Play()
end)

-- Lose energy on click
energyButton.MouseButton1Click:Connect(function()
    local args = {
        -10
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("Energy"):FireServer(unpack(args))
    
    -- Visual feedback
    TweenService:Create(energyButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(0, 255, 0)
    }):Play()
    
    task.wait(0.1)
    TweenService:Create(energyButton, TweenInfo.new(0.1), {
        BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    }):Play()
end)

-- Update canvas size
local function updateCanvasSize()
    local contentHeight = #items * 45
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
end
updateCanvasSize()

-- Close functionality
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Minimize functionality
local isMinimized = false
minimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 400, 0, 40)
        }):Play()
        scrollFrame.Visible = false
        energyButton.Visible = false
        gunButton.Visible = false
        minimizeButton.Text = "+"
    else
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 400, 0, 450)
        }):Play()
        scrollFrame.Visible = true
        energyButton.Visible = true
        gunButton.Visible = true
        minimizeButton.Text = "−"
    end
end)

-- Dragging functionality
local dragging = false
local dragOffset = Vector2.new(0, 0)

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragOffset = Vector2.new(
            input.Position.X - mainFrame.AbsolutePosition.X,
            input.Position.Y - mainFrame.AbsolutePosition.Y
        )
    end
end)

header.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local newPosition = UDim2.new(
            0, input.Position.X - dragOffset.X,
            0, input.Position.Y - dragOffset.Y
        )
        mainFrame.Position = newPosition
    end
end)

-- Notify user
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "✅ Script Loaded",
    Text = "Break In Item Grabber loaded! Click items to receive them.",
    Duration = 5
})
