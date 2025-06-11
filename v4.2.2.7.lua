-- VERSION: 4.2.2.7
-- More versions: https://github.com/lilmond/roblox_fly_script

--- Configs
getgenv().fly_force_stop = false
getgenv().flybutton = "t"
getgenv().flyparent = "HumanoidRootPart"
getgenv().flyspeed = 100

getgenv().invisible_subkey = ""
getgenv().invisiblebutton = "y"
getgenv().invisible_max_distance = 9e10

getgenv().controls = {
	front = "w",
	back = "s",
	right = "d",
	left = "a",
	up = "space",
	down = "leftcontrol",
	add_speed = "rightbracket",
	sub_speed = "leftbracket",
	reset_speed = "minus"
}
getgenv().default_flyspeed = getgenv().flyspeed
-- Configs

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local camera = game:GetService("Workspace").CurrentCamera

local flycontrol = {F = 0, R = 0, B = 0, L = 0, U = 0, D = 0}
local flying = false
local invisible_enabled = false

local function fly()
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild(getgenv().flyparent)
	if not hrp then return end
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end

	flying = true
	
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

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
		bv.Velocity = (workspace.Camera.CoordinateFrame.LookVector * ((flycontrol.F - flycontrol.B) * getgenv().flyspeed)) + (workspace.CurrentCamera.CoordinateFrame.RightVector * ((flycontrol.R - flycontrol.L) * getgenv().flyspeed)) + (workspace.CurrentCamera.CoordinateFrame.UpVector * ((flycontrol.U - flycontrol.D) * getgenv().flyspeed))
		bg.CFrame = workspace.Camera.CoordinateFrame
	end)

	repeat wait() until not flying

	while humanoid.PlatformStand == true do
		humanoid.PlatformStand = false
		task.wait()
	end
	
	if not invisible_enabled then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
	end
end

local function invisible()
	local random = Random.new()
	
	local character = player.Character
	if not character then return end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return end
	
	invisible_enabled = true
	
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
	humanoid.Sit = false
	
    local cammodel = Instance.new("Model")
	local campart = Instance.new("Part")
    local camhumanoid = Instance.new("Humanoid")
	campart.CFrame = hrp.CFrame
	campart.Transparency = 0.5
	campart.BrickColor = BrickColor.new("Really red")
	campart.Material = Enum.Material.ForceField
	campart.Size = hrp.Size
	campart.CanCollide = false
    campart.Name = "HumanoidRootPart"
	campart.Parent = cammodel
    camhumanoid.Parent = cammodel
    cammodel.Parent = game:GetService("Workspace")
	camera.CameraSubject = camhumanoid
	
	local bv = Instance.new("BodyVelocity")
	local bg = Instance.new("BodyGyro")
	bv.MaxForce = Vector3.new(9e4, 9e4, 9e4)
	bg.CFrame = hrp.CFrame
	bg.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
	bg.P = 9e4
	bv.Parent = campart
	bg.Parent = campart
	
	local con = nil
	con = runservice.Stepped:Connect(function()
		if not invisible_enabled then
			if campart then
				hrp.CFrame = campart.CFrame
				hrp.Velocity = campart.Velocity
				cammodel:Destroy()
			end
			if not flying then
				humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
			end
			camera.CameraSubject = player.Character:FindFirstChildWhichIsA("Humanoid")
			con:Disconnect()
			return
		end
		hrp.CFrame = CFrame.new(random:NextNumber(-getgenv().invisible_max_distance, getgenv().invisible_max_distance), random:NextNumber(0, getgenv().invisible_max_distance), random:NextNumber(-getgenv().invisible_max_distance, getgenv().invisible_max_distance))
		hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
		bv.Velocity = (workspace.Camera.CoordinateFrame.LookVector * ((flycontrol.F - flycontrol.B) * getgenv().flyspeed)) + (workspace.CurrentCamera.CoordinateFrame.RightVector * ((flycontrol.R - flycontrol.L) * getgenv().flyspeed)) + (workspace.CurrentCamera.CoordinateFrame.UpVector * ((flycontrol.U - flycontrol.D) * getgenv().flyspeed))
		bg.CFrame = workspace.Camera.CoordinateFrame
	end)
end

local function main()
	if getgenv().FLY_SCRIPT_RUNNING then return end
	getgenv().FLY_SCRIPT_RUNNING = true

	getgenv().KEY_LISTENER1 = uis.InputBegan:Connect(function(keyinput, paused)
		if paused then return end

		local key = keyinput.KeyCode.Name:lower()

		if key == getgenv().flybutton then
			if flying then
				flying = false
			else
				fly()
			end
		elseif key == getgenv().controls.front then
			flycontrol.F = 1
		elseif key == getgenv().controls.back then
			flycontrol.B = 1
		elseif key == getgenv().controls.right then
			flycontrol.R = 1
		elseif key == getgenv().controls.left then
			flycontrol.L = 1
		elseif key == getgenv().controls.up then
			flycontrol.U = 1
		elseif key == getgenv().controls.down then
			flycontrol.D = 1
		elseif key == getgenv().controls.add_speed then
			if getgenv().flyspeed == 1 then
				getgenv().flyspeed = 25
			else
				getgenv().flyspeed += 25
			end
			textgui.TextTransparency = 0
			textgui.Text = getgenv().flyspeed
			wait(0.1)
			while uis:IsKeyDown(keyinput.KeyCode) do
				getgenv().flyspeed += 25
				textgui.Text = getgenv().flyspeed
				wait(0.05)
			end
			textgui.TextTransparency = 1
		elseif key == getgenv().controls.sub_speed then
			if (getgenv().flyspeed - 25) < 1 then
				getgenv().flyspeed = 1
			else	
				getgenv().flyspeed -= 25
			end
			textgui.TextTransparency = 0
			textgui.Text = getgenv().flyspeed
			wait(0.1)
			while uis:IsKeyDown(keyinput.KeyCode) do
				if (getgenv().flyspeed - 25) < 1 then
					getgenv().flyspeed = 1
				else	
					getgenv().flyspeed -= 25
				end
				textgui.Text = getgenv().flyspeed
				wait(0.05)
			end
			textgui.TextTransparency = 1
		elseif key == getgenv().controls.reset_speed then
			textgui.TextTransparency = 0
			getgenv().flyspeed = getgenv().default_flyspeed
			textgui.Text = getgenv().flyspeed
			wait(0.1)
			textgui.TextTransparency = 1
		elseif key == getgenv().invisiblebutton then
			local subkey_held = false
			
			if (getgenv().invisible_subkey ~= "") then
				for i, kc in pairs(Enum.KeyCode:GetEnumItems()) do
					local kcs = kc.Name:lower()
					if (kcs == getgenv().invisible_subkey) then
						if not uis:IsKeyDown(kc) then return end
						subkey_held = true
					end
				end
			else
				subkey_held = true
			end
			
			if not subkey_held then return end
			
			if invisible_enabled then
				invisible_enabled = false
			else
				invisible()
			end
		end
	end)

	getgenv().KEY_LISTENER2 = uis.InputEnded:Connect(function(key, paused)
		if paused then return end

		key = key.KeyCode.Name:lower()

		if key == getgenv().controls.front then
			flycontrol.F = 0
		elseif key == getgenv().controls.back then
			flycontrol.B = 0
		elseif key == getgenv().controls.right then
			flycontrol.R = 0
		elseif key == getgenv().controls.left then
			flycontrol.L = 0
		elseif key == getgenv().controls.up then
			flycontrol.U = 0
		elseif key == getgenv().controls.down then
			flycontrol.D = 0
		end
	end)

	local function load_textgui()
		local gui = player.PlayerGui:FindFirstChild("FlyGUI")
		if gui then
			gui:Destroy()
		end

		local gui = Instance.new("ScreenGui")
		local text = Instance.new("TextLabel")

		gui.Name = "FlyGUI"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true

		text.Size = UDim2.new(1, 0, 0, 25)
		text.Position = UDim2.fromScale(0, 0.5)
		text.BackgroundTransparency = 1
		text.TextSize = 25
		text.Text = getgenv().flyspeed
		text.TextColor = BrickColor.new("White")
		text.Font = Enum.Font.SciFi
		text.TextTransparency = 1

		gui.Parent = player.PlayerGui
		text.Parent = gui

		return text
	end

	getgenv().CHARACTER_ADDED_CON = player.CharacterAdded:Connect(function()
		flying = false
		invisible_enabled = false
	end)

	textgui = load_textgui()
end

if (not getgenv().fly_force_stop) then
	main()
else
	if getgenv().KEY_LISTENER1 then
		getgenv().KEY_LISTENER1:Disconnect()
	end

	if getgenv().KEY_LISTENER2 then
		getgenv().KEY_LISTENER2:Disconnect()
	end

	if getgenv().CHARACTER_ADDED_CON then
		getgenv().CHARACTER_ADDED_CON:Disconnect()
	end

	getgenv().FLY_SCRIPT_RUNNING = false
end
