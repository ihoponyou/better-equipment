
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Comm = require(ReplicatedStorage.Packages.Comm)

local InventoryService = Knit.GetService("InventoryService")
local serverComm = Comm.ServerComm.new(ReplicatedStorage.Comm, "EquipmentComm")

local EquipmentConfig = require(ReplicatedStorage.Shared.EquipmentConfig)

local Equipment = Component.new({
	Tag = "Equipment";
})

function Equipment:Construct()
	self._trove = Trove.new()

	self.Config = EquipmentConfig[self.Instance.Name]

	self.WorldModel = self._trove:Clone(ReplicatedStorage.Equipment[self.Instance.Name].WorldModel) :: Model
	self.WorldModel.Parent = self.Instance

	self.IsEquipped = false
	self.EquipRequest = serverComm:CreateSignal("EquipRequest")
	self.EquipRequest:Connect(function(player, equipping)
		if equipping then
			self:Equip(player)
		else
			self:Unequip(player)
		end
	end)

	self.IsPickedUp = false
	self.PickUpRequest = serverComm:CreateSignal("PickUpRequest")
	self.PickUpRequest:Connect(function(player, pickingUp)
		local success = InventoryService:PickUp(player, self, pickingUp)
		if not success then return end
		if pickingUp then
			self:_onPickUp(player)
		else
			self:_onDrop()
		end
	end)
end

function Equipment:Equip(player: Player)
	if self.Owner ~= player then return end
	if self.IsEquipped then return end
	print("equip")

	self.IsEquipped = true
	self.WorldModel.Parent = self.Owner.Character
	self.WorldModel.PrimaryPart.RootJoint.Part0 = self.Owner.Character.PrimaryPart

	self.EquipRequest:Fire(player, true)
end

function Equipment:Unequip(player: Player)
	if self.Owner ~= player then return end
	if not self.IsEquipped then return end
	print("unequip")

	self.IsEquipped = false
	self.WorldModel.Parent = self.Instance
	self.WorldModel.PrimaryPart.RootJoint.Part0 = nil

	self.EquipRequest:Fire(player, false)
end

function Equipment:_onDeath()
	if self.Owner.Character:GetPivot().Position.Y < workspace.FallenPartsDestroyHeight then
		InventoryService:PickUp(self.Owner, self, false)
		self.Instance:Destroy()
	else
		InventoryService:PickUp(self.Owner, self, false)
		self:_onDrop()
	end
end

function Equipment:_onPickUp(player: Player)
	print'pickup'

	self.IsPickedUp = true
	self.Owner = player

	self._deathConn = self._trove:Connect(self.Owner.CharacterRemoving, function(_)
		self:_onDeath()
	end)

	self.Instance.Parent = player:FindFirstChild("Inventory")
	
	self.PickUpRequest:Fire(self.Owner, true)
end

function Equipment:_onDrop()
	print'drop'

	if self.IsEquipped then
		self:Unequip(self.Owner)
	end
	
	self.IsPickedUp = false
	local oldOwner = self.Owner
	self.Owner = nil
	
	self._deathConn:Disconnect()
	self._deathConn = nil
	
	self.Instance.Parent = workspace

	self.PickUpRequest:Fire(oldOwner, false)
end

function Equipment:Stop()
	self.Owner = nil
	self._trove:Destroy()
end

return Equipment
