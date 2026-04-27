--!strict
-- Voitures statiques cyberpunk parquées le long des trottoirs.
-- Pas de physique : tout est Anchored. Style fuselé, 2 couleurs.

local Vehicles = {}

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

-- Une voiture cyberpunk = un Model contenant châssis + cabine + 2 bandes néon.
local function spawnCar(name: string, x: number, z: number, color: Color3, neonColor: Color3, parent: Instance)
	local car = Instance.new("Model")
	car.Name = name

	local baseY = 1.7

	-- Châssis (long et plat)
	local chassis =
		makePart("Chassis", Vector3.new(3, 1, 6.5), Vector3.new(x, baseY, z), color, Enum.Material.SmoothPlastic)
	chassis.Parent = car

	-- Cabine (un peu plus petite, posée sur le châssis, vitres sombres)
	local cabin = makePart(
		"Cabin",
		Vector3.new(2.6, 1, 3.5),
		Vector3.new(x, baseY + 1, z - 0.3),
		Color3.fromRGB(15, 15, 25),
		Enum.Material.Glass
	)
	cabin.Parent = car

	-- Bande néon dessous (effet "skin néon" cyberpunk classique)
	local underglow =
		makePart("Underglow", Vector3.new(2.8, 0.1, 6), Vector3.new(x, baseY - 0.55, z), neonColor, Enum.Material.Neon)
	underglow.Parent = car

	-- Phares avant
	local headlight = makePart(
		"Headlights",
		Vector3.new(2.6, 0.3, 0.2),
		Vector3.new(x, baseY + 0.2, z - 3.3),
		Color3.fromRGB(255, 240, 200),
		Enum.Material.Neon
	)
	headlight.Parent = car

	car.Parent = parent
end

function Vehicles.build(parent: Instance)
	-- Voitures parquées le long du trottoir gauche (X = -16, juste après le sidewalk)
	spawnCar("Car_W1", -16, -42, Color3.fromRGB(120, 30, 60), Color3.fromRGB(255, 50, 200), parent)
	spawnCar("Car_W2", -16, -20, Color3.fromRGB(20, 40, 80), Color3.fromRGB(0, 220, 255), parent)
	spawnCar("Car_W3", -16, 5, Color3.fromRGB(40, 40, 40), Color3.fromRGB(120, 255, 180), parent)

	-- Côté droit (X = +16)
	spawnCar("Car_E1", 16, -42, Color3.fromRGB(180, 90, 30), Color3.fromRGB(255, 150, 50), parent)
	spawnCar("Car_E2", 16, -20, Color3.fromRGB(30, 30, 60), Color3.fromRGB(180, 50, 255), parent)
	spawnCar("Car_E3", 16, 5, Color3.fromRGB(60, 60, 70), Color3.fromRGB(0, 200, 255), parent)
end

return Vehicles
