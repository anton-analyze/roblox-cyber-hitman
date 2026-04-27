--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Constants = require(ReplicatedStorage.Shared.Constants)
local LightingConfig = require(ServerScriptService.Source.lighting.LightingConfig)

print(string.format("[%s] V%s alive", Constants.GameName, Constants.Version))

LightingConfig.apply()
print("[Lighting] applied cyberpunk night preset")
