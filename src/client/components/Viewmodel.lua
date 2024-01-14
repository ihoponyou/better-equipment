
-- allows clients to request interaction with equipment (server)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Knit = require(ReplicatedStorage.Packages.Knit)

local CameraController

local Viewmodel = Component.new({
    Tag = "Viewmodel";
})

function Viewmodel:Construct()
    Knit.OnStart():andThen(function()
        CameraController = Knit.GetController("CameraController")
    end, warn):await()

    self.Visible = false
    self.Instance.Parent = workspace.CurrentCamera
end

function Viewmodel:Start()
    self:ToggleVisibility(self.Visible)
end

function Viewmodel:RenderSteppedUpdate(_dt)
    self.Instance:PivotTo(workspace.CurrentCamera.CFrame)
end

function Viewmodel:ToggleVisibility(visible: boolean)
    self.Instance["Left Arm"].Transparency = if visible then 0 else 1
    self.Instance["Right Arm"].Transparency = if visible then 0 else 1
end

return Viewmodel
