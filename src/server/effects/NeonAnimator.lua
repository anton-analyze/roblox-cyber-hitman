--!strict
-- Anime certaines enseignes néon en runtime (pulse / blink / color cycle).
-- La logique pure vit dans ReplicatedStorage.Shared.NeonAnimations.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local NeonAnimations = require(ReplicatedStorage.Shared.NeonAnimations)

type AnimKind = "pulse" | "blink" | "colorCycle"

type Animation = {
	kind: AnimKind,
	targetPath: { string },
	period: number,
	minT: number?,
	maxT: number?,
	onRatio: number?,
	onColor: Color3?,
	offColor: Color3?,
	colors: { Color3 }?,
}

local NeonAnimator = {}

local connection: RBXScriptConnection? = nil

-- Liste des enseignes animées (chemin relatif à Workspace).
local animations: { Animation } = {
	{
		kind = "pulse",
		targetPath = { "City", "NeonSigns", "RoofSign_CorpW" },
		period = 2.5,
		minT = 0,
		maxT = 0.5,
	},
	{
		kind = "colorCycle",
		targetPath = { "City", "NeonSigns", "RoofSign_CorpE" },
		period = 4,
		colors = {
			Color3.fromRGB(255, 50, 200),
			Color3.fromRGB(0, 220, 255),
			Color3.fromRGB(255, 100, 100),
		},
	},
	{
		kind = "pulse",
		targetPath = { "City", "NeonSigns", "RoofSign_Sniper" },
		period = 3.5,
		minT = 0.1,
		maxT = 0.5,
	},
	{
		kind = "blink",
		targetPath = { "City", "CyberBar", "BarNeon" },
		period = 0.7,
		onRatio = 0.7,
		onColor = Color3.fromRGB(255, 50, 200),
		offColor = Color3.fromRGB(60, 20, 50),
	},
	{
		kind = "pulse",
		targetPath = { "City", "RamenShop", "RamenSign" },
		period = 3,
		minT = 0,
		maxT = 0.35,
	},
}

local function findTarget(path: { string }): BasePart?
	local current: Instance = Workspace
	for _, segment in path do
		local child = current:FindFirstChild(segment)
		if not child then
			return nil
		end
		current = child
	end
	if current:IsA("BasePart") then
		return current :: BasePart
	end
	return nil
end

function NeonAnimator.start()
	if connection then
		connection:Disconnect()
		connection = nil
	end

	-- Résoudre les targets une fois (les enseignes sont buildées avant ce start).
	type Resolved = { target: BasePart, anim: Animation }
	local resolved: { Resolved } = {}
	for _, anim in animations do
		local target = findTarget(anim.targetPath)
		if target then
			table.insert(resolved, { target = target, anim = anim })
		end
	end

	connection = RunService.Heartbeat:Connect(function()
		local t = Workspace:GetServerTimeNow()
		for _, entry in resolved do
			local target = entry.target
			local anim = entry.anim

			if anim.kind == "pulse" then
				target.Transparency = NeonAnimations.pulseTransparency(t, anim.period, anim.minT or 0, anim.maxT or 0.5)
			elseif anim.kind == "blink" then
				local on = NeonAnimations.blinkOn(t, anim.period, anim.onRatio or 0.5)
				if on then
					target.Color = anim.onColor or Color3.new(1, 1, 1)
				else
					target.Color = anim.offColor or Color3.new(0.2, 0.2, 0.2)
				end
			elseif anim.kind == "colorCycle" then
				target.Color = NeonAnimations.colorCycle(t, anim.period, anim.colors or {})
			end
		end
	end)
end

return NeonAnimator
