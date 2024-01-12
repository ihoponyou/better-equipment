
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Comm = require(ReplicatedStorage.Packages.Comm)
local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local clientComm = Comm.ClientComm.new(ReplicatedStorage.Comm, true, "EquipmentComm")

local EquipmentClient = Component.new({
    Tag = "Equipment";
})

function EquipmentClient:Construct()
    self._trove = Trove.new()

    self.PickUpPrompt = self._trove:Add(Instance.new("ProximityPrompt")) :: ProximityPrompt
	self.PickUpPrompt.Parent = self.Instance
    self.PickUpPrompt.RequiresLineOfSight = false

    self._equipped = false
    self.EquipRequest = clientComm:GetSignal("EquipRequest")
    self.PickUpRequest = clientComm:GetSignal("PickUpRequest")

    self.PickUpPrompt.Triggered:Connect(function()
		self.PickUpRequest:Fire(true)
	end)
end

function EquipmentClient:Start()
    self.EquipRequest:Connect(function()
        self:_onEquipped()
    end)
    self.PickUpRequest:Connect(function(pickedUp)
        if pickedUp then
            self:_onPickUp()
        else
            self:_onDrop()
        end
    end)
end

function EquipmentClient:Stop()
    self._trove:Destroy()
end

function EquipmentClient:_onEquipped()
    print('equip')
end

function EquipmentClient:_onPickUp()
    print('picked up')
    ContextActionService:BindAction("equip", function(_, uis, _)
        if uis ~= Enum.UserInputState.Begin then return end
        self._equipped = not self._equipped
        self.EquipRequest:Fire(self._equipped)
    end, false, Enum.KeyCode.One)
    ContextActionService:BindAction("drop", function(_, uis, _)
        if uis ~= Enum.UserInputState.Begin then return end
        self.PickUpRequest:Fire(false)
    end, false, Enum.KeyCode.G)
end

function EquipmentClient:_onDrop()
    print('drop')
    ContextActionService:UnbindAction("equip")
    ContextActionService:UnbindAction("drop")
end

return EquipmentClient
