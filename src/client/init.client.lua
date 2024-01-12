local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Loader = require(ReplicatedStorage.Packages.Loader)
local Knit = require(ReplicatedStorage.Packages.Knit)

Knit.Start():andThen(function()
    -- print("Knit started.")
    Loader.LoadChildren(script.components)
end):catch(warn)