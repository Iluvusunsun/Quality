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
local TeleportTab      = Window:Tab({Title = "Teleport",      Icon = "map-pin"})
local MiscTab      = Window:Tab({Title = "Misc",      Icon = "eye"})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

AimlockEnabled = false
FOVEnabled = true
FOVSize = 120
AimPart = "Head"
Smoothness = 0.1
SafeFriends = false
WallCheck = false
FOVMode = "Mouse"

FOVColor = Color3.fromRGB(255,0,0)

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = FOVSize
FOVCircle.Filled = false
FOVCircle.Color = FOVColor

RunService.RenderStepped:Connect(function()

    local pos

    if FOVMode == "Mouse" then
        local mouse = UserInputService:GetMouseLocation()
        pos = Vector2.new(mouse.X,mouse.Y)
    else
        pos = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    end

    FOVCircle.Position = pos
    FOVCircle.Radius = FOVSize
    FOVCircle.Visible = FOVEnabled
    FOVCircle.Color = FOVColor

end)

function IsVisible(part)

    if not WallCheck then
        return true
    end

    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin)

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local ray = workspace:Raycast(origin,direction,params)

    if ray and ray.Instance then
        if ray.Instance:IsDescendantOf(part.Parent) then
            return true
        end
        return false
    end

    return true

end

function GetClosest()

    local closest = nil
    local shortest = FOVSize

    local fovPos

    if FOVMode == "Mouse" then
        local mouse = UserInputService:GetMouseLocation()
        fovPos = Vector2.new(mouse.X,mouse.Y)
    else
        fovPos = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    end

    for _,player in pairs(Players:GetPlayers()) do

        if player ~= LocalPlayer then

            if SafeFriends and player:IsFriendsWith(LocalPlayer.UserId) then
                continue
            end

            local char = player.Character

            if char and char:FindFirstChild(AimPart) then

                local part = char[AimPart]

                if IsVisible(part) then

                    local pos,visible = Camera:WorldToViewportPoint(part.Position)

                    if visible then

                        local dist = (Vector2.new(pos.X,pos.Y) - fovPos).Magnitude

                        if dist < shortest then
                            shortest = dist
                            closest = part
                        end

                    end

                end

            end

        end

    end

    return closest

end

RunService.RenderStepped:Connect(function()

    if AimlockEnabled then

        local target = GetClosest()

        if target then

            local pos = Camera.CFrame.Position
            local look = CFrame.new(pos,target.Position)

            Camera.CFrame = Camera.CFrame:Lerp(look,Smoothness)

        end

    end

end)

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

CombatTab:Toggle({
Title = "Wall Check",
Default = false,
Callback = function(v)
WallCheck = v
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
Title = "FOV Mode",
Values = {"Mouse","Center"},
Default = "Mouse",
Multi = false,
Callback = function(v)
FOVMode = v
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

while true do
FOVColor = Color3.fromHSV(tick()%5/5,1,1)
task.wait()
end

end)

end

end
})

CombatTab:Keybind({
Title = "Aimlock Keybind",
Flag = "aimlock_key",
Value = "G",
Callback = function()
AimlockEnabled = not AimlockEnabled
end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local NameESPEnabled = false

local Names = {}

function CreateName(player)

    local name = Drawing.new("Text")
    name.Visible = false
    name.Color = Color3.fromRGB(255,255,255)
    name.Size = 12
    name.Center = true
    name.Outline = true
    name.Font = 2

    Names[player] = name
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateName(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateName(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if Names[p] then
        Names[p]:Remove()
        Names[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()

    if not NameESPEnabled then
        for _,n in pairs(Names) do
            n.Visible = false
        end
        return
    end

    for player,name in pairs(Names) do

        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if head and hum and hum.Health > 0 then

            local pos, visible = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))

            if visible then
                name.Text = player.Name
                name.Position = Vector2.new(pos.X,pos.Y)
                name.Visible = true
            else
                name.Visible = false
            end

        else
            name.Visible = false
        end
    end
end)

VisualTab:Toggle({
Title = "ESP Name",
Default = false,
Callback = function(v)
NameESPEnabled = v
end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESPEnabled = false
local ESP_COLOR = Color3.fromRGB(0,170,255)

local Boxes = {}

function CreateBox(player)
    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = ESP_COLOR
    box.Thickness = 0.7
    box.Filled = false
    Boxes[player] = box
end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateBox(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateBox(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if Boxes[p] then
        Boxes[p]:Remove()
        Boxes[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()

    if not ESPEnabled then
        for _,box in pairs(Boxes) do
            box.Visible = false
        end
        return
    end

    for player,box in pairs(Boxes) do

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then

            local pos, visible = Camera:WorldToViewportPoint(hrp.Position)

            if visible then

                local scale = (Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0)).Y -
                               Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0)).Y)

                local width = math.abs(scale) * 0.6
                local height = math.abs(scale)

                box.Size = Vector2.new(width,height)
                box.Position = Vector2.new(pos.X - width/2, pos.Y - height/2)
                box.Visible = true

            else
                box.Visible = false
            end
        else
            box.Visible = false
        end
    end
end)

VisualTab:Toggle({
Title = "ESP Box",
Default = false,
Callback = function(v)
ESPEnabled = v
end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local HealthESPEnabled = false

local HealthBars = {}

function CreateHealth(player)

    local bar = Drawing.new("Line")
    bar.Visible = false
    bar.Thickness = 1

    HealthBars[player] = bar

end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateHealth(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateHealth(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if HealthBars[p] then
        HealthBars[p]:Remove()
        HealthBars[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()

    if not HealthESPEnabled then
        for _,bar in pairs(HealthBars) do
            bar.Visible = false
        end
        return
    end

    for player,bar in pairs(HealthBars) do

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then

            local pos, visible = Camera:WorldToViewportPoint(hrp.Position)

            if visible then

                local top = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0,3,0))
                local bottom = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

                local height = math.abs(top.Y - bottom.Y)
                local healthPercent = hum.Health / hum.MaxHealth

                local barHeight = height * healthPercent

                local x = pos.X - (height * 0.35)

                bar.From = Vector2.new(x, bottom.Y)
                bar.To = Vector2.new(x, bottom.Y - barHeight)

                bar.Color = Color3.fromRGB(
                    255 - (255 * healthPercent),
                    255 * healthPercent,
                    0
                )

                bar.Visible = true

            else
                bar.Visible = false
            end
        else
            bar.Visible = false
        end
    end
end)

VisualTab:Toggle({
Title = "ESP Health Bar",
Default = false,
Callback = function(v)
HealthESPEnabled = v
end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local HighlightESPEnabled = false

local Highlights = {}

function AddHighlight(player)

    local function setup(char)

        if char:FindFirstChild("ESPHighlight") then return end

        local hl = Instance.new("Highlight")
        hl.Name = "ESPHighlight"
        hl.FillColor = Color3.fromRGB(0,170,255)
        hl.OutlineColor = Color3.fromRGB(0,170,255)
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Parent = char

        Highlights[player] = hl

    end

    if player.Character then
        setup(player.Character)
    end

    player.CharacterAdded:Connect(setup)

end

function RemoveHighlight(player)

    if Highlights[player] then
        Highlights[player]:Destroy()
        Highlights[player] = nil
    end

end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        AddHighlight(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        AddHighlight(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveHighlight(p)
end)

game:GetService("RunService").RenderStepped:Connect(function()

    for player,hl in pairs(Highlights) do
        hl.Enabled = HighlightESPEnabled
    end

end)

VisualTab:Toggle({
Title = "ESP Highlight",
Default = false,
Callback = function(v)
HighlightESPEnabled = v
end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local DistanceESPEnabled = false

local Distances = {}

function CreateDistance(player)

    local text = Drawing.new("Text")
    text.Visible = false
    text.Color = Color3.fromRGB(255,255,255)
    text.Size = 12
    text.Center = true
    text.Outline = true
    text.Font = 2

    Distances[player] = text

end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateDistance(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateDistance(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if Distances[p] then
        Distances[p]:Remove()
        Distances[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()

    if not DistanceESPEnabled then
        for _,t in pairs(Distances) do
            t.Visible = false
        end
        return
    end

    for player,text in pairs(Distances) do

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then

            local pos, visible = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))

            if visible then

                local distance = (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                distance = math.floor(distance)

                text.Text = distance.."m"
                text.Position = Vector2.new(pos.X,pos.Y)
                text.Visible = true

            else
                text.Visible = false
            end

        else
            text.Visible = false
        end
    end
end)

VisualTab:Toggle({
Title = "ESP Distance",
Default = false,
Callback = function(v)
DistanceESPEnabled = v
end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local TracerEnabled = false

local Tracers = {}

function CreateTracer(player)

    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(0,170,255)
    line.Thickness = 1
    line.Transparency = 1

    Tracers[player] = line

end

for _,p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        CreateTracer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        CreateTracer(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if Tracers[p] then
        Tracers[p]:Remove()
        Tracers[p] = nil
    end
end)

RunService.RenderStepped:Connect(function()

    if not TracerEnabled then
        for _,line in pairs(Tracers) do
            line.Visible = false
        end
        return
    end

    for player,line in pairs(Tracers) do

        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if hrp and hum and hum.Health > 0 then

            local pos, visible = Camera:WorldToViewportPoint(hrp.Position)

            if visible then

                local screenCenterX = Camera.ViewportSize.X / 2

                line.From = Vector2.new(screenCenterX, 0)
                line.To = Vector2.new(pos.X, pos.Y)

                line.Visible = true

            else
                line.Visible = false
            end

        else
            line.Visible = false
        end
    end
end)

VisualTab:Toggle({
Title = "ESP Tracer",
Default = false,
Callback = function(v)
TracerEnabled = v
end
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local SpeedEnabled = false
local SpeedPower = 2

RunService.RenderStepped:Connect(function()

if SpeedEnabled then

local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")
local hum = char and char:FindFirstChildOfClass("Humanoid")

if hrp and hum then
hrp.Velocity = hum.MoveDirection * (SpeedPower * 20)
end

end
end)

ExploitTab:Toggle({
Title = "Speed Boost",
Default = false,
Callback = function(v)
SpeedEnabled = v
end
})

ExploitTab:Slider({
Title = "Speed Power",
Flag = "speed_power",
Step = 1,
Value = {
Min = 1,
Max = 10,
Default = 2
},
Callback = function(v)
SpeedPower = v
end
})

ExploitTab:Keybind({
Title = "Speed Keybind",
Flag = "speed_key",
Value = "H",
Callback = function()
SpeedEnabled = not SpeedEnabled
end
})

local JumpEnabled = false
local JumpPower = 60

UIS.JumpRequest:Connect(function()

if JumpEnabled then

local char = LocalPlayer.Character
local hrp = char and char:FindFirstChild("HumanoidRootPart")

if hrp then
hrp.Velocity = Vector3.new(hrp.Velocity.X, JumpPower, hrp.Velocity.Z)
end

end
end)

ExploitTab:Toggle({
Title = "High Jump",
Default = false,
Callback = function(v)
JumpEnabled = v
end
})

ExploitTab:Slider({
Title = "Jump Power",
Flag = "jump_power",
Step = 5,
Value = {
Min = 50,
Max = 200,
Default = 60
},
Callback = function(v)
JumpPower = v
end
})

ExploitTab:Keybind({
Title = "Jump Keybind",
Flag = "jump_key",
Value = "J",
Callback = function()
JumpEnabled = not JumpEnabled
end
})

local NoclipEnabled = false

RunService.Stepped:Connect(function()

if NoclipEnabled then

local char = LocalPlayer.Character

if char then
for _,v in pairs(char:GetDescendants()) do
if v:IsA("BasePart") then
v.CanCollide = false
end
end
end

end
end)

ExploitTab:Toggle({
Title = "noclip",
Default = false,
Callback = function(v)
NoclipEnabled = v
end
})

ExploitTab:Keybind({
Title = "Noclip Keybind",
Flag = "noclip_key",
Value = "K",
Callback = function()
NoclipEnabled = not NoclipEnabled
end
})

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local SelectedPlayer = nil
local SavedName = ""
local SavedPositions = {}
local SelectedPosition = nil
local TweenSpeed = 1.5

-- PLAYER LIST
local PlayerList = {}

for _,p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
table.insert(PlayerList,p.Name)
end
end

-- SELECT PLAYER
TeleportTab:Dropdown({
Title = "Select Player",
Values = PlayerList,
Default = nil,
Multi = false,
Callback = function(v)
SelectedPlayer = v
end
})

-- TP TO PLAYER
TeleportTab:Button({
Title = "TP To Player",
Callback = function()

local target = Players:FindFirstChild(SelectedPlayer)

if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

LocalPlayer.Character.HumanoidRootPart.CFrame =
target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)

end

end
})

-- TWEEN TO PLAYER
TeleportTab:Button({
Title = "Tween To Player",
Callback = function()

local target = Players:FindFirstChild(SelectedPlayer)

if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then

local hrp = LocalPlayer.Character.HumanoidRootPart
local targetPos = target.Character.HumanoidRootPart.CFrame

local tween = TweenService:Create(
hrp,
TweenInfo.new(TweenSpeed),
{CFrame = targetPos}
)

tween:Play()

end

end
})

-- TWEEN SPEED
TeleportTab:Slider({
Title = "Tween Speed",
Flag = "tween_speed",
Step = 0.1,
Value = {
Min = 0.1,
Max = 500,
Default = 1.5
},
Callback = function(v)
TweenSpeed = v
end
})

-- INPUT POSITION NAME
TeleportTab:Input({
Title = "Position Name",
Placeholder = "Enter location name",
Callback = function(Value)
SavedName = Value
end
})

-- SAVE POSITION
TeleportTab:Button({
Title = "Save Position",
Callback = function()

if SavedName ~= "" then

local hrp = LocalPlayer.Character.HumanoidRootPart
SavedPositions[SavedName] = hrp.CFrame

end

end
})

-- SAVED POSITION LIST
TeleportTab:Dropdown({
Title = "Saved Positions",
Values = {},
Default = nil,
Multi = false,
Callback = function(v)
SelectedPosition = v
end
})

-- TP TO SAVED
TeleportTab:Button({
Title = "TP To Saved",
Callback = function()

if SelectedPosition and SavedPositions[SelectedPosition] then

LocalPlayer.Character.HumanoidRootPart.CFrame =
SavedPositions[SelectedPosition]

end

end
})

-- TWEEN TO SAVED
TeleportTab:Button({
Title = "Tween To Saved",
Callback = function()

if SelectedPosition and SavedPositions[SelectedPosition] then

local hrp = LocalPlayer.Character.HumanoidRootPart

local tween = TweenService:Create(
hrp,
TweenInfo.new(TweenSpeed),
{CFrame = SavedPositions[SelectedPosition]}
)

tween:Play()

end

end
})

local ChatMessage = ""
local SpamAmount = 1

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

-- INPUT MESSAGE
MiscTab:Input({
Title = "Chat Message",
Placeholder = "Enter message to spam...",
Callback = function(Value)
ChatMessage = Value
end
})

-- INPUT AMOUNT
MiscTab:Input({
Title = "Spam Amount",
Placeholder = "How many messages...",
Callback = function(Value)
SpamAmount = tonumber(Value) or 1
end
})

-- BUTTON START SPAM
MiscTab:Button({
Title = "Start Chat Spam",
Callback = function()

for i = 1, SpamAmount do

ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(
ChatMessage,
"All"
)

task.wait(0.3)

end

end
})

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local SpectateEnabled = false
local SelectedPlayer = nil

-- PLAYER LIST
local PlayerList = {}

for _,p in pairs(Players:GetPlayers()) do
if p ~= LocalPlayer then
table.insert(PlayerList,p.Name)
end
end

-- DROPDOWN
MiscTab:Dropdown({
Title = "Select Player",
Values = PlayerList,
Default = nil,
Multi = false,
Callback = function(v)
SelectedPlayer = v
end
})

-- SPECTATE TOGGLE
MiscTab:Toggle({
Title = "Spectate Player",
Default = false,
Callback = function(v)

SpectateEnabled = v

if SpectateEnabled then

local target = Players:FindFirstChild(SelectedPlayer)

if target and target.Character and target.Character:FindFirstChild("Humanoid") then
Camera.CameraSubject = target.Character.Humanoid
end

else

if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
Camera.CameraSubject = LocalPlayer.Character.Humanoid
end

end

end
})

local FPSBoostEnabled = false

MiscTab:Toggle({
Title = "FPS Boost",
Default = false,
Callback = function(v)

FPSBoostEnabled = v

if FPSBoostEnabled then

for _,v in pairs(game:GetDescendants()) do

if v:IsA("BasePart") then
v.Material = Enum.Material.Plastic
v.Reflectance = 0
end

if v:IsA("Decal") or v:IsA("Texture") then
v.Transparency = 1
end

if v:IsA("ParticleEmitter") or v:IsA("Trail") then
v.Enabled = false
end

end

game:GetService("Lighting").GlobalShadows = false
game:GetService("Lighting").FogEnd = 9e9

else

game:GetService("Lighting").GlobalShadows = true

end

end
})

local Lighting = game:GetService("Lighting")
local RTXEnabled = false

MiscTab:Toggle({
Title = "RTX ON",
Default = false,
Callback = function(v)

RTXEnabled = v

if RTXEnabled then

Lighting.Brightness = 3
Lighting.GlobalShadows = true
Lighting.EnvironmentDiffuseScale = 1
Lighting.EnvironmentSpecularScale = 1
Lighting.Ambient = Color3.fromRGB(70,70,70)
Lighting.OutdoorAmbient = Color3.fromRGB(120,120,120)

local bloom = Instance.new("BloomEffect")
bloom.Intensity = 0.4
bloom.Size = 56
bloom.Parent = Lighting

local color = Instance.new("ColorCorrectionEffect")
color.Saturation = 0.2
color.Contrast = 0.1
color.Parent = Lighting

local atmosphere = Instance.new("Atmosphere")
atmosphere.Density = 0.3
atmosphere.Parent = Lighting

else

for _,v in pairs(Lighting:GetChildren()) do
if v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("Atmosphere") then
v:Destroy()
end
end

Lighting.Brightness = 1

end

end
})

local InfiniteJumpEnabled = false
local UIS = game:GetService("UserInputService")

UIS.JumpRequest:Connect(function()

if InfiniteJumpEnabled then

local char = game.Players.LocalPlayer.Character
local hum = char and char:FindFirstChildOfClass("Humanoid")

if hum then
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end

end

end)

ExploitTab:Toggle({
Title = "Infinite Jump",
Default = false,
Callback = function(v)
InfiniteJumpEnabled = v
end
})

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

MiscTab:Button({
Title = "Server Hop (high player)",
Callback = function()

local placeId = game.PlaceId
local servers = HttpService:JSONDecode(game:HttpGet(
"https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Desc&limit=100"
))

for _,server in pairs(servers.data) do
if server.playing >= server.maxPlayers - 2 then

TeleportService:TeleportToPlaceInstance(
placeId,
server.id,
Players.LocalPlayer
)

break
end
end

end
})

local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

MiscTab:Button({
Title = "Server Hop (Low Players)",
Callback = function()

local placeId = game.PlaceId
local servers = HttpService:JSONDecode(game:HttpGet(
"https://games.roblox.com/v1/games/"..placeId.."/servers/Public?sortOrder=Asc&limit=100"
))

for _,server in pairs(servers.data) do
if server.playing <= 3 then

TeleportService:TeleportToPlaceInstance(
placeId,
server.id,
Players.LocalPlayer
)

break
end
end

end
})
