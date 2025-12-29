-- Lenny V1 - Ultimate God Client
-- Zugriff NUR für UserId 10114308197

local ALLOWED_USER_ID = 10114308197

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
if player.UserId ~= ALLOWED_USER_ID then return end

-- =====================
-- CHARACTER
-- =====================
local char, hum, root
local function loadChar(c)
	char = c
	hum = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")

	-- HARD GOD SETUP
	hum.MaxHealth = math.huge
	hum.Health = hum.MaxHealth
	hum.BreakJointsOnDeath = false
	hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
end

loadChar(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(loadChar)

-- =====================
-- STATES
-- =====================
local states = {
	Fly=false, NoClip=false, ESP=false,
	Speed=false, Jump=false, Invis=false,
	God=true, Fullbright=false, AntiVoid=true
}

-- =====================
-- ABSOLUTE GODMODE LOOP
-- =====================
RunService.Heartbeat:Connect(function()
	if not hum or not states.God then return end

	-- Health Lock
	hum.MaxHealth = math.huge
	hum.Health = hum.MaxHealth

	-- Anti Void
	if states.AntiVoid and root.Position.Y < -50 then
		root.CFrame = CFrame.new(0, 100, 0)
	end
end)

hum.HealthChanged:Connect(function()
	if states.God then
		hum.Health = hum.MaxHealth
	end
end)

hum.Died:Connect(function()
	if states.God then
		hum.Health = hum.MaxHealth
	end
end)

-- =====================
-- SPEED & JUMP
-- =====================
local function applyMovement()
	hum.WalkSpeed = states.Speed and 65 or 16
	hum.JumpPower = states.Jump and 220 or 50
end

-- =====================
-- FLY
-- =====================
local gyro, vel
local control = {F=0,B=0,L=0,R=0,U=0,D=0}

RunService.RenderStepped:Connect(function()
	if states.Fly and gyro and vel then
		local cam = workspace.CurrentCamera
		local dir =
			(cam.CFrame.LookVector * (control.F + control.B)) +
			(cam.CFrame.RightVector * (control.R + control.L)) +
			Vector3.new(0,1,0) * (control.U + control.D)

		if dir.Magnitude > 0 then dir = dir.Unit * 80 end
		vel.Velocity = dir
		gyro.CFrame = cam.CFrame
	end
end)

local function toggleFly()
	states.Fly = not states.Fly
	if states.Fly then
		hum.PlatformStand = true
		gyro = Instance.new("BodyGyro", root)
		gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
		vel = Instance.new("BodyVelocity", root)
		vel.MaxForce = Vector3.new(9e9,9e9,9e9)
	else
		hum.PlatformStand = false
		if gyro then gyro:Destroy() end
		if vel then vel:Destroy() end
	end
end

-- =====================
-- NOCLIP
-- =====================
RunService.Stepped:Connect(function()
	if states.NoClip then
		for _,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end
end)

-- =====================
-- INVISIBILITY
-- =====================
local function toggleInvis()
	states.Invis = not states.Invis
	for _,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = states.Invis and 1 or 0
			if v.Name == "HumanoidRootPart" then v.Transparency = 1 end
		elseif v:IsA("Decal") then
			v.Transparency = states.Invis and 1 or 0
		end
	end
end

-- =====================
-- FULLBRIGHT
-- =====================
local oldLighting = {}
local function toggleFullbright()
	states.Fullbright = not states.Fullbright
	if states.Fullbright then
		oldLighting = {
			Brightness = Lighting.Brightness,
			ClockTime = Lighting.ClockTime,
			FogEnd = Lighting.FogEnd
		}
		Lighting.Brightness = 5
		Lighting.ClockTime = 14
		Lighting.FogEnd = 100000
	else
		for k,v in pairs(oldLighting) do
			Lighting[k] = v
		end
	end
end

-- =====================
-- ESP
-- =====================
local espBoxes = {}
local function toggleESP()
	states.ESP = not states.ESP
	if not states.ESP then
		for _,b in pairs(espBoxes) do if b then b:Destroy() end end
		espBoxes = {}
	end
end

RunService.RenderStepped:Connect(function()
	if not states.ESP then return end
	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			if not espBoxes[plr] then
				local box = Instance.new("BoxHandleAdornment")
				box.Adornee = plr.Character.HumanoidRootPart
				box.AlwaysOnTop = true
				box.Color3 = Color3.fromRGB(0,255,120)
				box.Transparency = 0.4
				box.ZIndex = 10
				box.Parent = workspace
				espBoxes[plr] = box
			end
		end
	end
end)

-- =====================
-- INPUT (FLY)
-- =====================
UIS.InputBegan:Connect(function(i,g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.W then control.F=1 end
	if i.KeyCode == Enum.KeyCode.S then control.B=-1 end
	if i.KeyCode == Enum.KeyCode.A then control.L=-1 end
	if i.KeyCode == Enum.KeyCode.D then control.R=1 end
	if i.KeyCode == Enum.KeyCode.Space then control.U=1 end
	if i.KeyCode == Enum.KeyCode.LeftShift then control.D=-1 end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W then control.F=0 end
	if i.KeyCode == Enum.KeyCode.S then control.B=0 end
	if i.KeyCode == Enum.KeyCode.A then control.L=0 end
	if i.KeyCode == Enum.KeyCode.D then control.R=0 end
	if i.KeyCode == Enum.KeyCode.Space then control.U=0 end
	if i.KeyCode == Enum.KeyCode.LeftShift then control.D=0 end
end)

-- =====================
-- GUI (LENNY V1)
-- =====================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,520)
frame.Position = UDim2.new(0,30,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(12,12,12)
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0,255,150)
stroke.Thickness = 2

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,45)
title.Text = "Lenny V1"
title.Font = Enum.Font.Code
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(0,255,150)
title.BackgroundTransparency = 1

local y = 55
local function button(name, func)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-30,0,40)
	b.Position = UDim2.new(0,15,0,y)
	y += 45
	b.Text = name.." : OFF"
	b.Font = Enum.Font.Code
	b.TextColor3 = Color3.fromRGB(0,255,150)
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,12)

	b.MouseButton1Click:Connect(function()
		func()
		if name=="Speed" or name=="Jump" then applyMovement() end
		b.Text = name.." : "..(states[name] and "ON" or "OFF")
	end)
end

button("Fly", toggleFly)
button("NoClip", function() states.NoClip=not states.NoClip end)
button("ESP", toggleESP)
button("Speed", function() states.Speed=not states.Speed end)
button("Jump", function() states.Jump=not states.Jump end)
button("Invisible", toggleInvis)
button("Fullbright", toggleFullbright)
button("GodMode", function() states.God=not states.God end)

UIS.InputBegan:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.RightShift then
		frame.Visible = not frame.Visible
	end
end)