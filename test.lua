local lp = game:GetService("Players").LocalPlayer
local lines = {}
local function add(...)
    local t = {}
    for i, v in ipairs({...}) do t[i] = tostring(v) end
    table.insert(lines, table.concat(t, " "))
end

add("hookmetamethod:", hookmetamethod ~= nil)
add("getnamecallmethod:", getnamecallmethod ~= nil)
add("firetouchinterest:", firetouchinterest ~= nil)
add("checkcaller:", checkcaller ~= nil)

pcall(function()
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    add("Tool в руках:", tool and tool.Name or "нет")
    if tool then
        for _, v in ipairs(tool:GetDescendants()) do
            add(" -", v.ClassName, v.Name)
        end
    end
end)

pcall(function()
    for _, v in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            add("Remote:", v:GetFullName())
        end
    end
end)
add("--- конец ---")

local root = (gethui and gethui()) or game:GetService("CoreGui")
local old = root:FindFirstChild("TestOut")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "TestOut"
gui.ResetOnSpawn = false
gui.Parent = root

local sf = Instance.new("ScrollingFrame", gui)
sf.Size = UDim2.new(0.6, 0, 0.7, 0)
sf.Position = UDim2.new(0.2, 0, 0.15, 0)
sf.BackgroundColor3 = Color3.new(0, 0, 0)
sf.BackgroundTransparency = 0.1
sf.CanvasSize = UDim2.new()
sf.AutomaticCanvasSize = Enum.AutomaticSize.Y

local t = Instance.new("TextLabel", sf)
t.Size = UDim2.new(1, 0, 0, 0)
t.AutomaticSize = Enum.AutomaticSize.Y
t.BackgroundTransparency = 1
t.TextColor3 = Color3.new(1, 1, 1)
t.TextSize = 14
t.TextWrapped = true
t.TextXAlignment = Enum.TextXAlignment.Left
t.TextYAlignment = Enum.TextYAlignment.Top
t.Text = table.concat(lines, "\n")

local x = Instance.new("TextButton", gui)
x.Size = UDim2.new(0, 60, 0, 36)
x.Position = UDim2.new(0.8, -60, 0.15, -40)
x.Text = "X"
x.MouseButton1Click:Connect(function() gui:Destroy() end)
