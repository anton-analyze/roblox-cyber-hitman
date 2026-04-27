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

	-- Néons rooftop sur les Corp Towers (visibles de loin, classique cyberpunk)
	-- CorpTower_West est à (-25, -35, h60), top à Y = 1.5 + 60 = 61.5
	makePart("RoofSign_CorpW", Vector3.new(12, 3, 0.4), Vector3.new(-15.5, 64, -35), Color3.fromRGB(0, 220, 255)).Parent =
		signs
	-- CorpTower_East est à (25, -35, h50), top à Y = 51.5
	makePart("RoofSign_CorpE", Vector3.new(12, 3, 0.4), Vector3.new(15.5, 54, -35), Color3.fromRGB(255, 50, 200)).Parent =
		signs

	-- Néon rooftop sur Sniper Building (top à Y = 1.5 + 28 = 29.5)
	makePart("RoofSign_Sniper", Vector3.new(8, 2, 0.4), Vector3.new(15.5, 32, 38), Color3.fromRGB(255, 200, 50)).Parent =
		signs

	signs.Parent = parent
end

return NeonSigns
