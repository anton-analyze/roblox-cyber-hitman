--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local TestEZ = require(ReplicatedStorage.Packages.TestEZ)

local function findSpecs(parent: Instance, found: { Instance })
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("ModuleScript") and string.match(child.Name, "%.spec$") then
			table.insert(found, child)
		end
		findSpecs(child, found)
	end
end

local specs = {}
findSpecs(ServerScriptService.Source, specs)

if #specs == 0 then
	print("[SpecRunner] no .spec modules found, skipping")
else
	print(string.format("[SpecRunner] found %d spec modules", #specs))
	TestEZ.TestBootstrap:run(specs)
end
