local middleclass = require "libs.middleclass"
local push = require "libs.push"

local WorldObject = require "core.WorldObject"
local AssetRegistry = require "core.AssetRegistry"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Player : WorldObject
---@field SPEED number
---@field lightRadius number
---@overload fun(scene: Scene, x: number, y: number): self
local Player = middleclass("Player", WorldObject)
	
function Player:initialize(scene, x, y)
	WorldObject.initialize(self, "player", scene, x, y)
	self.lightSprite, self.lightSpriteSx, self.lightSpriteSy = 
		AssetRegistry:getSprObj({ID = "light_sprite", w = 64, h = 64})
	self._lightMaskWrapper = function()
		return self:_lightMask(love.graphics)
	end
end

--============================ Core API ==============================

function Player:update(dt)
	WorldObject.update(self, dt)
	local isDown = love.keyboard.isDown
	---move
	local dirX, dirY = 0, 0
	if isDown('w') then dirY = dirY - 1 end
	if isDown('s') then dirY = dirY + 1 end
	if isDown('a') then dirX = dirX - 1 end
	if isDown('d') then dirX = dirX + 1 end
	if dirX ~= 0 or dirY ~= 0 then
		if dirX == dirY then	--going diagonally
			self.pos.x = self.pos.x + self.SPEED * dirX * dt * 1.41421356237	--The square-root of 2.
			self.pos.y = self.pos.y + self.SPEED * dirY * dt * 1.41421356237	--The square-root of 2.
		else
			self.pos.x = self.pos.x + self.SPEED * dirX * dt
			self.pos.y = self.pos.y + self.SPEED * dirY * dt
		end
	end
end

function Player:draw(g2d)
	WorldObject.draw(self, g2d)
	--push:setupCanvas("stencil_canvas")
	g2d.stencil(self._lightMaskWrapper, 'replace', 1)
	g2d.setStencilTest('greater', 0)
--	g2d.setColor(1, 0,0,1)
	self:_lightMask(g2d)
--	g2d.setColor(1, 1,0,1)
--	g2d.rectangle('fill', self.pos.x, self.pos.y, 20, 20)
end

function Player:lateDraw(g2d)
	local sw, sh = GAME:getGameDimensions()
	local x = sw / 2 - self.lightRadius * 2
	local y = sh / 2 - self.lightRadius * 2
	local diameter = self.lightRadius * 2
	g2d.draw(self.lightSprite, x, y, nil, self.lightSpriteSx, self.lightSpriteSy)
end


--============================ API ==============================

--============================ Internals ==============================
function Player:_lightMask(g2d)

	local sw, sh = GAME:getGameDimensions()
	local diameter = self.lightRadius * 2
	g2d.circle('fill', sw/2, sh/2, diameter, diameter)
	--[[

	local x = self.pos.x - self.lightRadius
	local y = self.pos.y - self.lightRadius
	local diameter = self.lightRadius * 2
	g2d.circle('fill', x, y, diameter, diameter)
	--]]
end


--============================ Getters / Setters ==============================

return Player
