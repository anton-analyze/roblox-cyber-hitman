--!strict
-- Joue les 3 ambiances sonores de la ville V1 (loop infini) :
--   1. Ambient city  — drone urbain, vent, lointain
--   2. Synthwave music — la "vibe" cyberpunk
--   3. Rain — bruit de pluie qui tombe
--
-- ⚠️ TOS RESPECT : tu DOIS utiliser uniquement :
--   • un son que TU as uploadé via Asset Manager dans Studio (mineur OK
--     pour upload de tes propres créations / sons libres de droits)
--   • OU un asset de la Roblox Creator Store marqué "Free to use"
--   • OU un son listé sur le devforum avec licence explicite
-- JAMAIS un son "trouvé sur internet" — ça peut ban ton compte.
--
-- Comment configurer : remplace les chaînes vides ci-dessous par les
-- assetIds (format "rbxassetid://NUMBER"). Tant qu'ils sont vides, le
-- sound est skippé (warning console mais pas de crash).

local SoundService = game:GetService("SoundService")

local AudioManager = {}

-- 🔊 ↓ REMPLACE ces SoundIds quand tu auras choisi tes sons ↓
local SOUND_AMBIENT_CITY = "" -- ex: "rbxassetid://1234567890"
local SOUND_SYNTHWAVE_MUSIC = "" -- ex: "rbxassetid://1234567891"
local SOUND_RAIN = "" -- ex: "rbxassetid://1234567892"
-- 🔊 ↑ REMPLACE ces SoundIds ↑

-- Volumes par défaut (entre 0 et 1).
local VOLUME_AMBIENT = 0.4
local VOLUME_MUSIC = 0.3
local VOLUME_RAIN = 0.5

local function makeLoopingSound(name: string, soundId: string, volume: number): Sound?
	if soundId == "" then
		warn(
			string.format("[AudioManager] %s skipped: SoundId vide. Édite AudioManager.lua pour le configurer.", name)
		)
		return nil
	end

	local sound = Instance.new("Sound")
	sound.Name = name
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Looped = true
	sound.PlayOnRemove = false
	sound.Parent = SoundService
	sound:Play()
	return sound
end

function AudioManager.start()
	-- Reset si rebuild (kill anciens sons)
	for _, name in { "AmbientCity", "SynthwaveMusic", "Rain" } do
		local existing = SoundService:FindFirstChild(name)
		if existing then
			existing:Destroy()
		end
	end

	makeLoopingSound("AmbientCity", SOUND_AMBIENT_CITY, VOLUME_AMBIENT)
	makeLoopingSound("SynthwaveMusic", SOUND_SYNTHWAVE_MUSIC, VOLUME_MUSIC)
	makeLoopingSound("Rain", SOUND_RAIN, VOLUME_RAIN)
end

return AudioManager
