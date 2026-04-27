--!strict
-- Construit la ville cyberpunk programmatiquement.
-- Toute la géométrie de base (rue, trottoirs, passages piétons, bâtiments…)
-- vit ici, pas dans le fichier .rbxl. Avantage : Git diffs lisibles.

local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Buildings = require(ServerScriptService.Source.map.Buildings)

local MapBuilder = {}

-- Helper : crée un Part Anchored avec les propriétés données.
local function makePart(name: string, size: Vector3, position: Vector3, color: Color3, material: Enum.Material): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = material
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

-- Reconfigure le Baseplate par défaut en sol urbain.
local function configureGround()
	local baseplate = Workspace:FindFirstChild("Baseplate")
	if baseplate and baseplate:IsA("BasePart") then
		baseplate.Size = Vector3.new(200, 1, 200)
		baseplate.Position = Vector3.new(0, 0, 0)
		baseplate.Color = Color3.fromRGB(40, 40, 40)
		baseplate.Material = Enum.Material.Concrete
		baseplate.Anchored = true
	end
end

-- Construit un passage piéton (6 bandes blanches espacées de 1 stud).
local function buildCrosswalk(name: string, centerZ: number, parent: Instance)
	local crosswalk = Instance.new("Model")
	crosswalk.Name = name

	for i = 0, 5 do
		local stripe = makePart(
			string.format("Stripe_%d", i + 1),
			Vector3.new(20, 0.05, 1),
			Vector3.new(0, 1.22, centerZ - 5 + i * 2),
			Color3.fromRGB(240, 240, 240),
			Enum.Material.SmoothPlastic
		)
		stripe.Parent = crosswalk
	end

	crosswalk.Parent = parent
end

function MapBuilder.build()
	configureGround()

	-- Container racine pour toute la ville.
	local existing = Workspace:FindFirstChild("City")
	if existing then
		existing:Destroy()
	end

	local city = Instance.new("Model")
	city.Name = "City"

	-- Rue principale : asphalte sombre, axe Z (nord-sud).
	local mainStreet = makePart(
		"MainStreet",
		Vector3.new(20, 0.2, 100),
		Vector3.new(0, 1.1, 0),
		Color3.fromRGB(15, 15, 15),
		Enum.Material.Asphalt
	)
	mainStreet.Parent = city

	-- Ruelle perpendiculaire : axe X (est-ouest), traverse à Z=30.
	local sideAlley = makePart(
		"SideAlley",
		Vector3.new(40, 0.2, 8),
		Vector3.new(0, 1.1, 30),
		Color3.fromRGB(15, 15, 15),
		Enum.Material.Asphalt
	)
	sideAlley.Parent = city

	-- Trottoirs principaux (gauche/droite, le long de l'axe Z).
	local sidewalkMainLeft = makePart(
		"Sidewalk_Main_Left",
		Vector3.new(4, 0.5, 100),
		Vector3.new(-12, 1.25, 0),
		Color3.fromRGB(70, 70, 75),
		Enum.Material.Concrete
	)
	sidewalkMainLeft.Parent = city

	local sidewalkMainRight = makePart(
		"Sidewalk_Main_Right",
		Vector3.new(4, 0.5, 100),
		Vector3.new(12, 1.25, 0),
		Color3.fromRGB(70, 70, 75),
		Enum.Material.Concrete
	)
	sidewalkMainRight.Parent = city

	-- Trottoirs ruelle (devant/derrière, le long de l'axe X).
	local sidewalkAlleyNorth = makePart(
		"Sidewalk_Alley_North",
		Vector3.new(40, 0.5, 2),
		Vector3.new(0, 1.25, 35),
		Color3.fromRGB(70, 70, 75),
		Enum.Material.Concrete
	)
	sidewalkAlleyNorth.Parent = city

	local sidewalkAlleySouth = makePart(
		"Sidewalk_Alley_South",
		Vector3.new(40, 0.5, 2),
		Vector3.new(0, 1.25, 25),
		Color3.fromRGB(70, 70, 75),
		Enum.Material.Concrete
	)
	sidewalkAlleySouth.Parent = city

	-- Passages piétons (2) : un au sud (Z=-30), un au nord (Z=+10, avant la ruelle).
	buildCrosswalk("Crosswalk_South", -30, city)
	buildCrosswalk("Crosswalk_Mid", 10, city)

	-- Bâtiments cyberpunk (8 au total, deux côtés de la rue).
	Buildings.build(city)

	city.Parent = Workspace
end

return MapBuilder
