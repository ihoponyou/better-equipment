
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local CameraController

local Viewmodel = require(script.Parent.Parent.components.Viewmodel)

local ViewmodelController = Knit.CreateController({
    Name = "ViewmodelController",

    Viewmodel = nil
})

function ViewmodelController:KnitInit()
    self:CreateViewmodel()

    Knit.Player.CharacterAdded:Connect(function()
        self:CreateViewmodel()
    end)

    Knit.Player.CharacterRemoving:Connect(function()
        self.Viewmodel.Instance:Destroy()
    end)
end

function ViewmodelController:KnitStart()
    CameraController = Knit.GetController("CameraController")

    CameraController.PointOfViewChanged:Connect(function(inFirstPerson: boolean)
        self.Viewmodel:ToggleVisibility(inFirstPerson)
    end)
end

function ViewmodelController:CreateViewmodel()
    if self.Viewmodel then return end

    local newViewmodel = ReplicatedStorage.Viewmodel:Clone()
    newViewmodel.Parent = workspace.CurrentCamera
    local appearance = if Knit.Player.UserId > 0 then Players:GetHumanoidDescriptionFromUserId(Knit.Player.UserId) else ReplicatedStorage.test
    newViewmodel.RigHumanoid:ApplyDescriptionReset(appearance)
    CollectionService:AddTag(newViewmodel, "Viewmodel")

    local success, component = Viewmodel:WaitForInstance(newViewmodel):andThen(function(_component)
        return _component
    end, warn):await()

    if success then
        self.Viewmodel = component
    else
        error("didnt work")
    end
end

return ViewmodelController
