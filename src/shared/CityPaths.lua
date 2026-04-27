--!strict
-- Définit les chemins prédéfinis que les PNJ piétons suivent en boucle.
-- Logique pure (data + helpers) — facilement testable.

local CityPaths = {}

export type Path = { Vector3 }

-- Hauteur Y standard des piétons (au-dessus des trottoirs Y=1.5, mi-taille).
local Y_PED = 3.6

-- Trottoir ouest (X = -12), le long de la rue principale (Z = -45 → +45).
CityPaths.WEST_SIDEWALK = {
	Vector3.new(-12, Y_PED, -45),
	Vector3.new(-12, Y_PED, -25),
	Vector3.new(-12, Y_PED, -5),
	Vector3.new(-12, Y_PED, 18),
	Vector3.new(-12, Y_PED, 45),
} :: Path

-- Trottoir est (X = +12), trajet inverse.
CityPaths.EAST_SIDEWALK = {
	Vector3.new(12, Y_PED, 45),
	Vector3.new(12, Y_PED, 18),
	Vector3.new(12, Y_PED, -5),
	Vector3.new(12, Y_PED, -25),
	Vector3.new(12, Y_PED, -45),
} :: Path

-- Boucle qui passe par la ruelle (croisée en T à Z=30) puis retour.
CityPaths.LOOP_VIA_ALLEY = {
	Vector3.new(-12, Y_PED, -10),
	Vector3.new(-12, Y_PED, 25),
	Vector3.new(-15, Y_PED, 30),
	Vector3.new(15, Y_PED, 30),
	Vector3.new(12, Y_PED, 25),
	Vector3.new(12, Y_PED, -10),
} :: Path

-- Pure : retourne l'index suivant dans une boucle de longueur `length`.
-- 1-indexed (Lua style). nextIndex(3, 5) = 4 ; nextIndex(5, 5) = 1.
function CityPaths.nextIndex(currentIndex: number, length: number): number
	return (currentIndex % length) + 1
end

-- Pure : distance 2D (plan XZ) entre deux waypoints.
function CityPaths.distanceXZ(a: Vector3, b: Vector3): number
	local dx = a.X - b.X
	local dz = a.Z - b.Z
	return math.sqrt(dx * dx + dz * dz)
end

return CityPaths
