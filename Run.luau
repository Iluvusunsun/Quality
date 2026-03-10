local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Quality x Hub | All function (เรื้อนเต็มระบบ)",
    Icon = "rbxassetid://138614699274576",
    Author = "Quality.Team",
    Folder = "Mybabeee",
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Name = LocalPlayer.Name,
        Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId,
        Callback = function() end,
    },
})

Window:EditOpenButton({ Enabled = false })

local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("ImageButton")

ScreenGui.Name = "WindUI_Toggle"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
ToggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
ToggleBtn.BackgroundTransparency = 1
ToggleBtn.Image = "rbxassetid://138614699274576" 
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui

local opened = true

local function toggle()
    opened = not opened
    if Window.UI then
        Window.UI.Enabled = opened
    else
        Window:Toggle()
    end
end

ToggleBtn.MouseButton1Click:Connect(function()
    ToggleBtn:TweenSize(
        UDim2.new(0, 56, 0, 56),
        Enum.EasingDirection.Out,
        Enum.EasingStyle.Quad,
        0.12,
        true,
        function()
            ToggleBtn:TweenSize(
                UDim2.new(0, 50, 0, 50),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Quad,
                0.12,
                true
            )
        end
    )
    toggle()
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.T then
        toggle()
    end
end)


if not LocalPlayer.Character then
LocalPlayer.CharacterAdded:Wait()
end


local CombatTab   = Window:Tab({Title = "Combat",   Icon = "crosshair"})
local VisualTab   = Window:Tab({Title = "Visual",   Icon = "user"})
local ExploitTab = Window:Tab({Title = "Exploit", Icon = "map-pin"})
local MiscTab      = Window:Tab({Title = "Misc",      Icon = "eye"})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SETTINGS
AimlockEnabled = false
FOVEnabled = true
FOVSize = 120
AimPart = "Head"
Smoothness = 0.1
SafeFriends = false
FOVColor = Color3.fromRGB(255,0,0)

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOVSize
FOVCircle.Filled = false
FOVCircle.Color = FOVColor

RunService.RenderStepped:Connect(function()
    local mousePos = UserInputService:GetMouseLocation()
    FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)

    FOVCircle.Radius = FOVSize
    FOVCircle.Visible = FOVEnabled
    FOVCircle.Color = FOVColor
end)

-- GET TARGET
function GetClosest()
    local closest = nil
    local shortest = FOVSize

    for _,player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if SafeFriends and player:IsFriendsWith(LocalPlayer.UserId) then
                continue
            end

            local char = player.Character
            if char and char:FindFirstChild(AimPart) then
                local pos, visible = Camera:WorldToViewportPoint(char[AimPart].Position)
                if visible then
                    local dist = (Vector2.new(pos.X,pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = char[AimPart]
                    end
                end
            end
        end
    end

    return closest
end

-- AIMLOCK
RunService.RenderStepped:Connect(function()
    if AimlockEnabled then
        local target = GetClosest()
        if target then
            local pos = Camera.CFrame.Position
            local look = CFrame.new(pos, target.Position)
            Camera.CFrame = Camera.CFrame:Lerp(look, Smoothness)
        end
    end
end)

-- KEYBINDS
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.Q then
        AimlockEnabled = not AimlockEnabled
    end

    if input.KeyCode == Enum.KeyCode.E then
        FOVEnabled = not FOVEnabled
    end
end)

------------------------------------------------------------------
-- UI (ตามรูปแบบที่คุณให้มา)
------------------------------------------------------------------

CombatTab:Toggle({
Title = "Enable Aimlock",
Default = false,
Callback = function(v)
AimlockEnabled = v
end
})

CombatTab:Toggle({
Title = "Show FOV",
Default = true,
Callback = function(v)
FOVEnabled = v
end
})

CombatTab:Toggle({
Title = "Safe Friends",
Default = false,
Callback = function(v)
SafeFriends = v
end
})

CombatTab:Slider({
Title = "FOV Size",
Flag = "fov_size",
Step = 1,
Value = {
Min = 50,
Max = 500,
Default = 120
},
Callback = function(v)
FOVSize = v
end
})

CombatTab:Slider({
Title = "Smoothness",
Flag = "smooth_value",
Step = 0.01,
Value = {
Min = 0.01,
Max = 1,
Default = 0.1
},
Callback = function(v)
Smoothness = v
end
})

CombatTab:Dropdown({
Title = "Aim Part",
Values = {"Head","HumanoidRootPart"},
Default = "Head",
Multi = false,
Callback = function(v)
AimPart = v
end
})

CombatTab:Dropdown({
Title = "FOV Color",
Values = {"Red","Green","White","Blue","Cyan","Purple","RGB"},
Default = "Red",
Multi = false,
Callback = function(v)

if v == "Red" then
FOVColor = Color3.fromRGB(255,0,0)
elseif v == "Green" then
FOVColor = Color3.fromRGB(0,255,0)
elseif v == "White" then
FOVColor = Color3.fromRGB(255,255,255)
elseif v == "Blue" then
FOVColor = Color3.fromRGB(0,0,255)
elseif v == "Cyan" then
FOVColor = Color3.fromRGB(0,255,255)
elseif v == "Purple" then
FOVColor = Color3.fromRGB(170,0,255)
elseif v == "RGB" then

spawn(function()
while FOVColor do
FOVColor = Color3.fromHSV(tick()%5/5,1,1)
task.wait()
end
end)

end

end
})
