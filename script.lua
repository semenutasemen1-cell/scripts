local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local S = {aura = false, tesp = false}
local AURA_RANGE = 15
local ESP_RANGE = 120

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MyMenu"
gui.ResetOnSpawn = false
gui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 104)
frame.Position = UDim2.new(0, 20, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local function button(text, y, key)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 36)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = text .. ": OFF"
    b.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        b.Text = text .. ": " .. (S[key] and "ON" or "OFF")
        b.BackgroundColor3 = S[key] and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(60, 60, 60)
    end)
end
button("Kill Aura", 10, "aura")
button("Target ESP", 56, "tesp")

-- Поиск ближайшего врага
local function nearest(range)
    local char = lp.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local best, bestDist
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and not (p.Team and p.Team == lp.Team) then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local r = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and r and hum.Health > 0 then
                local d = (r.Position - root.Position).Magnitude
                if d <= range and (not bestDist or d < bestDist) then
                    best, bestDist = p, d
                end
            end
        end
    end
    return best, bestDist
end

-- Оружие
local function getTool()
    local char = lp.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        local bp = lp:FindFirstChildOfClass("Backpack")
        tool = bp and bp:FindFirstChildOfClass("Tool")
        if tool then tool.Parent = char end
    end
    return tool
end

-- Kill Aura
RunService.Heartbeat:Connect(function()
    if not S.aura then return end
    local target = nearest(AURA_RANGE)
    local tool = getTool()
    if not (target and tool) then return end
    tool:Activate()
    local handle = tool:FindFirstChild("Handle")
    local tr = target.Character:FindFirstChild("HumanoidRootPart")
    if handle and tr and firetouchinterest then
        firetouchinterest(handle, tr, 0)
        firetouchinterest(handle, tr, 1)
    end
end)

-- Target ESP
local hl = Instance.new("Highlight")
hl.FillColor = Color3.fromRGB(255, 0, 0)
hl.OutlineColor = Color3.new(1, 1, 1)
hl.Enabled = false
hl.Parent = gui

local bb = Instance.new("BillboardGui")
bb.Size = UDim2.new(0, 160, 0, 40)
bb.StudsOffset = Vector3.new(0, 3.5, 0)
bb.AlwaysOnTop = true
bb.Parent = gui
local lbl = Instance.new("TextLabel", bb)
lbl.Size = UDim2.new(1, 0, 1, 0)
lbl.BackgroundTransparency = 1
lbl.TextColor3 = Color3.new(1, 1, 1)
lbl.TextStrokeTransparency = 0
lbl.TextScaled = true

RunService.RenderStepped:Connect(function()
    if not S.tesp then
        hl.Enabled = false
        bb.Adornee = nil
        return
    end
    local target, dist = nearest(ESP_RANGE)
    if target then
        local hum = target.Character:FindFirstChildOfClass("Humanoid")
        hl.Adornee = target.Character
        hl.Enabled = true
        bb.Adornee = target.Character:FindFirstChild("Head")
        lbl.Text = string.format("%s | %d HP | %dm", target.DisplayName, hum.Health, dist)
    else
        hl.Enabled = false
        bb.Adornee = nil
    end
end)
