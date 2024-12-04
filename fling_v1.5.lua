local FLING_PART = "HumanoidRootPart"

local player = game:GetService("Players").LocalPlayer
local camera = game:GetService("Workspace").CurrentCamera
local uis = game:GetService("UserInputService")

uis.InputBegan:Connect(function(key, paused)
    if paused then return end
    
    if key.KeyCode == Enum.KeyCode.G then
        local character = player.Character
        if not character then return end
        local rootPart = character:FindFirstChild(FLING_PART)
        if not rootPart then return end
        local humanoid = character:FindFirstChildWhichIsA("Humanoid")
        if not humanoid then return end

        if rootPart:FindFirstChildWhichIsA("BodyAngularVelocity") then
            rootPart:FindFirstChildWhichIsA("BodyAngularVelocity"):Destroy()
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            camera.CameraSubject = humanoid
            humanoid.AutoRotate = true
            for _, child in pairs(character:GetDescendants()) do if child:IsA("BasePart") then child.Massless = false end end
            return
        end

        for _, child in pairs(character:GetDescendants()) do if child:IsA("BasePart") then child.Massless = true end end
        local bv = Instance.new("BodyAngularVelocity")
        bv.AngularVelocity = Vector3.new(0, 9e4, 0)
        bv.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        bv.P = 9e4
        bv.Parent = rootPart

        humanoid.AutoRotate = false
        camera.CameraSubject = rootPart

        if rootPart:FindFirstChildWhichIsA("BodyGyro") then
            rootPart:FindFirstChildWhichIsA("BodyGyro"):Destroy()
        end
    end
end)
