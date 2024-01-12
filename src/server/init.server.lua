local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Knit = require(ReplicatedStorage.Packages.Knit)

Loader.LoadDescendants(script.services, Loader.MatchesName("Service$"))

Knit.Start():andThen(function()
    -- print("Knit started.")
    Loader.LoadChildren(script.components)
end):catch(warn)

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local function OnPlayerAdded(player: Player)
    local sword = Instance.new("Model")
    CollectionService:AddTag(sword, "Equipment")
    sword.Name = "ClassicSword"
    sword.Parent = workspace
end

Players.PlayerAdded:Connect(OnPlayerAdded)