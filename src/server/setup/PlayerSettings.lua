--!strict
-- Configure les paramètres globaux des joueurs (caméra, contrôles).

local StarterPlayer = game:GetService("StarterPlayer")

local PlayerSettings = {}

function PlayerSettings.apply()
	-- Vue à la 1ère personne forcée — ambiance hitman immersive.
	StarterPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	StarterPlayer.CameraMaxZoomDistance = 0.5
end

return PlayerSettings
