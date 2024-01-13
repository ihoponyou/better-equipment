
local function fromOrientationDeg(x: number, y: number, z: number): CFrame
  return CFrame.Angles(math.rad(x), math.rad(y), math.rad(z))
end

return {
	ClassicSword = {
		SlotType = "Primary",
		HolsterLimb = "Torso",
    RootJointC0 = {
      Holstered = CFrame.new(-1.1, -1.393, 0.148) * fromOrientationDeg(30, 0, 90),
      Equipped = CFrame.new(0, -0.8, -1.456) * fromOrientationDeg(0, 180, 90)
    },
		Viewport = {
			ElementPosition = nil,
			ModelCFrame = CFrame.new(0.6, 0, -2) * fromOrientationDeg(0, -90, 90),
		},
	},
	ClassicKnife = {
		SlotType = "Secondary",
		HolsterLimb = "Torso",
    RootJointC0 = {
      Holstered = CFrame.new(1.1, -1.35, -0.3) * fromOrientationDeg(-15, 180, 180),
      Equipped = CFrame.new(0, -0.7, 1.01) * fromOrientationDeg(90, 0, 0)
    },
		Viewport = {
			ElementPosition = nil,
			-- ModelCFrame = CFrame.new(0.6, 0, -2) * CFrame.Angles(0, math.rad(-90), math.rad(90)),
		},
	},
}
