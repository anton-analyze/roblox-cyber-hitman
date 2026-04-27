--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local LightingConfig = require(ServerScriptService.Source.lighting.LightingConfig)
local Skybox = require(ServerScriptService.Source.lighting.Skybox)
local MapBuilder = require(ServerScriptService.Source.map.MapBuilder)
local PlayerSettings = require(ServerScriptService.Source.setup.PlayerSettings)
local Rain = require(ServerScriptService.Source.effects.Rain)
local NeonAnimator = require(ServerScriptService.Source.effects.NeonAnimator)

print(string.format("[%s] V%s alive", Constants.GameName, Constants.Version))

LightingConfig.apply()
print("[Lighting] applied cyberpunk night preset")

Skybox.apply()
print("[Skybox] starfield + Mt Fuji holo placed")

MapBuilder.build()
print("[Map] city built")

Rain.apply()
print("[Rain] particle emitter active")

NeonAnimator.start()
print("[NeonAnimator] running")

PlayerSettings.apply()
print("[PlayerSettings] first-person camera locked")
