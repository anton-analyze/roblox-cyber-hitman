--!strict
-- Effet de pluie cyberpunk (ParticleEmitter sur un Part invisible
-- planant au-dessus de la ville, qui drop des particules vers le bas).

local Workspace = game:GetService("Workspace")

local Rain = {}

function Rain.apply()
	-- Reset si rebuild
	local existing = Workspace:FindFirstChild("RainEmitter")
	if existing then
		existing:Destroy()
	end

	local emitter = Instance.new("Part")
	emitter.Name = "RainEmitter"
	emitter.Size = Vector3.new(220, 1, 220)
	emitter.Position = Vector3.new(0, 90, 0) -- au-dessus de la ville
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.CastShadow = false
	emitter.Transparency = 1 -- invisible

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "RainParticles"
	particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particles.Color = ColorSequence.new(Color3.fromRGB(160, 180, 220))
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(1, 0.05),
	})
	particles.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.3),
		NumberSequenceKeypoint.new(0.7, 0.5),
		NumberSequenceKeypoint.new(1, 1),
	})
	particles.Lifetime = NumberRange.new(1.2, 1.6)
	particles.Rate = 250
	particles.Speed = NumberRange.new(60, 90)
	particles.Acceleration = Vector3.new(0, -50, 0)
	particles.Rotation = NumberRange.new(0, 0)
	particles.RotSpeed = NumberRange.new(0, 0)
	particles.SpreadAngle = Vector2.new(2, 2)
	particles.LightEmission = 0.6
	particles.LightInfluence = 0
	particles.EmissionDirection = Enum.NormalId.Bottom
	particles.Parent = emitter

	emitter.Parent = Workspace
end

return Rain
