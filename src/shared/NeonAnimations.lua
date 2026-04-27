--!strict
-- Logique pure d'animation néon. Pas d'effets de bord — tout est testable
-- avec TestEZ sans avoir besoin d'instancier des Parts dans Workspace.

local NeonAnimations = {}

-- Pulse : transparency oscille entre min et max selon une sinusoïde.
-- Retourne la transparency au temps `t` pour une animation de période `period`.
function NeonAnimations.pulseTransparency(t: number, period: number, minT: number, maxT: number): number
	local progress = (t % period) / period -- [0, 1)
	local sineVal = math.sin(progress * math.pi * 2) -- [-1, 1]
	local norm = (sineVal + 1) / 2 -- [0, 1]
	return minT + norm * (maxT - minT)
end

-- Blink : on/off binaire selon le ratio "on" du cycle.
function NeonAnimations.blinkOn(t: number, period: number, onRatio: number): boolean
	local progress = (t % period) / period
	return progress < onRatio
end

-- ColorCycle : interpole entre N couleurs (boucle continue).
function NeonAnimations.colorCycle(t: number, period: number, colors: { Color3 }): Color3
	if #colors == 0 then
		return Color3.new(1, 1, 1)
	end
	if #colors == 1 then
		return colors[1]
	end

	local progress = (t % period) / period -- [0, 1)
	local segmentLength = 1 / #colors
	local segment = math.floor(progress / segmentLength)
	local segmentProgress = (progress - segment * segmentLength) / segmentLength

	local from = colors[segment + 1]
	local to = colors[((segment + 1) % #colors) + 1]

	return Color3.new(
		from.R + (to.R - from.R) * segmentProgress,
		from.G + (to.G - from.G) * segmentProgress,
		from.B + (to.B - from.B) * segmentProgress
	)
end

return NeonAnimations
