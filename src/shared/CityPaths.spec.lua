return function()
	local CityPaths = require(script.Parent.CityPaths)

	describe("nextIndex", function()
		it("advances by 1 in the middle of the loop", function()
			expect(CityPaths.nextIndex(2, 5)).to.equal(3)
			expect(CityPaths.nextIndex(3, 5)).to.equal(4)
		end)

		it("wraps from last to first", function()
			expect(CityPaths.nextIndex(5, 5)).to.equal(1)
		end)

		it("works for a 1-element loop", function()
			expect(CityPaths.nextIndex(1, 1)).to.equal(1)
		end)
	end)

	describe("distanceXZ", function()
		it("ignores the Y component", function()
			local a = Vector3.new(0, 100, 0)
			local b = Vector3.new(0, -50, 0)
			expect(CityPaths.distanceXZ(a, b)).to.equal(0)
		end)

		it("returns the Pythagorean distance in the XZ plane", function()
			local a = Vector3.new(0, 0, 0)
			local b = Vector3.new(3, 0, 4)
			expect(CityPaths.distanceXZ(a, b)).to.equal(5)
		end)

		it("is symmetric", function()
			local a = Vector3.new(1, 0, 7)
			local b = Vector3.new(4, 0, 3)
			expect(CityPaths.distanceXZ(a, b)).to.equal(CityPaths.distanceXZ(b, a))
		end)
	end)

	describe("predefined paths", function()
		it("WEST_SIDEWALK is non-empty", function()
			expect(#CityPaths.WEST_SIDEWALK > 0).to.equal(true)
		end)

		it("EAST_SIDEWALK is non-empty", function()
			expect(#CityPaths.EAST_SIDEWALK > 0).to.equal(true)
		end)

		it("LOOP_VIA_ALLEY is non-empty", function()
			expect(#CityPaths.LOOP_VIA_ALLEY > 0).to.equal(true)
		end)
	end)
end
