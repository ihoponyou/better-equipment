--!strict

local ModelUtil = {}

local function validateModel(model: Model?)
	if typeof(model) ~= "Instance" then
		error("model is nil or incorrect type")
	end
	if model.ClassName ~= "Model" then
		error("model is not a model")
	end
end

local function iterateModel(model: Model, operation: (part: BasePart) -> nil)
	for _, part in model:GetDescendants() do
		if not part:IsA("BasePart") then continue end
		operation(part)
	end
end

function ModelUtil.SetPartProperty(model: Model, property: string, value: any)
	validateModel(model)

	local testPart = Instance.new("Part")
	-- check if property exists
	local success, result = pcall(function()
		return typeof(testPart[property])
	end)
	if not success then error(result) end
	-- check if given value matches property's type
	if typeof(value) ~= result then error("type mismatch") end
	-- check class?

	iterateModel(model, function(part)
		part[property] = value
	end)

	testPart:Destroy()
end

return ModelUtil
