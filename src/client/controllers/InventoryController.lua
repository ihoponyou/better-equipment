
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

function InventoryController:KnitInit()
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.One then
            local primary = self.Inventory["Primary"]
            if not primary then return end
            local equipment = EquipmentClient:FromInstance(primary)
            if equipment.IsEquipped:Get() then
                equipment:Unequip()
            else
                equipment:Equip()
            end
        end
    end)
end

function InventoryController:KnitStart()
    InventoryService = Knit.GetService("InventoryService")

    InventoryService.InventoryChanged:Connect(function(...)
        self.Inventory = ...
    end)
end

return InventoryController
