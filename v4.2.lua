--- Configs
local flybutton = "e"
local flyspeed = 100
local controls = {
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
local default_flyspeed = flyspeed
-- Configs

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local runservice = game:GetService("RunService")
local uis = game:GetService("UserInputService")

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

uis.InputBegan:Connect(function(keyinput, paused)
	if paused then return end

	key = keyinput.KeyCode.Name:lower()

	if key == flybutton then
		if flying then
			flying = false
		else
			fly()
		end
	elseif key == controls.front then
		flycontrol.F = 1
	elseif key == controls.back then
		flycontrol.B = 1
	elseif key == controls.right then
		flycontrol.R = 1
	elseif key == controls.left then
		flycontrol.L = 1
	elseif key == controls.up then
		flycontrol.U = 1
	elseif key == controls.down then
		flycontrol.D = 1
	elseif key == controls.add_speed then
		if flyspeed == 1 then
			flyspeed = 25
		else
			flyspeed += 25
		end
		textgui.TextTransparency = 0
		textgui.Text = flyspeed
		wait(0.1)
		while uis:IsKeyDown(keyinput.KeyCode) do
			flyspeed += 25
			textgui.Text = flyspeed
			wait(0.05)
		end
		textgui.TextTransparency = 1
	elseif key == controls.sub_speed then
		if (flyspeed - 25) < 1 then
			flyspeed = 1
		else	
			flyspeed -= 25
		end
		textgui.TextTransparency = 0
		textgui.Text = flyspeed
		wait(0.1)
		while uis:IsKeyDown(keyinput.KeyCode) do
			if (flyspeed - 25) < 1 then
				flyspeed = 1
			else	
				flyspeed -= 25
			end
			textgui.Text = flyspeed
			wait(0.05)
		end
		textgui.TextTransparency = 1
	elseif key == controls.reset_speed then
		textgui.TextTransparency = 0
		flyspeed = default_flyspeed
		textgui.Text = flyspeed
		wait(0.1)
		textgui.TextTransparency = 1
	end
end)

uis.InputEnded:Connect(function(key, paused)
	if paused then return end

	key = key.KeyCode.Name:lower()

	if key == controls.front then
		flycontrol.F = 0
	elseif key == controls.back then
		flycontrol.B = 0
	elseif key == controls.right then
		flycontrol.R = 0
	elseif key == controls.left then
		flycontrol.L = 0
	elseif key == controls.up then
		flycontrol.U = 0
	elseif key == controls.down then
		flycontrol.D = 0
	end
end)

local function load_textgui()
	local gui = Instance.new("ScreenGui")
	local text = Instance.new("TextLabel")

	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true

	text.Size = UDim2.new(1, 0, 0, 25)
	text.Position = UDim2.fromScale(0, 0.5)
	text.BackgroundTransparency = 1
	text.TextSize = 25
	text.Text = flyspeed
	text.TextColor = BrickColor.new("White")
	text.Font = Enum.Font.SciFi
	text.TextTransparency = 1

	gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui
	text.Parent = gui
	
	return text
end

player.CharacterAdded:Connect(function()
	flying = false
end)

textgui = load_textgui()
