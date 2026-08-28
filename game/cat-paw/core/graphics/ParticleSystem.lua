local middleclass = require "libs.middleclass"
--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class ParticleData

---@class ParticleSystem : Middleclass
---@overload fun(systems: ParticleData): self
local ParticleSystem = middleclass("ParticleSystem")

function ParticleSystem:initialize(particleData)
	self.data = particleData
	for _, v in ipairs(self.data) do
		v.enabled = false
	end
end

--============================ Core API ==============================

function ParticleSystem:update(dt)
	for _, v in ipairs(self.data) do
		if v.enabled then
			v.system:update(dt)
		end
	end
end

function ParticleSystem:draw(g2d)
	g2d.push('all')
		for _, v in ipairs(self.data) do
			if v.enabled then
				g2d.setBlendMode(v.blendMode)
				g2d.draw(v.system, v.x, v.y)
			end
		end
	g2d.pop()
end

--============================ API ==============================
function ParticleSystem:emitAt(id, x, y)
	local data = self.data[id]
	data.x = x
	data.y = y
	data.enabled = true
	data.system:start()
	for _ = 1, data.kickStartSteps do data.system:update(data.kickStartDt) end
	data.system:emit(data.emitAtStart)
end

--============================ Internals ==============================

--============================ Getters / Setters ==============================

function ParticleSystem:setPosition(id, x, y)
	self.data[id].x = x
	self.data[id].y = y
end

return ParticleSystem
