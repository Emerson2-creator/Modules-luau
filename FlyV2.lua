local fly = {}
fly.__index = fly

function fly.new()
	local self = setmetatable({}, fly)
	
	
	
	self.Players = game:GetService("Players")
	self.UserInputService = game:GetService("UserInputService")
	
	self.LocalPlayer = self.Players.LocalPlayer
	
	self.ControlModule = require(self.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))
	
	self.CurrentCamera = workspace.CurrentCamera
	self.Connections = {}
	
	self.character = nil
	self.humanoid = nil 
	self.humanoidRootPart = nil
	
	self.BodyVelocity = Instance.new("BodyVelocity")
	self.BodyGyro = Instance.new("BodyGyro")
	
	self.Controls = {Up = 0, Down = 0}
	
	self.Enabled = false
	self.ToggleBind = Enum.KeyCode.F
	self.Speed = 1
	self.UsePlatformStand = true
	
	-- self.Connections.CharacterAdded = self.LocalPlayer.CharacterAdded:Connect(function(character)
	-- 	self.character = character
	-- 	self.humanoid = self.character:WaitForChild("Humanoid")
	-- 	self.humanoidRootPart = self.character:WaitForChild("HumanoidRootPart")
		
	-- end)

	task.spawn(function()
		while self.LocalPlayer.Parent and task.wait() do 
			self.character = self.LocalPlayer.Character
			self.humanoid = self.character and self.character:FindFirstChildOfClass("Humanoid")
			self.humanoidRootPart = self.character and self.character:FindFirstChild("HumanoidRootPart")
		end
	end)
	
	self.Connections.ControlsInputBegan = self.UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == self.ToggleBind then
			self:Fly(not self.Enabled)
		end
		if input.KeyCode == Enum.KeyCode.E then
			self.Controls.Up = 1
		elseif input.KeyCode == Enum.KeyCode.Q then
			self.Controls.Down = 1
		end
	end)
	
	self.Connections.ControlsInputEnded= self.UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		
		if input.KeyCode == Enum.KeyCode.E then
			self.Controls.Up = 0
		elseif input.KeyCode == Enum.KeyCode.Q then
			self.Controls.Down = 0
		end
	end)

	
	return self
end

function fly:SetToggleBind(bind: Enum.KeyCode | nil)
	if bind ~= nil and typeof(bind) ~= "EnumItem" then
		return
			
	elseif typeof(bind) == "EnumItem" and  bind.EnumType ~= Enum.KeyCode then
		return
	end
	
	self.ToggleBind = bind
end

function fly:SetSpeed(speed: number)
	if typeof(speed) ~= "number" then return end
	
	self.Speed = speed
end

function fly:GetSpeed(): number
	return self.Speed
end

function fly:ApplyAndUpDateBvBg()
	if typeof(self.BodyVelocity) ~= "Instance" or not self.BodyVelocity:IsA("BodyVelocity") then
		self.BodyVelocity = Instance.new("BodyVelocity")
	end
	if typeof(self.BodyGyro) ~= "Instance" or not self.BodyGyro:IsA("BodyGyro") then
		self.BodyGyro = Instance.new("BodyGyro")
	end
	
	self.BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	self.BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	self.BodyGyro.P = 9e4
	self.BodyGyro.D = 600
	
	if not self.Enabled then
		if self.BodyVelocity:IsDescendantOf(game) then
			self.BodyVelocity.Parent = nil
		end
		if self.BodyGyro:IsDescendantOf(game) then
			self.BodyGyro.Parent = nil
		end
		return
	end

	if not self.humanoidRootPart then return end
	
	local success, err = pcall(function()
		self.BodyVelocity.Parent = self.humanoidRootPart
		self.BodyGyro.Parent = self.humanoidRootPart
	end)
	
	if not success then
		warn("Failed to parent BodyVelocity or BodyGyro: " .. tostring(err))
		

		if typeof(self.BodyVelocity) == "Instance" then
			self.BodyVelocity:Destroy()
		end

		if typeof(self.BodyGyro) == "Instance" then
			self.BodyGyro:Destroy()
		end

		self.BodyVelocity = Instance.new("BodyVelocity")
		self.BodyGyro = Instance.new("BodyGyro")

		self.BodyVelocity.Parent = self.humanoidRootPart
		self.BodyGyro.Parent = self.humanoidRootPart
	end
	
end

function fly:Fly(value: boolean?)
	if value ~= nil and typeof(value) ~= "boolean" then
		return
	elseif value == nil then
		value = not self.Enabled
	end
	
	if value == self.Enabled then
		return
	end
	
	self.Enabled = value
	
	task.spawn(function()
		while self.Enabled and task.wait() do
			if not self.character or not self.humanoid or not self.humanoidRootPart then continue end
				
			if self.UsePlatformStand then
				self.humanoid.PlatformStand = true
			end
			
			self:ApplyAndUpDateBvBg()
			
			local MoveVector = self.ControlModule:GetMoveVector()
			local Direction = self.CurrentCamera.CFrame.RightVector * MoveVector.X - self.CurrentCamera.CFrame.LookVector * MoveVector.Z
			local Up = self.Controls.Up - self.Controls.Down
			
			self.BodyVelocity.Velocity = Direction * self:GetSpeed() * 30  + Vector3.new(0, Up * self:GetSpeed() * 30, 0)
			self.BodyGyro.CFrame = self.CurrentCamera.CFrame
		end
		
		if self.UsePlatformStand and self.humanoid.PlatformStand then
			self.humanoid.PlatformStand = false
		end
	end)
	
	
end



function fly:Destroy()
	self:Fly(false)
	
	for _, connection in pairs(self.Connections) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
			self.Connections[connection] = nil
		end
	end
	
	if typeof(self.BodyVelocity) == "Instance" then
		self.BodyVelocity:Destroy()
		self.BodyVelocity = nil
	end
	
	if typeof(self.BodyGyro) == "Instance" then
		self.BodyGyro:Destroy()
		self.BodyGyro = nil
	end
end

return fly.new()
