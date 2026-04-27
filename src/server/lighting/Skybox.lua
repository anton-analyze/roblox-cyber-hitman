--!strict
-- Ciel cyberpunk étoilé + Mont Fuji holographique au loin.

local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Skybox = {}

local function makePart(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.CanCollide = false
	part.CastShadow = false
	part.Transparency = 0.4 -- effet holographique
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

-- Crée un Sky avec étoiles + ciel sombre violet.
local function applySky()
	-- Supprime le Sky existant si présent
	for _, child in Lighting:GetChildren() do
		if child:IsA("Sky") then
			child:Destroy()
		end
	end

	local sky = Instance.new("Sky")
	sky.StarCount = 3000 -- max
	sky.SkyboxBk = "rbxasset://textures/sky/sky512_bk.tex"
	sky.SkyboxDn = "rbxasset://textures/sky/sky512_dn.tex"
	sky.SkyboxFt = "rbxasset://textures/sky/sky512_ft.tex"
	sky.SkyboxLf = "rbxasset://textures/sky/sky512_lf.tex"
	sky.SkyboxRt = "rbxasset://textures/sky/sky512_rt.tex"
	sky.SkyboxUp = "rbxasset://textures/sky/sky512_up.tex"
	sky.SunAngularSize = 0
	sky.MoonAngularSize = 5
	sky.CelestialBodiesShown = true
	sky.Parent = Lighting
end

-- Mont Fuji holographique : pyramide / cône stylisé en Wedge, lointain, transparent.
local function buildMtFuji(parent: Instance)
	-- Position : très loin au sud (Z = -350), gros, Material ForceField pour effet holo.
	local fujiContainer = Instance.new("Model")
	fujiContainer.Name = "MtFuji_Holo"

	local centerX = 0
	local centerZ = -350
	local baseY = -10 -- légèrement enfoncé pour cacher la base
	local color = Color3.fromRGB(120, 200, 255) -- cyan holo

	-- Construction par 4 "couches" empilées (cône pyramidal)
	local layers = {
		{ size = Vector3.new(180, 30, 180), y = baseY + 15 },
		{ size = Vector3.new(140, 30, 140), y = baseY + 45 },
		{ size = Vector3.new(95, 30, 95), y = baseY + 75 },
		{ size = Vector3.new(50, 30, 50), y = baseY + 100 },
		{ size = Vector3.new(20, 20, 20), y = baseY + 125 },
	}

	for i, layer in layers do
		local part = makePart(
			string.format("FujiLayer_%d", i),
			layer.size,
			Vector3.new(centerX, layer.y, centerZ),
			color,
			Enum.Material.ForceField
		)
		part.Parent = fujiContainer
	end

	-- Sommet enneigé blanc holo
	local snowCap = makePart(
		"SnowCap",
		Vector3.new(15, 8, 15),
		Vector3.new(centerX, baseY + 140, centerZ),
		Color3.fromRGB(220, 240, 255),
		Enum.Material.Neon
	)
	snowCap.Transparency = 0.3
	snowCap.Parent = fujiContainer

	fujiContainer.Parent = parent
end

function Skybox.apply()
	applySky()
	-- Reset le container Mt Fuji si rebuild
	local existing = Workspace:FindFirstChild("MtFuji_Holo")
	if existing then
		existing:Destroy()
	end
	buildMtFuji(Workspace)
end

return Skybox
