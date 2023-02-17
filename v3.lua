--- Configs
local flybutton = "e"
local flyspeed = 100
local controls = {
	front = "w",
	back = "s",
	right = "d",
	left = "a",
	up = " ",
	down = "q"
}
-- Configs

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local runservice = game:GetService("RunService")

local flycontrol = {F = 0, R = 0, B = 0, L = 0, U = 0, D = 0}
local flying = false

local function fly()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end
	
	flying = true
	
	local bv = Instance.new("BodyVelocity")
	local bg = Instance.new("BodyGyro")
	bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
	bg.CFrame = hrp.CFrame
	bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
	bg.P = 9e4
	bv.Parent = hrp
	bg.Parent = hrp
	
	for i, child in pairs(character:GetDescendants()) do
		if child:IsA("BasePart") then
			coroutine.wrap(function()
				local con = nil
				con = runservice.Stepped:Connect(function()
					if not flying then
						con:Disconnect()
						child.CanCollide = true
					end
					child.CanCollide = false
				end)
			end)()
		end
	end
	
	local con = nil
	con = runservice.Stepped:Connect(function()
		if not flying then
			con:Disconnect()
			bv:Destroy()
			bg:Destroy()
		end
		
		humanoid.PlatformStand = true
		bv.Velocity = (workspace.Camera.CoordinateFrame.LookVector * ((flycontrol.F - flycontrol.B) * flyspeed)) + (workspace.CurrentCamera.CoordinateFrame.RightVector * ((flycontrol.R - flycontrol.L) * flyspeed)) + (workspace.CurrentCamera.CoordinateFrame.UpVector * ((flycontrol.U - flycontrol.D) * flyspeed))
		bg.CFrame = workspace.Camera.CoordinateFrame
	end)
	
	repeat wait() until not flying
	
	while humanoid.PlatformStand == true do
		humanoid.PlatformStand = false
		task.wait()
	end
end

mouse.KeyDown:Connect(function(key)
	
	if key:lower() == flybutton then
		if flying then
			flying = false
		else
			fly()
		end
	elseif key:lower() == controls.front then
		flycontrol.F = 1
	elseif key:lower() == controls.back then
		flycontrol.B = 1
	elseif key:lower() == controls.right then
		flycontrol.R = 1
	elseif key:lower() == controls.left then
		flycontrol.L = 1
	elseif key:lower() == controls.up then
		flycontrol.U = 1
	elseif key:lower() == controls.down then
		flycontrol.D = 1
	end
end)

mouse.KeyUp:Connect(function(key)
	if key:lower() == controls.front then
		flycontrol.F = 0
	elseif key:lower() == controls.back then
		flycontrol.B = 0
	elseif key:lower() == controls.right then
		flycontrol.R = 0
	elseif key:lower() == controls.left then
		flycontrol.L = 0
	elseif key:lower() == controls.up then
		flycontrol.U = 0
	elseif key:lower() == controls.down then
		flycontrol.D = 0
	end
end)

player.CharacterAdded:Connect(function()
	flying = false
end)
