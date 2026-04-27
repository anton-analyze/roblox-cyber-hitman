--!strict
-- Spawne quelques piétons silhouettes qui marchent en boucle sur des
-- chemins prédéfinis. V1 = silhouettes simples (Parts en mouvement via
-- TweenService), pas de vrais Humanoids — l'objectif est l'ambiance.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local CityPaths = require(ReplicatedStorage.Shared.CityPaths)

local PedestrianSpawner = {}

local function buildSilhouette(name: string, color: Color3, startPos: Vector3, parent: Instance): BasePart
	local model = Instance.new("Model")
	model.Name = name

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(1.5, 4, 1)
	body.Position = startPos
	body.Color = color
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.TopSurface = Enum.SurfaceType.Smooth
	body.BottomSurface = Enum.SurfaceType.Smooth
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Shape = Enum.PartType.Ball
	head.Size = Vector3.new(1.2, 1.2, 1.2)
	head.Position = startPos + Vector3.new(0, 2.6, 0)
	head.Color = Color3.fromRGB(180, 150, 130)
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.Parent = model

	-- Welds tête au corps pour qu'elle suive le mouvement.
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = body
	weld.Part1 = head
	weld.Parent = body

	model.PrimaryPart = body
	model.Parent = parent
	return body
end

-- Démarre un loop de tweens enchaînés qui font marcher la silhouette
-- de waypoint en waypoint indéfiniment, à `speed` studs/sec.
local function walkLoop(body: BasePart, path: { Vector3 }, speed: number)
	task.spawn(function()
		local index = 1
		while body.Parent do
			local nextIdx = CityPaths.nextIndex(index, #path)
			local target = path[nextIdx]
			local distance = CityPaths.distanceXZ(body.Position, target)
			local duration = math.max(distance / speed, 0.1)

			local tween = TweenService:Create(body, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
				Position = target,
			})
			tween:Play()
			tween.Completed:Wait()

			-- Petite pause aléatoire (style "civil qui s'arrête, regarde, repart")
			if math.random() < 0.3 then
				task.wait(math.random() * 1.5)
			end

			index = nextIdx
		end
	end)
end

function PedestrianSpawner.spawn()
	-- Container Workspace.City devient le parent (créé par MapBuilder).
	local city = Workspace:FindFirstChild("City")
	if not city then
		warn("[PedestrianSpawner] Workspace.City introuvable — skip spawn")
		return
	end

	local pedestrians = Instance.new("Model")
	pedestrians.Name = "Pedestrians"
	pedestrians.Parent = city

	-- Walker 1 — trottoir ouest, lent (vieux passant)
	local body1 = buildSilhouette("Walker_West_1", Color3.fromRGB(50, 55, 70), CityPaths.WEST_SIDEWALK[1], pedestrians)
	walkLoop(body1, CityPaths.WEST_SIDEWALK, 5)

	-- Walker 2 — trottoir est, vitesse moyenne
	local body2 = buildSilhouette("Walker_East_1", Color3.fromRGB(80, 30, 60), CityPaths.EAST_SIDEWALK[1], pedestrians)
	walkLoop(body2, CityPaths.EAST_SIDEWALK, 7)

	-- Walker 3 — boucle via ruelle, rapide (genre coursier pressé)
	local body3 =
		buildSilhouette("Walker_Alley_1", Color3.fromRGB(40, 60, 80), CityPaths.LOOP_VIA_ALLEY[1], pedestrians)
	walkLoop(body3, CityPaths.LOOP_VIA_ALLEY, 9)
end

return PedestrianSpawner
