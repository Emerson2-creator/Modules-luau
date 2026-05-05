-- Developed by Emerson

local xdev = {}
local fly = {}
local esp = {}
local exploits = {}

xdev.__index = xdev
fly.__index = fly
esp.__index = esp
exploits.__index = exploits

local cloneref = (cloneref or clonereference or function(instance: any)
	return instance
end)

local Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return cloneref(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

local Players: Players = Services.Players
local UserInputService = Services.UserInputService

local LocalPlayer: Player = Players.LocalPlayer
local Character: Model = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid: Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart: BasePart = Humanoid.RootPart Character:WaitForChild("HumanoidRootPart")
local CurrentCamera: Camera = workspace.CurrentCamera



local LOCAL_PLAYER_ID = LocalPlayer.UserId
local LOCAL_PLAYER_NAME = LocalPlayer.Name
local PLACE_ID = game.PlaceId

local LOCAL_PLAYER_ID_ToString= tostring(LocalPlayer.UserId)
local PLACE_ID_ToString = tostring(game.PlaceId)

local VECTOR3_INF = Vector3.new(9e9, 9e9, 9e9)
local VECTOR3_ZERO = Vector3.new(0, 0, 0)



local CharacterAddedConnection: RBXScriptConnection = LocalPlayer.CharacterAdded:Connect(function(character: Model)
	Character = character
	Humanoid = character:WaitForChild("Humanoid")
	HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
end)


function xdev.new()
	local self = setmetatable({}, xdev)
	
	self._Fly = fly.new()
	self._Exploits = exploits.new() 
	
	self._hipHeight = {
		defaultValue = if Humanoid then Humanoid.HipHeight else 0,
		currentValue = if Humanoid then Humanoid.HipHeight else 0,
	}
	
	self._jumpPowerHeight = {
		powerDefaultValue = if Humanoid then Humanoid.JumpPower else 50,
		powerCurrentValue = if Humanoid then Humanoid.JumpPower else 50,
		
		usingJumpPower = if Humanoid then Humanoid.UseJumpPower else false,
		
		heightDefaultValue = if Humanoid then Humanoid.JumpHeight else 7.2,
		heightCurrentValue = if Humanoid then Humanoid.JumpHeight else 7.2,
	}
	
	
	return self
end

function xdev:SetJumpPower(value: number)
	if typeof(value) ~= "number" then return end
	
	if Humanoid then 
		Humanoid.JumpPower = value
		Humanoid.UseJumpPower = true
		self._jumpPowerHeight.usingJumpPower = true
		self._jumpPowerHeight.powerCurrentValue = value
	end
end

function xdev:SetJumpHeight(value: number)
	if typeof(value) ~= "number" then return end
	
	if Humanoid then 
		Humanoid.JumpHeight = value
		Humanoid.UseJumpPower = false
		self._jumpPowerHeight.usingJumpPower = false
		self._jumpPowerHeight.heightCurrentValue = value
	end
end

function xdev:SetHipHeight(value: number)
	if typeof(value) ~= "number" then return end
	
	if Humanoid then
		Humanoid.HipHeight = value
		self._hipHeight.currentValue = value
	end
end

function xdev:SetCharacterSize(value: number)
	if typeof(value) ~= "number" then return end
	
	if Character then
		Character:ScaleTo(value)
	end
end

function xdev:Fly()
	self._Fly:Set(true)
end

function xdev:Unfly()
	self._Fly:Set(false)
end

function xdev:_GetFlyModule()
	return self._Fly
end

function xdev:_GetExploitsModule()
	return self._Exploits
end

-- [[ EXPLOITS ]]

function exploits.new()
	local self = setmetatable({}, exploits)
	
	self._Initialized = false
	
	self._noRagdoll = false
	self._noSlow = false
	self._noFatigue = false
	self._noDashCooldown = false
	self._noFreeze = false
	
	self:Init()
	
	assert(self:GetInitialized() == true, "Exploits module not initialized")
	
	return self
end

function exploits:GetInitialized(): boolean
	return self.Initialized
end

function exploits:Init()
	if self:GetInitialized() then return end
	
	
	
	if workspace:GetAttribute("VIPServer") == nil or workspace:GetAttribute("VIPServer") ~= LOCAL_PLAYER_ID_ToString then
		workspace:SetAttribute("VIPServer", LOCAL_PLAYER_ID_ToString)
	end

	if workspace:GetAttribute("VIPServerOwner") == nil or workspace:GetAttribute("VIPServerOwner") ~= LOCAL_PLAYER_NAME then 
		workspace:SetAttribute("VIPServerOwner", LOCAL_PLAYER_NAME)
	end
	
	workspace:SetAttribute('EffectAffects', 1) 
	
	self.Initialized = true
end


function exploits:Unload()
	if not self:GetInitialized() then return end
	
	self.Initialized = false
	
end


function exploits:SetNoRagdoll(value: boolean)
	if typeof(value) ~= "boolean" then return end
	if self._noRagdoll == value then return end
	
	self._noRagdoll = value
	
	if not value then return end
	
	task.spawn(function()
		while self._noRagdoll do
			task.wait(0.1)
			
			if not Character then return end
			
			local ragdoll = Character:FindFirstChild("Ragdoll")
			local ragdollSim = Character:FindFirstChild("RagdollSim")
			
			if ragdoll then
				ragdoll:Destroy()
				ragdoll = nil
			end

			if ragdollSim then
				ragdollSim:Destroy()
				ragdollSim = nil
			end
			
		end
	end)
	
end

function exploits:SetNoFreeze(value: boolean)
	if typeof(value) ~= "boolean" then return end
	if self._noFreeze == value then return end
	
	self._noFreeze = value
	
	if not value then return end
	
	task.spawn(function()
		while self._noFreeze do
			task.wait(0.1)
			
			if not Character then return end
			
			local freeze = Character:FindFirstChild("Freeze")
			
			if freeze then
				freeze:Destroy()
				freeze = nil
			end
		end
	end)
end


function exploits:SetNoSlow(value: boolean)
	if typeof(value) ~= "boolean" then return end
	if self._noSlow == value then return end

	self._noSlow = value

	if not value then return end

	task.spawn(function()
		while self._noSlow do
			task.wait(0.1)

			if not Character then return end

			local slowed = Character:FindFirstChild("Slowed")

			if slowed then
				slowed:Destroy()
				slowed = nil
			end
		end
	end)
end

function exploits:SetNoFatigue(value: boolean)
	if typeof(value) ~= "boolean" then return end
	
	self._noFatigue = value
	
	workspace:SetAttribute("NoFatigue", value)
end

function exploits:SetNoDashCooldown(value: boolean | number)
	if typeof(value) ~= "boolean" and typeof(value) ~= "number" then return end
	
	if typeof(value) == "number" then
		if value > 1 then
			value = 1
		else
			value = 0
		end
	end

	self._noDashCooldown = value

	workspace:SetAttribute("NoDashCooldown", value)
end

function exploits:SetNoJumpBypass(value: boolean)
	if typeof(value) ~= "boolean" then return end
	
	if self._noJumpBypass == value then return end
	
	self._noJumpBypass = value
	
	if not value then return end
	
	task.spawn(function()
		while self._noJumpBypass do
			task.wait(0.1)
			
			if not Character then return end
			
			local noJump = Character:FindFirstChild("NoJump")
			
			if noJump then
				noJump:Destroy()
				noJump = nil
			end
		end
	end)
end


-- [[ FLY ]]


function fly.new()
	local self = setmetatable({}, fly)

	self.CONTROL_MODULE = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

	assert(self.CONTROL_MODULE, "ControlModule not found, fatal error")

	self._state = false
	self._speed = 1

	self._rotation = {
		useX = false,
		useY = false,
		useZ = false,

		X = CFrame.Angles(math.rad(180), 0, 0),
		Y = CFrame.Angles(0, math.rad(180), 0),
		Z = CFrame.Angles(0, 0, math.rad(180)),
	}

	self._smoothness = 1200
	self._controlsUpAndDown = {Up = 0, Down = 0}
	self._usePlatformStand = true
	self._useKeyBindToggle = false

	self._keyBindings = {
		Up = Enum.KeyCode.E,
		Down = Enum.KeyCode.Q,
		EnableFly = Enum.KeyCode.F,
	}

	self.BodyVelocity = Instance.new("BodyVelocity")
	self.BodyGyro = Instance.new("BodyGyro")
	
	self.BodyVelocity.Name = "XDevFlyVelocity"
	self.BodyGyro.Name = "XDevFlyGyro"

	self.ControlsUpAndDownBeganConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if self._useKeyBindToggle then
			if typeof(self._keyBindings.EnableFly) == "EnumItem" and input.KeyCode == self._keyBindings.EnableFly then
				self:Set(not self._state)
			end
			print(1)
		end

		if input.KeyCode == self._keyBindings.Up then
			self._controlsUpAndDown.Up = 1
		elseif input.KeyCode == self._keyBindings.Down then
			self._controlsUpAndDown.Down = 1
		end
	end)

	self.ControlsUpAndDownEndedConn = UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == self._keyBindings.Up then
			self._controlsUpAndDown.Up = 0
		elseif input.KeyCode == self._keyBindings.Down then
			self._controlsUpAndDown.Down = 0
		end
	end)

	return self
end

function fly:ApplyAndUpdateGyroAndVelocity()
	if typeof(self.BodyVelocity) ~= "Instance" or not self.BodyVelocity:IsA("BodyVelocity") then
		self.BodyVelocity = Instance.new("BodyVelocity")
	end

	if typeof(self.BodyGyro) ~= "Instance" or not self.BodyGyro:IsA("BodyGyro") then
		self.BodyGyro = Instance.new("BodyGyro")
	end

	if not self._state then
		self.BodyVelocity:Destroy()
		self.BodyGyro:Destroy()
		return
	end

	if self.BodyVelocity and self.BodyVelocity.Parent ~= HumanoidRootPart then
		self.BodyVelocity.Parent = HumanoidRootPart
	end

	if self.BodyGyro and self.BodyGyro.Parent ~= HumanoidRootPart then
		self.BodyGyro.Parent = HumanoidRootPart
	end
end

function fly:_GetSpeed(): number
	return self._speed * 35
end

function fly:GetSpeed(): number
	return self._speed
end

function fly:GetKeyBindToEnableFly(): Enum.KeyCode
	return self._keyBindings.EnableFly
end

function fly:UseKeyBindToEnableFly(bool: boolean)
	self._useKeyToggle = bool
end

function fly:SetKeyBindToEnableFly(keyCode: Enum.KeyCode)
	if typeof(keyCode) ~= "EnumItem" then return end

	self._keyBindings.EnableFly = keyCode 
end

function fly:SetValueOfAxis(axis, value)
	if typeof(value) ~= "number" then return end
	if typeof(axis) ~= "string" then return end

	axis = string.upper(axis)

	if axis == "X" then
		self._rotation.X = CFrame.Angles(math.rad(value), 0, 0)
	elseif axis == "Y" then
		self._rotation.Y = CFrame.Angles(0, math.rad(value), 0)
	elseif axis == "Z" then
		self._rotation.Z = CFrame.Angles(0, 0, math.rad(value))
	end
end

function fly:_GetRotationForGryo(): CFrame

	local rotation = CurrentCamera.CFrame or workspace.CurrentCamera.CFrame

	if self._rotation.useX then
		rotation *= self._rotation.X
	end

	if self._rotation.useY then
		rotation *= self._rotation.Y
	end

	if self._rotation.useZ then
		rotation *= self._rotation.Z
	end

	return rotation
end

function fly:Set(value: boolean, speed: number?)
	if typeof(value) ~= "boolean" then return end

	if typeof(speed) == "number" then
		self._speed = speed
	end

	if self._state == value then return end

	self:ApplyAndUpdateGyroAndVelocity()

	self._state = value

	if not value then
		return
	end

	task.spawn(function()
		while self._state do

			task.wait()

			if not LocalPlayer.Character then return end

			if self._usePlatformStand then
				if Humanoid then Humanoid.PlatformStand = true end
			else
				if Humanoid then Humanoid.PlatformStand = false end
			end

			self:ApplyAndUpdateGyroAndVelocity()

			local moveVector = self.CONTROL_MODULE:GetMoveVector()

			local direction = (CurrentCamera or workspace.CurrentCamera).CFrame.RightVector * moveVector.X - (CurrentCamera or workspace.CurrentCamera).CFrame.LookVector * moveVector.Z
			local up = self._controlsUpAndDown.Up - self._controlsUpAndDown.Down

			self.BodyVelocity.Velocity = direction * self:_GetSpeed() + Vector3.new(0, up * self:_GetSpeed(), 0)
			self.BodyVelocity.MaxForce = VECTOR3_INF

			self.BodyGyro.MaxTorque = VECTOR3_INF
			self.BodyGyro.P = 9e4
			self.BodyGyro.D = self._smoothness

			self.BodyGyro.CFrame = self:_GetRotationForGryo()
		end

		if Humanoid then Humanoid.PlatformStand = false end
		self:ApplyAndUpdateGyroAndVelocity()
	end)
end

function fly:SetSpeed(value: number)
	if typeof(value) ~= "number" then return end
	self._speed = value
end

function fly:SetAxisEnabled(axis: string, value: boolean)
	if typeof(value) ~= "boolean" then return end
	if typeof(axis) ~= "string" then return end

	axis = string.upper(axis)

	if axis == "X" then
		self._rotation.useX = value
	elseif axis == "Y" then
		self._rotation.useY = value
	elseif axis == "Z" then
		self._rotation.useZ = value
	end

end


function fly:SetSmoothness(value: number)
	if typeof(value) ~= "number" then return end
	self._smoothness = value
end

function fly:GetSmoothness(): number
	return self._smoothness
end

function fly:UsePlatformStand(value: boolean)
	if typeof(value) ~= "boolean" then return end
	self._usePlatformStand = value
end

function fly:GetPlatformStand(): boolean
	return self._usePlatformStand
end

function fly:DisableAllAxis()
	self._rotation.useX = false
	self._rotation.useY = false
	self._rotation.useZ = false
end


-- [[ ESP ]]

function esp.new()
	local self = setmetatable({}, esp)
	
	return self
end

return xdev.new()
