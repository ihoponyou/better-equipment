
-- allows clients to request interaction with equipment (server)

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Component = require(ReplicatedStorage.Packages.Component)
local Trove = require(ReplicatedStorage.Packages.Trove)

local Viewmodel = Component.new({
    Tag = "Viewmodel";
})

function Viewmodel:Construct()
    self._trove = Trove.new()

    self.Visible = false
    self.Instance.Parent = workspace.CurrentCamera

    self._trove:Connect(self.Instance.DescendantAdded, function(descendant: Instance)
        if descendant:IsA("Accessory") then
            task.wait() -- hacky
            descendant:Destroy()
        end
    end)
end

function Viewmodel:Start()
    self:ToggleVisibility(self.Visible)
end

function Viewmodel:Stop()
    self._trove:Destroy()
end

function Viewmodel:RenderSteppedUpdate(_dt)
    self.Instance:PivotTo(workspace.CurrentCamera.CFrame)
end

function Viewmodel:ToggleVisibility(visible: boolean)
    self.Instance["Left Arm"].Transparency = if visible then 0 else 1
    self.Instance["Right Arm"].Transparency = if visible then 0 else 1
end

return Viewmodel
