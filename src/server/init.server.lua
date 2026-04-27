--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)

print(string.format("[%s] V%s alive", Constants.GameName, Constants.Version))
