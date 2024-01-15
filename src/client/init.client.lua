local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Knit = require(ReplicatedStorage.Packages.Knit)

Loader.LoadDescendants(script.controllers, Loader.MatchesName("Controller$"))

Knit.Start():andThen(function()
    -- print("Knit started.")
    Loader.LoadChildren(script.components)
end, warn)