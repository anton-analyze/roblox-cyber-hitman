--!strict
-- Configure le service Lighting pour ambiance nuit cyberpunk.
-- Appelé une fois au démarrage de la place, côté serveur.

local Lighting = game:GetService("Lighting")

local LightingConfig = {}

function LightingConfig.apply()
	-- Couleur globale (clair pour voir mais ambiance violette gardée)
	Lighting.Ambient = Color3.fromRGB(45, 40, 65)
	Lighting.OutdoorAmbient = Color3.fromRGB(40, 35, 55)
	Lighting.Brightness = 1.5
	Lighting.ClockTime = 0 -- minuit

	-- Soleil/lune
	Lighting.GeographicLatitude = 35 -- Tokyo
	Lighting.ExposureCompensation = 0.2

	-- Fog cyberpunk (plus loin pour qu'on voie la ville)
	Lighting.FogColor = Color3.fromRGB(40, 20, 60)
	Lighting.FogStart = 120
	Lighting.FogEnd = 600

	-- Atmosphere effect (si pas déjà là)
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.2
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(80, 60, 100)
	atmosphere.Decay = Color3.fromRGB(106, 112, 125)
	atmosphere.Glare = 0
	atmosphere.Haze = 0.8
end

return LightingConfig
