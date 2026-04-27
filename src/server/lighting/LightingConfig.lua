--!strict
-- Configure le service Lighting pour ambiance nuit cyberpunk.
-- Appelé une fois au démarrage de la place, côté serveur.

local Lighting = game:GetService("Lighting")

local LightingConfig = {}

function LightingConfig.apply()
	-- Couleur globale
	Lighting.Ambient = Color3.fromRGB(20, 20, 35)
	Lighting.OutdoorAmbient = Color3.fromRGB(15, 15, 30)
	Lighting.Brightness = 0.3
	Lighting.ClockTime = 0 -- minuit

	-- Soleil/lune : faible
	Lighting.GeographicLatitude = 35 -- Tokyo
	Lighting.ExposureCompensation = 0

	-- Fog cyberpunk
	Lighting.FogColor = Color3.fromRGB(40, 20, 60) -- violet sombre
	Lighting.FogStart = 50
	Lighting.FogEnd = 300

	-- Atmosphere effect (si pas déjà là)
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.4
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(60, 40, 80)
	atmosphere.Decay = Color3.fromRGB(106, 112, 125)
	atmosphere.Glare = 0
	atmosphere.Haze = 1.5
end

return LightingConfig
