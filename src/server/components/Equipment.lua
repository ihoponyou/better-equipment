local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

local InventoryService = Knit.GetService("InventoryService")

local EquipmentConfig = require(ReplicatedStorage.Shared.EquipmentConfig)

local Equipment = Component.new({
	Tag = "Equipment",
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
			if self.Owner ~= nil then
				InventoryService:RemoveEquipment(self.Owner, self)
			end
			self.Instance:Destroy()
		end
	end)

	-- PICK UP / DROP ----------------------------------------------------
	self.IsPickedUp = self._serverComm:CreateProperty("IsPickedUp", false)

	self.PickUpRequest = self._serverComm:CreateSignal("PickUpRequest")

	self.PickUpPrompt = self._trove:Construct(Instance, "ProximityPrompt") :: ProximityPrompt
	self.PickUpPrompt.Parent = self.WorldModel
	self.PickUpPrompt.Triggered:Connect(function(playerWhoTriggered)
		self:PickUp(playerWhoTriggered)
	end)

	self.DropRequest = self._serverComm:CreateSignal("DropRequest")

	self._trove:Connect(self.DropRequest, function(player)
		self:Drop(player)
	end)

	-- EQUIP / UNEQUIP ----------------------------------------------------
	self.IsEquipped = self._serverComm:CreateProperty("IsEquipped", false)

	self.EquipRequest = self._serverComm:CreateSignal("EquipRequest")
	self._trove:Connect(self.EquipRequest, function(player: Player)
		self:Equip(player)
	end)

	self.UnequipRequest = self._serverComm:CreateSignal("UnequipRequest")
	self._trove:Connect(self.UnequipRequest, function(player: Player)
		self:Unequip(player)
	end)
end

function Equipment:Stop()
	self._trove:Destroy()
end

-- MISC ----------------------------------------------------------------

function Equipment:_newRootJoint(): Motor6D
	local rootJoint = Instance.new("Motor6D")
	rootJoint.Name = "RootJoint"
	rootJoint.Parent = self.WorldModel.PrimaryPart
	rootJoint.Part1 = self.WorldModel.PrimaryPart
	return rootJoint
end

function Equipment:RigTo(character: Model, limb: string)
	if not character then error("nil character") end

	local rootJoint = self.WorldModel.PrimaryPart:FindFirstChild("RootJoint")
	if not rootJoint then
		warn(self.Instance.Name..": RootJoint has been presumed dead")
		rootJoint = self:_newRootJoint()
	end

	local limbPart = character:FindFirstChild(limb)
	if not limbPart then error("nil " .. limb) end

	self.WorldModel.Parent = character
	rootJoint.Part0 = limbPart
end

function Equipment:Unrig()
	local rootJoint = self.WorldModel.PrimaryPart:FindFirstChild("RootJoint")
	if not rootJoint then
		warn("RootJoint has been presumed dead")
		rootJoint = self:_newRootJoint()
	end

	self.WorldModel.Parent = self.Instance
	rootJoint.Part0 = nil
end

-- PICK UP / DROP ----------------------------------------------------

function Equipment:PickUp(player: Player)
	if self.Owner ~= nil then return end
	local success = InventoryService:AddEquipment(player, self)
	if not success then return end

	self.Owner = player

	self:RigTo(player.Character, self.Config.HolsterLimb)

	self.PickUpPrompt.Enabled = false
	self.IsPickedUp:Set(true)
end

function Equipment:Drop(player: Player)
	if self.Owner ~= player then return end
	local success = InventoryService:RemoveEquipment(self.Owner, self)
	if not success then return end

	if self.IsEquipped:Get() then
		print("forced unequip")
		self:Unequip()
	end

	self.Owner = nil

	self:Unrig()

	self.PickUpPrompt.Enabled = true
	self.IsPickedUp:Set(false)
end

-- EQUIP / UNEQUIP ----------------------------------------------------

function Equipment:Equip(player: Player)
	if self.Owner ~= player then return end
	self:RigTo(self.Owner.Character, "Right Arm")

	self.IsEquipped:Set(true)
end

function Equipment:Unequip(player: Player)
	if self.Owner ~= player then return end
	self:RigTo(self.Owner.Character, self.Config.HolsterLimb)

	self.IsEquipped:Set(false)
end

return Equipment
