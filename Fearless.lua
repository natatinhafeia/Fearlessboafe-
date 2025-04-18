--[[
  Aimbot Fearless - Completo
  Autor: @fearless_boafe
  Funcionalidades:
  - Slider FOV (1–300)
  - Seleção de parte do corpo
  - Visualização do corpo
  - Mira com botão direito
  - Suavização + proteção de aliados
  - Mensagem automática após 1 minuto
]]

-- SERVIÇOS
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- CONFIG
_G.FOV_RADIUS = 100
_G.AIM_PART = "Head"
local aimEnabled = true
local aiming = false

-- GUI
local gui = Instance.new("ScreenGui", localPlayer:WaitForChild("PlayerGui"))
gui.Name = "AimbotUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0, 20, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "Aimbot Fearless"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 22

-- FOV SLIDER
local fovLabel = Instance.new("TextLabel", frame)
fovLabel.Position = UDim2.new(0, 10, 0, 50)
fovLabel.Size = UDim2.new(1, -20, 0, 20)
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.Text = "FOV: " .. _G.FOV_RADIUS

local fovBar = Instance.new("Frame", frame)
fovBar.Position = UDim2.new(0, 10, 0, 75)
fovBar.Size = UDim2.new(1, -20, 0, 8)
fovBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)

local fovFill = Instance.new("Frame", fovBar)
fovFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
fovFill.Size = UDim2.new(_G.FOV_RADIUS / 300, 0, 1, 0)

local dragging = false
fovBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
UserInputService.InputChanged:Connect(function(input)
	if dragging then
		local percent = math.clamp((input.Position.X - fovBar.AbsolutePosition.X) / fovBar.AbsoluteSize.X, 0, 1)
		fovFill.Size = UDim2.new(percent, 0, 1, 0)
		_G.FOV_RADIUS = math.floor(percent * 300)
		fovLabel.Text = "FOV: " .. _G.FOV_RADIUS
	end
end)

-- DROP: PARTE DO CORPO
local parts = {"Head", "Torso", "HumanoidRootPart", "LeftLeg", "RightArm"}
local partLabel = Instance.new("TextLabel", frame)
partLabel.Position = UDim2.new(0, 10, 0, 100)
partLabel.Size = UDim2.new(1, -20, 0, 20)
partLabel.BackgroundTransparency = 1
partLabel.TextColor3 = Color3.new(1, 1, 1)
partLabel.Text = "Parte do corpo:"

local partBtn = Instance.new("TextButton", frame)
partBtn.Position = UDim2.new(0, 10, 0, 125)
partBtn.Size = UDim2.new(1, -20, 0, 30)
partBtn.Text = _G.AIM_PART
partBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
partBtn.TextColor3 = Color3.new(1, 1, 1)
partBtn.Font = Enum.Font.GothamBold
partBtn.TextSize = 16

partBtn.MouseButton1Click:Connect(function()
	local i = table.find(parts, _G.AIM_PART) or 1
	i = (i % #parts) + 1
	_G.AIM_PART = parts[i]
	partBtn.Text = _G.AIM_PART
	updateHighlight()
end)

-- PREVIEW
local preview = Instance.new("ViewportFrame", frame)
preview.Position = UDim2.new(0, 50, 0, 170)
preview.Size = UDim2.new(0, 200, 0, 200)
preview.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local model = Players:CreateHumanoidModelFromUserId(1)
model.PrimaryPart = model:FindFirstChild("HumanoidRootPart")
model:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
model.Parent = preview

local cam = Instance.new("Camera", preview)
preview.CurrentCamera = cam
cam.CFrame = CFrame.new(Vector3.new(0, 1.5, 5), Vector3.new(0, 1.5, 0))

local hl = Instance.new("Highlight", preview)
hl.FillColor = Color3.fromRGB(0, 255, 0)
hl.OutlineTransparency = 1

function updateHighlight()
	local p = model:FindFirstChild(_G.AIM_PART)
	if p then hl.Adornee = p end
end
updateHighlight()

-- MENSAGEM 1 MINUTO
task.delay(60, function()
	local msg = Instance.new("TextLabel", gui)
	msg.Size = UDim2.new(1, 0, 0, 40)
	msg.Position = UDim2.new(0.5, 0, 0.9, 0)
	msg.AnchorPoint = Vector2.new(0.5, 0.5)
	msg.Text = "siga o @fearless_boafe para mais atualizações"
	msg.TextColor3 = Color3.new(1, 1, 1)
	msg.TextScaled = true
	msg.BackgroundTransparency = 1
	msg.Font = Enum.Font.GothamBold
	for i = 1, 30 do
		msg.TextTransparency = 1 - i * 0.03
		task.wait(0.03)
	end
end)

-- ===============================
-- AIMBOT FUNCIONAL
-- ===============================

local function isEnemy(player)
	return player ~= localPlayer and player.Team ~= localPlayer.Team
end

local function getClosest()
	local closest = nil
	local shortest = math.huge
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if isEnemy(player) and player.Character and player.Character:FindFirstChild(_G.AIM_PART) then
			local part = player.Character[_G.AIM_PART]
			local pos, onScreen = camera:WorldToViewportPoint(part.Position)
			if onScreen then
				local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
				if dist < _G.FOV_RADIUS and dist < shortest then
					shortest = dist
					closest = part
				end
			end
		end
	end

	return closest
end

UserInputService.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = true
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
	end
end)

RunService.RenderStepped:Connect(function()
	if aimEnabled and aiming then
		local target = getClosest()
		if target then
			local dir = (target.Position - camera.CFrame.Position).Unit
			local targetCF = CFrame.new(camera.CFrame.Position, camera.CFrame.Position + dir)
			camera.CFrame = camera.CFrame:Lerp(targetCF, 0.15)
		end
	end
end)
