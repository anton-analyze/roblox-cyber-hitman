return function()
	local NeonAnimations = require(script.Parent.NeonAnimations)

	describe("pulseTransparency", function()
		it("stays within [minT, maxT] bounds for any t", function()
			for i = 0, 50 do
				local t = i * 0.1
				local result = NeonAnimations.pulseTransparency(t, 2, 0.1, 0.6)
				expect(result >= 0.1).to.equal(true)
				expect(result <= 0.6).to.equal(true)
			end
		end)

		it("returns midpoint at t=0 (sine starts at 0)", function()
			local result = NeonAnimations.pulseTransparency(0, 2, 0, 1)
			-- sin(0) = 0 → norm = 0.5 → mid value
			expect(math.abs(result - 0.5) < 0.001).to.equal(true)
		end)

		it("loops with period (same value at t and t+period)", function()
			local v1 = NeonAnimations.pulseTransparency(0.7, 2, 0, 1)
			local v2 = NeonAnimations.pulseTransparency(0.7 + 2, 2, 0, 1)
			expect(math.abs(v1 - v2) < 0.001).to.equal(true)
		end)
	end)

	describe("blinkOn", function()
		it("returns true during the first onRatio fraction of the cycle", function()
			expect(NeonAnimations.blinkOn(0, 2, 0.5)).to.equal(true)
			expect(NeonAnimations.blinkOn(0.5, 2, 0.5)).to.equal(true)
		end)

		it("returns false after the onRatio fraction", function()
			expect(NeonAnimations.blinkOn(1.1, 2, 0.5)).to.equal(false)
			expect(NeonAnimations.blinkOn(1.9, 2, 0.5)).to.equal(false)
		end)

		it("loops with period", function()
			expect(NeonAnimations.blinkOn(2.1, 2, 0.5)).to.equal(true)
		end)
	end)

	describe("colorCycle", function()
		it("returns the only color when given a single one", function()
			local red = Color3.new(1, 0, 0)
			local result = NeonAnimations.colorCycle(0.5, 2, { red })
			expect(result).to.equal(red)
		end)

		it("returns first color exactly at t=0", function()
			local red = Color3.new(1, 0, 0)
			local blue = Color3.new(0, 0, 1)
			local result = NeonAnimations.colorCycle(0, 2, { red, blue })
			expect(math.abs(result.R - 1) < 0.001).to.equal(true)
			expect(math.abs(result.B - 0) < 0.001).to.equal(true)
		end)

		it("returns white fallback for empty color list", function()
			local result = NeonAnimations.colorCycle(0, 2, {})
			expect(result).to.equal(Color3.new(1, 1, 1))
		end)

		it("interpolates between two colors at midpoint of segment", function()
			local red = Color3.new(1, 0, 0)
			local blue = Color3.new(0, 0, 1)
			-- 2 colors, period 2, segmentLength 0.5 (not 1!) — wait actually segmentLength = 1/2 = 0.5
			-- t=0.5: progress=0.25, segment=0 (first), segmentProgress=0.5 → halfway red→blue
			local result = NeonAnimations.colorCycle(0.5, 2, { red, blue })
			expect(math.abs(result.R - 0.5) < 0.05).to.equal(true)
			expect(math.abs(result.B - 0.5) < 0.05).to.equal(true)
		end)
	end)
end
