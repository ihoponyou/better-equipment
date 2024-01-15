
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local function OnPlayerAdded(player: Player)
    local sword = Instance.new("Model")
    CollectionService:AddTag(sword, "Equipment")
    sword.Name = "ClassicSword"
    sword.Parent = workspace
    -- sword:SetAttribute("Log", true)
end

Players.PlayerAdded:Connect(OnPlayerAdded)
