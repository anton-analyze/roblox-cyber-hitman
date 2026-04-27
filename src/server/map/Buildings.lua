--!strict
-- Construit les 8 bâtiments cyberpunk de la ville V1.
-- Chaque bâtiment = un bloc Part avec Material/Color cyberpunk + 1 PointLight
-- d'ambiance. Néons (Material.Neon) sur certaines façades — pas de PointLight
-- pour les néons (cap perf : on garde ≤20 PointLights total dans tout le projet).

local Buildings = {}

-- Y de la base d'un bâtiment : trottoir top = 1.5, on pose le bâtiment dessus.
local GROUND_Y = 1.5

-- Helper : crée un Part Anchored.
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

-- Helper : pose un bloc-bâtiment standard (centré X/Z, base posée au sol).
local function block(
	name: string,
	footprintX: number,
	footprintZ: number,
	height: number,
	x: number,
	z: number,
	color: Color3,
	material: Enum.Material
): Part
	local centerY = GROUND_Y + height / 2
	return makePart(name, Vector3.new(footprintX, height, footprintZ), Vector3.new(x, centerY, z), color, material)
end

-- Helper : ajoute une PointLight d'ambiance au sommet d'un bâtiment.
local function addRoofLight(building: Part, color: Color3, brightness: number, range: number)
	local light = Instance.new("PointLight")
	light.Color = color
	light.Brightness = brightness
	light.Range = range
	light.Shadows = false -- perf
	light.Parent = building
end

-- Helper : ajoute une bande néon décorative sur une façade.
-- offsetY = position verticale relative au centre du bâtiment.
-- side = "front" (Z négatif vers la rue) ou "back".
local function addNeonStripe(building: Part, name: string, color: Color3, offsetY: number, side: string)
	local pos = building.Position
	local size = building.Size
	local stripeZ: number
	if side == "front" then
		stripeZ = pos.Z - size.Z / 2 - 0.05
	else
		stripeZ = pos.Z + size.Z / 2 + 0.05
	end

	local stripe = makePart(
		name,
		Vector3.new(size.X * 0.8, 0.6, 0.1),
		Vector3.new(pos.X, pos.Y + offsetY, stripeZ),
		color,
		Enum.Material.Neon
	)
	stripe.Parent = building
end

-- ============================================================
-- TYPES DE BÂTIMENTS
-- ============================================================

local function corporateTower(name: string, x: number, z: number, height: number, parent: Instance)
	local tower = block(name, 18, 22, height, x, z, Color3.fromRGB(35, 40, 55), Enum.Material.Concrete)
	addRoofLight(tower, Color3.fromRGB(80, 180, 255), 2, 30)
	-- Néons cyan verticaux sur la façade rue
	addNeonStripe(tower, "NeonAccent", Color3.fromRGB(0, 220, 255), height / 2 - 4, "front")
	tower.Parent = parent
end

local function ramenShop(name: string, x: number, z: number, parent: Instance)
	local shop = block(name, 14, 18, 8, x, z, Color3.fromRGB(60, 30, 30), Enum.Material.WoodPlanks)
	addRoofLight(shop, Color3.fromRGB(255, 80, 60), 3, 20)
	-- Enseigne rouge-orangée façade rue
	addNeonStripe(shop, "RamenSign", Color3.fromRGB(255, 60, 40), 1, "front")
	shop.Parent = parent
end

local function cyberBar(name: string, x: number, z: number, parent: Instance)
	local bar = block(name, 12, 16, 12, x, z, Color3.fromRGB(25, 25, 35), Enum.Material.Brick)
	addRoofLight(bar, Color3.fromRGB(255, 50, 200), 3, 22)
	-- Néon rose magenta sur façade
	addNeonStripe(bar, "BarNeon", Color3.fromRGB(255, 50, 200), 2, "front")
	bar.Parent = parent
end

local function techShop(name: string, x: number, z: number, parent: Instance)
	local shop = block(name, 14, 16, 10, x, z, Color3.fromRGB(50, 60, 70), Enum.Material.Metal)
	addRoofLight(shop, Color3.fromRGB(150, 255, 200), 2, 18)
	-- Néon vert tech sur façade
	addNeonStripe(shop, "TechNeon", Color3.fromRGB(120, 255, 180), 1.5, "front")
	shop.Parent = parent
end

local function apartment(name: string, x: number, z: number, height: number, parent: Instance)
	local apt = block(name, 16, 20, height, x, z, Color3.fromRGB(80, 60, 50), Enum.Material.Brick)
	addRoofLight(apt, Color3.fromRGB(255, 200, 100), 1.5, 20)
	apt.Parent = parent
end

-- Building avec toit accessible (futur sniper spot V5).
-- Plus bas que les autres pour qu'on puisse y monter (escalier extérieur en V2+).
local function sniperBuilding(name: string, x: number, z: number, parent: Instance)
	local height = 28
	local building = block(name, 16, 18, height, x, z, Color3.fromRGB(45, 50, 60), Enum.Material.Concrete)
	addRoofLight(building, Color3.fromRGB(180, 220, 255), 1.5, 22)

	-- Garde-corps blanc sur le toit (4 murets fins) — délimite la zone sniper
	local topY = GROUND_Y + height
	local railingColor = Color3.fromRGB(200, 200, 210)
	local railH = 1.2
	local sizeX = 16
	local sizeZ = 18

	local railNorth = makePart(
		"Railing_N",
		Vector3.new(sizeX, railH, 0.3),
		Vector3.new(x, topY + railH / 2, z - sizeZ / 2),
		railingColor,
		Enum.Material.Metal
	)
	railNorth.Parent = building

	local railSouth = makePart(
		"Railing_S",
		Vector3.new(sizeX, railH, 0.3),
		Vector3.new(x, topY + railH / 2, z + sizeZ / 2),
		railingColor,
		Enum.Material.Metal
	)
	railSouth.Parent = building

	local railWest = makePart(
		"Railing_W",
		Vector3.new(0.3, railH, sizeZ),
		Vector3.new(x - sizeX / 2, topY + railH / 2, z),
		railingColor,
		Enum.Material.Metal
	)
	railWest.Parent = building

	local railEast = makePart(
		"Railing_E",
		Vector3.new(0.3, railH, sizeZ),
		Vector3.new(x + sizeX / 2, topY + railH / 2, z),
		railingColor,
		Enum.Material.Metal
	)
	railEast.Parent = building

	building.Parent = parent
end

-- ============================================================
-- LAYOUT V1
-- ============================================================

function Buildings.build(parent: Instance)
	-- WEST SIDE (X = -25, façade vers l'est / la rue)
	corporateTower("CorpTower_West", -25, -35, 60, parent)
	ramenShop("RamenShop", -25, -10, parent)
	apartment("Apartment_West", -25, 12, 25, parent)
	cyberBar("CyberBar", -25, 38, parent)

	-- EAST SIDE (X = +25, façade vers l'ouest / la rue)
	corporateTower("CorpTower_East", 25, -35, 50, parent)
	techShop("TechShop", 25, -10, parent)
	apartment("Apartment_East", 25, 12, 30, parent)
	sniperBuilding("RooftopBuilding", 25, 38, parent)
end

return Buildings
