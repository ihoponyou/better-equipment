
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local function OnPlayerAdded(player: Player)
    local sword = Instance.new("Model")
    CollectionService:AddTag(sword, "Equipment")
    sword.Name = "ClassicSword"
    sword.Parent = workspace
end

Players.PlayerAdded:Connect(OnPlayerAdded)
