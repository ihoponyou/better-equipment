
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local EquipmentClient = Component.new({
    Tag = "Equipment";
})

function EquipmentClient:Construct()
    self._trove = Trove.new()
    self._clientComm = self._trove:Construct(Comm.ClientComm, self.Instance)

    self.WorldModel = self.Instance:WaitForChild("WorldModel")

    self.IsPickedUp = self._clientComm:GetProperty("IsPickedUp")
    self.PickedUp = self._clientComm:GetSignal("PickedUp")
    self.Dropped = self._clientComm:GetSignal("Dropped")

    self.IsEquipped = self._clientComm:GetProperty("IsEquipped")
    self.Equipped = self._clientComm:GetSignal("Equipped")
    self.Unequipped = self._clientComm:GetSignal("Unequipped")
end

function EquipmentClient:Equip()
    if self.IsPickedUp:Get() then
        self.Equipped:Fire()
    end
end

function EquipmentClient:Unequip()
    if self.IsPickedUp:Get() then
        self.Unequipped:Fire()
    end
end

return EquipmentClient
