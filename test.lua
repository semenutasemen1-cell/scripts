local names = {}
local skip = {AdminAction=1, EconomyState=1, BlockChanged=1, BlockSync=1,
    ProjectileSpawned=1, Explosion=1, ProjectileRemoved=1}

pcall(function()
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) and not skip[v.Name] then
            table.insert(names, v.Name)
        end
    end
end)

local text = #names > 0 and table.concat(names, "  |  ") or "новых Remote нет"

local root = (gethui and gethui()) or game:GetService("CoreGui")
local old = root:FindFirstChild("TestOut")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "TestOut"
gui.ResetOnSpawn = false
gui.Parent = root

local sf = Instance.new("ScrollingFrame", gui)
sf.Size = UDim2.new(0.7, 0, 0.6, 0)
sf.Position = UDim2.new(0.15, 0, 0.2, 0)
sf.BackgroundColor3 = Color3.new(0, 0, 0)
sf.BackgroundTransparency = 0.1
sf.CanvasSize = UDim2.new()
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
sf.ScrollBarThickness = 8

local t = Instance.new("TextLabel", sf)
t.Size = UDim2.new(1, -10, 0, 0)
t.AutomaticSize = Enum.AutomaticSize.Y
t.BackgroundTransparency = 1
t.TextColor3 = Color3.new(1, 1, 1)
t.TextSize = 13
t.TextWrapped = true
t.TextXAlignment = Enum.TextXAlignment.Left
t.TextYAlignment = Enum.TextYAlignment.Top
t.Text = "Всего: " .. #names .. "\n" .. text

local function btn(txt, x, fn)
    local b = Instance.new("TextButton", gui)
    b.Size = UDim2.new(0, 60, 0, 40)
    b.Position = UDim2.new(x, 0, 0.2, -44)
    b.Text = txt
    b.MouseButton1Click:Connect(fn)
end
btn("▲", 0.15, function() sf.CanvasPosition = Vector2.new(0, math.max(0, sf.CanvasPosition.Y - 150)) end)
btn("▼", 0.22, function() sf.CanvasPosition = Vector2.new(0, sf.CanvasPosition.Y + 150) end)
btn("X", 0.29, function() gui:Destroy() end)
