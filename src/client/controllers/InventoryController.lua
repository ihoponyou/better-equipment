
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local InventoryService

local EquipmentClient = require(script.Parent.Parent.components.EquipmentClient)

local InventoryController = Knit.CreateController({
    Name = "InventoryController",

    Inventory = {},

    ActiveSlot = nil,
    ActiveSlotChanged = Signal.new()
})

function InventoryController:_tryEquip(slot: string)
    local currentItem = self.Inventory[self.ActiveSlot]
    if currentItem ~= nil then
        local equipment = EquipmentClient:FromInstance(currentItem)
        equipment:Unequip()

        if slot == self.ActiveSlot then
            self:SetActiveSlot(nil)
            return
        end
    end

    local newItem = self.Inventory[slot]
    if not newItem then return end
    local equipment = EquipmentClient:FromInstance(newItem)
    equipment:Equip()
    self:SetActiveSlot(equipment.Config.SlotType)
end

function InventoryController:_tryDrop()
    local currentItem = self.Inventory[self.ActiveSlot]
    if currentItem ~= nil then
        local equipment = EquipmentClient:FromInstance(currentItem)
        equipment:Drop()
    end
end

function InventoryController:KnitInit()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.One then
            self:_tryEquip("Primary")
        elseif input.KeyCode == Enum.KeyCode.Two then
            self:_tryEquip("Secondary")
        elseif input.KeyCode == Enum.KeyCode.Three then
            self:_tryEquip("Tertiary")
        elseif input.KeyCode == Enum.KeyCode.G then
            self:_tryDrop()
        end
    end)
end

function InventoryController:KnitStart()
    InventoryService = Knit.GetService("InventoryService")

    InventoryService.InventoryChanged:Connect(function(...)
        self.Inventory = ...
    end)
end

function InventoryController:SetActiveSlot(slot: string)
    self.ActiveSlot = slot
    self.ActiveSlotChanged:Fire(slot)
end

return InventoryController
