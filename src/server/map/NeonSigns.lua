--!strict
-- Enseignes néon supplémentaires (Material.Neon) sur les façades + en hauteur.
-- Pas de PointLight (cap perf : on garde 8/20 utilisées par les bâtiments).

local NeonSigns = {}

local function makePart(name: string, size: Vector3, position: Vector3, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Position = position
	part.Color = color
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

function NeonSigns.build(parent: Instance)
	local signs = Instance.new("Model")
	signs.Name = "NeonSigns"

	-- Enseignes verticales en façade ouest (collées sur les murs côté rue)
	-- X = -15.9 → juste devant les bâtiments (qui finissent à X=-16)
	makePart("West_VertSign_1", Vector3.new(0.2, 8, 1.5), Vector3.new(-15.9, 8, -35), Color3.fromRGB(255, 50, 200)).Parent =
		signs
	makePart("West_VertSign_2", Vector3.new(0.2, 6, 1.5), Vector3.new(-15.9, 6, -10), Color3.fromRGB(0, 220, 255)).Parent =
		signs
	makePart("West_VertSign_3", Vector3.new(0.2, 6, 1.5), Vector3.new(-15.9, 6, 12), Color3.fromRGB(255, 200, 100)).Parent =
		signs

	-- Enseignes horizontales (style banderole) en hauteur ouest
	makePart("West_HorzSign_1", Vector3.new(0.2, 1.2, 4), Vector3.new(-15.9, 14, -35), Color3.fromRGB(255, 80, 60)).Parent =
		signs
	makePart("West_HorzSign_2", Vector3.new(0.2, 1.2, 4), Vector3.new(-15.9, 12, 38), Color3.fromRGB(255, 50, 200)).Parent =
		signs

	-- Enseignes verticales façade est
	makePart("East_VertSign_1", Vector3.new(0.2, 7, 1.5), Vector3.new(15.9, 7, -35), Color3.fromRGB(120, 255, 180)).Parent =
		signs
	makePart("East_VertSign_2", Vector3.new(0.2, 5, 1.5), Vector3.new(15.9, 5, -10), Color3.fromRGB(0, 220, 255)).Parent =
		signs
	makePart("East_VertSign_3", Vector3.new(0.2, 6, 1.5), Vector3.new(15.9, 6, 38), Color3.fromRGB(255, 50, 200)).Parent =
		signs

	-- Enseignes horizontales est
	makePart("East_HorzSign_1", Vector3.new(0.2, 1.2, 5), Vector3.new(15.9, 13, -10), Color3.fromRGB(255, 200, 100)).Parent =
		signs
	makePart("East_HorzSign_2", Vector3.new(0.2, 1.2, 4), Vector3.new(15.9, 11, 12), Color3.fromRGB(120, 255, 180)).Parent =
		signs

	-- Enseignes "skybridge" : suspendues au-dessus de la rue, façon vieux Tokyo électrique
	makePart("SkyBanner_1", Vector3.new(8, 0.8, 0.2), Vector3.new(0, 18, -25), Color3.fromRGB(255, 50, 200)).Parent =
		signs
	makePart("SkyBanner_2", Vector3.new(6, 0.6, 0.2), Vector3.new(0, 14, 0), Color3.fromRGB(0, 220, 255)).Parent = signs
	makePart("SkyBanner_3", Vector3.new(7, 0.7, 0.2), Vector3.new(0, 16, 22), Color3.fromRGB(255, 200, 50)).Parent =
		signs

	signs.Parent = parent
end

return NeonSigns
