
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

local InventoryService = Knit.GetService("InventoryService")

local EquipmentConfig = require(ReplicatedStorage.Shared.EquipmentConfig)

local Equipment = Component.new({
	Tag = "Equipment";
})

function Equipment:Construct()
	self._trove = Trove.new()
	self._serverComm = self._trove:Construct(Comm.ServerComm, self.Instance)

	self.Config = EquipmentConfig[self.Instance.Name]

	self.WorldModel = self._trove:Clone(ReplicatedStorage.Equipment[self.Instance.Name].WorldModel)
	self.WorldModel.Parent = self.Instance
	-- destroy component if worldmodel is destroyed or drop if character is destroyed
	self._trove:Connect(self.WorldModel.AncestryChanged, function(child, parent)
		-- only consider when things are destroyed
		if parent ~= nil then return end

		if child ~= self.WorldModel then
			-- owner died/left
			self:Drop()
		else
			-- worldmodel DESTROYED!!!!!
			InventoryService:RemoveEquipment(self.Owner, self)
			self.Instance:Destroy()
		end
	end)

	-- PICK UP / DROP ----------------------------------------------------
	self.IsPickedUp = self._serverComm:CreateProperty("IsPickedUp", false)

	self.PickedUp = self._serverComm:CreateSignal("PickedUp")

	self.PickUpPrompt = self._trove:Construct(Instance, "ProximityPrompt") :: ProximityPrompt
    self.PickUpPrompt.Triggered:Connect(function(playerWhoTriggered)
        local success = self:PickUp(playerWhoTriggered)
		if success then
			self.PickedUp:Fire(playerWhoTriggered)
		end
    end)
	self.PickUpPrompt.Parent = self.WorldModel

	self.Dropped = self._serverComm:CreateSignal("Dropped")

	self._trove:Connect(self.Dropped, function(player)
		if self.Owner ~= player then return end
		local success = self:Drop()
		if success then
			-- cant use owner since it will be nil
			self.Dropped:Fire(player)
		end
	end)

	-- EQUIP / UNEQUIP ----------------------------------------------------
	self.IsEquipped = self._serverComm:CreateProperty("IsEquipped", false)

	self.Equipped = self._serverComm:CreateSignal("Equipped")
	self._trove:Connect(self.Equipped, function(player: Player)
		if self.Owner ~= player then return end
		local success = self:Equip()
		if success then
			self.Equipped:Fire(self.Owner)
		end
	end)

	self.Unequipped = self._serverComm:CreateSignal("Unequipped")
	self._trove:Connect(self.Unequipped, function(player: Player)
		if self.Owner ~= player then return end
		local success = self:Unequip()
		if success then
			self.Unequipped:Fire(self.Owner)
		end
	end)
end

function Equipment:Stop()
	self._trove:Destroy()
end

function Equipment:RigToCharacter(character: Model, limb: string)
	if not character then error("nil character") end

	local rootJoint = self.WorldModel.PrimaryPart:FindFirstChild("RootJoint")
	if not rootJoint then error("nil RootJoint") end

	local limbPart = character:FindFirstChild(limb)
	if not limbPart then error("nil "..limb) end

	self.WorldModel.Parent = character
	rootJoint.Part0 = limbPart
end

function Equipment:Unrig()
	local rootJoint = self.WorldModel.PrimaryPart:FindFirstChild("RootJoint")
	if not rootJoint then
		warn("RootJoint has been presumed dead")
		rootJoint = Instance.new("Motor6D")
		rootJoint.Name = "RootJoint"
		rootJoint.Parent = self.WorldModel.PrimaryPart
		rootJoint.Part1 = self.WorldModel.PrimaryPart
	end

	self.WorldModel.Parent = self.Instance
	rootJoint.Part0 = nil
end

-- PICK UP / DROP ----------------------------------------------------

function Equipment:PickUp(player: Player): boolean?
	local success = InventoryService:AddEquipment(player, self)
	if not success then return success end

	self.Owner = player

	self:RigToCharacter(player.Character, self.Config.HolsterLimb)

	self.PickUpPrompt.Enabled = false
	self.IsPickedUp:Set(true)

	return true
end

function Equipment:Drop(): boolean?
	if self.Owner ~= nil then
		local success = InventoryService:RemoveEquipment(self.Owner, self)
		if not success then return success end
	end

	if self.IsEquipped:Get() then self:Unequip() end

	self.Owner = nil

	self:Unrig()

	self.PickUpPrompt.Enabled = true
	self.IsPickedUp:Set(false)

	return true
end

-- EQUIP / UNEQUIP ----------------------------------------------------

function Equipment:Equip(): boolean?
	self:RigToCharacter(self.Owner.Character, "Right Arm")

	self.IsEquipped:Set(true)

	return true
end

function Equipment:Unequip(): boolean?
	self:RigToCharacter(self.Owner.Character, self.Config.HolsterLimb)

	self.IsEquipped:Set(false)

	return true
end

return Equipment
