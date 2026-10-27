local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- ===== НАСТРОЙКИ =====
local S = {
    aura = false, tesp = false, esp = false, remlog = false,
    espFill = true, espName = true, espHP = true, espDist = true,
    teamCheck = true,
    auraRange = 30, espRange = 300,
}
local COLORS = {
    Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 170, 255), Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(255, 0, 255), Color3.new(1, 1, 1),
}
local colorIdx = 1

-- Если найдёшь Remote удара, впиши его сюда, например:
-- local HIT_REMOTE = game.ReplicatedStorage.Remotes.Hit
local HIT_REMOTE = nil
local function hitArgs(target) return {target.Character} end

-- ===== GUI =====
local root = (gethui and gethui()) or game:GetService("CoreGui")
local prev = root:FindFirstChild("MyMenu")
if prev then prev:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MyMenu"
gui.ResetOnSpawn = false
gui.Parent = root

local ON, OFF = Color3.fromRGB(0, 140, 70), Color3.fromRGB(60, 60, 60)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 200, 0, 280)
frame.Position = UDim2.new(0, 10, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, -40, 0, 30)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Menu"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left

local list = Instance.new("ScrollingFrame", frame)
list.Size = UDim2.new(1, -16, 1, -38)
list.Position = UDim2.new(0, 8, 0, 34)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.CanvasSize = UDim2.new(0, 0, 0, 0)
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local mini = Instance.new("TextButton", frame)
mini.Size = UDim2.new(0, 26, 0, 24)
mini.Position = UDim2.new(1, -32, 0, 4)
mini.Text = "-"
mini.TextColor3 = Color3.new(1, 1, 1)
mini.BackgroundColor3 = OFF
mini.Font = Enum.Font.GothamBold
Instance.new("UICorner", mini)
local minimized = false
mini.MouseButton1Click:Connect(function()
    minimized = not minimized
    list.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 200, 0, 32) or UDim2.new(0, 200, 0, 280)
    mini.Text = minimized and "+" or "-"
end)

local order = 0
local function place(obj)
    order += 1
    obj.LayoutOrder = order
    obj.Parent = list
end

local function newBtn(text)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = OFF
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextSize = 14
    b.Font = Enum.Font.GothamBold
    b.Text = text
    Instance.new("UICorner", b)
    place(b)
    return b
end

local function section(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 18)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(160, 160, 160)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    place(l)
end

local function toggle(text, key, onChange)
    local b = newBtn("")
    local function refresh()
        b.Text = text .. ": " .. (S[key] and "ON" or "OFF")
        b.BackgroundColor3 = S[key] and ON or OFF
    end
    refresh()
    b.MouseButton1Click:Connect(function()
        S[key] = not S[key]
        refresh()
        if onChange then onChange(S[key]) end
    end)
end

local function stepper(text, key, step, min, max)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 32)
    row.BackgroundTransparency = 1
    place(row)
    local function mk(txt, x, anchor)
        local b = Instance.new("TextButton", row)
        b.Size = UDim2.new(0, 36, 1, 0)
        b.Position = UDim2.new(x, 0, 0, 0)
        b.AnchorPoint = Vector2.new(anchor, 0)
        b.Text = txt
        b.BackgroundColor3 = OFF
        b.TextColor3 = Color3.new(1, 1, 1)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 18
        Instance.new("UICorner", b)
        return b
    end
    local minus, plus = mk("-", 0, 0), mk("+", 1, 1)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 40, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    local function refresh() lbl.Text = text .. ": " .. S[key] end
    refresh()
    minus.MouseButton1Click:Connect(function() S[key] = math.max(min, S[key] - step); refresh() end)
    plus.MouseButton1Click:Connect(function() S[key] = math.min(max, S[key] + step); refresh() end)
end

-- ===== ПОИСК ВРАГОВ =====
local function alive(p)
    local c = p.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    if h and r and h.Health > 0 then return c, h, r end
end

local function isEnemy(p)
    if p == lp then return false end
    if S.teamCheck and p.Team and p.Team == lp.Team then return false end
    return true
end

local function nearest(range)
    local mc = lp.Character
    local mr = mc and mc:FindFirstChild("HumanoidRootPart")
    if not mr then return end
    local best, bestD
    for _, p in ipairs(Players:GetPlayers()) do
        if isEnemy(p) then
            local c, _, r = alive(p)
            if c then
                local d = (r.Position - mr.Position).Magnitude
                if d <= range and (not bestD or d < bestD) then best, bestD = p, d end
            end
        end
    end
    return best, bestD
end

-- ===== KILL AURA =====
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

RunService.Heartbeat:Connect(function()
    if not S.aura then return end
    local target = nearest(S.auraRange)
    if not target then return end
    local _, _, tr = alive(target)
    local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not (tr and myRoot) then return end

    -- встаём вплотную позади врага, лицом к нему
    local pos = (tr.CFrame * CFrame.new(0, 0, 3)).Position
    myRoot.CFrame = CFrame.lookAt(pos, tr.Position)

    if HIT_REMOTE then
        pcall(function() HIT_REMOTE:FireServer(unpack(hitArgs(target))) end)
    end

    local tool = getTool()
    if tool then
        tool:Activate()
        local handle = tool:FindFirstChild("Handle")
        if handle and firetouchinterest then
            firetouchinterest(handle, tr, 0)
            firetouchinterest(handle, tr, 1)
        end
    end
end)

-- ===== ОБЫЧНЫЙ ESP =====
local esp = {}

local function getEsp(p)
    if esp[p] then return esp[p] end
    local hl = Instance.new("Highlight")
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.Parent = gui
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 160, 0, 20)
    bb.StudsOffset = Vector3.new(0, -3.5, 0)
    bb.AlwaysOnTop = true
    bb.Parent = gui
    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextStrokeTransparency = 0
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    esp[p] = {hl = hl, bb = bb, lbl = lbl}
    return esp[p]
end

local function hideEsp(p)
    local e = esp[p]
    if e then
        e.hl.Enabled = false
        e.hl.Adornee = nil
        e.bb.Enabled = false
        e.bb.Adornee = nil
    end
end

Players.PlayerRemoving:Connect(function(p)
    local e = esp[p]
    if e then e.hl:Destroy(); e.bb:Destroy(); esp[p] = nil end
end)

local function updateEsp()
    local mr = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    for _, p in ipairs(Players:GetPlayers()) do
        local shown = false
        if S.esp and mr and isEnemy(p) then
            local c, h, r = alive(p)
            if c then
                local d = (r.Position - mr.Position).Magnitude
                if d <= S.espRange then
                    shown = true
                    local e = getEsp(p)
                    local col = COLORS[colorIdx]
                    e.hl.Adornee = c
                    e.hl.FillColor = col
                    e.hl.Enabled = S.espFill
                    local parts = {}
                    if S.espName then table.insert(parts, p.DisplayName) end
                    if S.espHP then table.insert(parts, math.floor(h.Health) .. " HP") end
                    if S.espDist then table.insert(parts, math.floor(d) .. "m") end
                    e.lbl.Text = table.concat(parts, " | ")
                    e.lbl.TextColor3 = col
                    e.bb.Adornee = r
                    e.bb.Enabled = #parts > 0
                end
            end
        end
        if not shown then hideEsp(p) end
    end
end

-- ===== ТАРГЕТ ESP =====
local thl = Instance.new("Highlight")
thl.FillColor = Color3.fromRGB(255, 140, 0)
thl.OutlineColor = Color3.new(1, 1, 1)
thl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
thl.Enabled = false
thl.Parent = gui

local tbb = Instance.new("BillboardGui")
tbb.Size = UDim2.new(0, 170, 0, 24)
tbb.StudsOffset = Vector3.new(0, -4.5, 0)
tbb.AlwaysOnTop = true
tbb.Parent = gui
local tlbl = Instance.new("TextLabel", tbb)
tlbl.Size = UDim2.new(1, 0, 1, 0)
tlbl.BackgroundColor3 = Color3.new(0, 0, 0)
tlbl.BackgroundTransparency = 0.4
tlbl.TextColor3 = Color3.new(1, 1, 1)
tlbl.TextSize = 16
tlbl.Font = Enum.Font.GothamBold
Instance.new("UICorner", tlbl)

local function updateTarget()
    if not S.tesp then
        thl.Enabled = false
        tbb.Adornee = nil
        return
    end
    local target, dist = nearest(S.espRange)
    local c, h, r
    if target then c, h, r = alive(target) end
    if c then
        thl.Adornee = c
        thl.Enabled = true
        tbb.Adornee = r
        tlbl.Text = string.format("%d/%d HP | %dm",
            math.floor(h.Health), math.floor(h.MaxHealth), math.floor(dist))
    else
        thl.Enabled = false
        tbb.Adornee = nil
    end
end

RunService.RenderStepped:Connect(function()
    updateEsp()
    updateTarget()
end)

-- ===== ЛОГГЕР REMOTE =====
local logFrame = Instance.new("TextLabel", gui)
logFrame.Size = UDim2.new(0.5, 0, 0.4, 0)
logFrame.Position = UDim2.new(0.3, 0, 0.05, 0)
logFrame.BackgroundColor3 = Color3.new(0, 0, 0)
logFrame.BackgroundTransparency = 0.3
logFrame.TextColor3 = Color3.new(1, 1, 1)
logFrame.TextXAlignment = Enum.TextXAlignment.Left
logFrame.TextYAlignment = Enum.TextYAlignment.Top
logFrame.TextSize = 13
logFrame.TextWrapped = true
logFrame.Text = "Remote Log: бей врага вручную"
logFrame.Visible = false

local lines = {}
local function logLine(t)
    if lines[#lines] == t then return end
    table.insert(lines, t)
    if #lines > 12 then table.remove(lines, 1) end
    logFrame.Text = table.concat(lines, "\n")
end

local hooked = false
local function enableLogger()
    if hooked then return end
    if not hookmetamethod then
        logLine("hookmetamethod не поддерживается")
        return
    end
    hooked = true
    local cc = checkcaller or function() return false end
    local orig
    orig = hookmetamethod(game, "__namecall", function(self, ...)
        local m = getnamecallmethod()
        if S.remlog and (m == "FireServer" or m == "InvokeServer") and not cc() then
            local args = table.pack(...)
            pcall(function()
                local parts = {}
                for i = 1, args.n do
                    parts[i] = typeof(args[i]) .. ":" .. tostring(args[i])
                end
                logLine(self:GetFullName() .. " | " .. table.concat(parts, ", "))
            end)
        end
        return orig(self, ...)
    end)
end

-- ===== МЕНЮ =====
section("COMBAT")
toggle("Kill Aura", "aura")
stepper("Радиус", "auraRange", 5, 5, 100)

section("TARGET ESP")
toggle("Target ESP", "tesp")

section("ESP")
toggle("ESP", "esp")
toggle("Заливка", "espFill")
toggle("Ник", "espName")
toggle("HP", "espHP")
toggle("Дистанция", "espDist")
stepper("Дальность", "espRange", 50, 50, 1000)
local colorBtn = newBtn("Цвет: сменить")
colorBtn.MouseButton1Click:Connect(function()
    colorIdx = colorIdx % #COLORS + 1
    colorBtn.TextColor3 = COLORS[colorIdx]
end)

section("ОБЩЕЕ")
toggle("Team check", "teamCheck")
toggle("Remote Log", "remlog", function(on)
    logFrame.Visible = on
    if on then enableLogger() end
end)
