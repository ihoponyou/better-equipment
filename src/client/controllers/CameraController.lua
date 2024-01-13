
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

local CameraController = Knit.CreateController({
    Name = "CameraController",

    InFirstPerson = false,
    AllowFirstPerson = true,
    PointOfViewChanged = Signal.new(),

    InCutscene = false,

    _playerModule = nil,
})

function CameraController:KnitInit()
    self._playerModule = require(Knit.Player.PlayerScripts:WaitForChild("PlayerModule"))
    self._playerModule:ToggleShiftLock(not self.InFirstPerson)

    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.V then
            self:TogglePointOfView()
        end
    end)
end

function CameraController:TogglePointOfView(firstPerson: boolean?)
    local enterFirstPerson = if firstPerson == nil then not self.InFirstPerson else firstPerson

    if not self.AllowFirstPerson and enterFirstPerson then return end

    -- print(self.InFirstPerson, "->", enterFirstPerson)
    self.InFirstPerson = enterFirstPerson

    if enterFirstPerson then
		Knit.Player.CameraMinZoomDistance = 0.5
		Knit.Player.CameraMaxZoomDistance = 0.5
	else
		Knit.Player.CameraMaxZoomDistance = 8
		Knit.Player.CameraMinZoomDistance = 4
	end

    self._playerModule:ToggleShiftLock(not enterFirstPerson)
end

return CameraController
