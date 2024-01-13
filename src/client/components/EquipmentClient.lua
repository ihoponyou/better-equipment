
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local EquipmentConfig = require(ReplicatedStorage.Shared.EquipmentConfig)

local EquipmentClient = Component.new({
    Tag = "Equipment";
})

function EquipmentClient:Construct()
    self._trove = Trove.new()
    self._clientComm = self._trove:Construct(Comm.ClientComm, self.Instance)

    self.Config = EquipmentConfig[self.Instance.Name]

    self.WorldModel = self.Instance:WaitForChild("WorldModel")

    self.IsPickedUp = self._clientComm:GetProperty("IsPickedUp")
    self.PickUpRequest = self._clientComm:GetSignal("PickUpRequest")
    self.DropRequest = self._clientComm:GetSignal("DropRequest")

    self.IsEquipped = self._clientComm:GetProperty("IsEquipped")
    -- self.IsEquipped:Observe(function(isEquipped: boolean)
        -- print(self.Instance.Name.." equipped", isEquipped)
    -- end)
    self.EquipRequest = self._clientComm:GetSignal("EquipRequest")
    self.UnequipRequest = self._clientComm:GetSignal("UnequipRequest")
end

function EquipmentClient:Equip()
    if self.IsPickedUp:Get() then
        self.EquipRequest:Fire()
    end
end

function EquipmentClient:Unequip()
    if self.IsPickedUp:Get() then
        self.UnequipRequest:Fire()
    end
end

function EquipmentClient:Drop()
    if self.IsPickedUp:Get() then
        self.DropRequest:Fire()
    end
end

return EquipmentClient
