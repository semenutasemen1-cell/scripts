local lp = game:GetService("Players").LocalPlayer
print("hookmetamethod:", hookmetamethod ~= nil)
print("getnamecallmethod:", getnamecallmethod ~= nil)
print("firetouchinterest:", firetouchinterest ~= nil)
print("checkcaller:", checkcaller ~= nil)

local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
print("Tool в руках:", tool and tool.Name or "нет")
if tool then
    for _, v in ipairs(tool:GetDescendants()) do
        print(" -", v.ClassName, v:GetFullName())
    end
end

local RS = game:GetService("ReplicatedStorage")
for _, v in ipairs(RS:GetDescendants()) do
    if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
        print("Remote:", v:GetFullName())
    end
end
print("--- конец ---")
