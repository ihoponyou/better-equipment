
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local Viewmodel = require(script.Parent.Parent.components.Viewmodel)

local ViewmodelController = Knit.CreateController({
    Name = "ViewmodelController",

    Viewmodel = nil
})

function ViewmodelController:KnitInit()
    Knit.Player.CharacterAdded:Connect(function(character)
        local clone = ReplicatedStorage.Viewmodel:Clone()
        clone.Parent = Knit.Player
        CollectionService:AddTag(clone, "Viewmodel")

        Viewmodel:WaitForInstance(clone):andThen(function(component)
            self.Viewmodel = component
            component.Stopped:Once(function()
                self.Viewmodel = nil
            end)
        end)
    end)

    Knit.Player.CharacterRemoving:Connect(function(character)
        self.Viewmodel.Instance:Destroy()
    end)
end

return ViewmodelController
