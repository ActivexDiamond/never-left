local middleclass = require "libs.middleclass"
local push = require "libs.push"

local WorldObject = require "core.WorldObject"
local AssetRegistry = require "core.AssetRegistry"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Player : WorldObject
---@field SPEED number
---@field lightRadius number
---@field lightFps number
---@overload fun(scene: Scene, x: number, y: number): self
local Player = middleclass("Player", WorldObject)
	
function Player:initialize(scene, x, y)
	WorldObject.initialize(self, "player", scene, x, y)

	self.light = WorldObject("player_light", scene, x, y)
	GAME:getScheduler():callEvery(1 / self.lightFps, function(dt, per, self)
		local light = self.lightSpriteData
		local spr, sx, sy = AssetRegistry:getSprObj(light)
		light.currentFrame = light.currentFrame + 1
		print(spr)
		print(light.currentFrame)
		if light.currentFrame >= #spr - 1 then
			light.currentFrame = 0
		end
	end, {self})
	self.lightSpriteData = {
		ID = "light_sprite", 
		w = self.lightRadius*4, 
		h = self.lightRadius*4,
		currentFrame = 0,
	}
		self.lightSprite, self.lightSpriteSx, self.lightSpriteSy = 
				AssetRegistry:getSprObj(self.lightSpriteData)
	print('asd',self.lightSprite)
	self._lightMaskWrapper = function()
		return self:_drawLightSprite(love.graphics)
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

	self.light.pos.x = self.pos.x
	self.light.pos.y = self.pos.y
end

function Player:earlyDraw(g2d)
	--push:setupCanvas("stencil_canvas")
--	g2d.rectangle('fill', self:getBoundingBox())
	g2d.stencil(self._lightMaskWrapper, 'replace', 1)
	g2d.setStencilTest('greater', 0)
--	g2d.setColor(1, 0,0,1)
	self:_drawLightSprite(g2d)
--	g2d.setColor(1, 1,0,1)
--	g2d.rectangle('fill', self.pos.x, self.pos.y, 20, 20)
	print('ss', self.pos)
end

function Player:draw(g2d)
	WorldObject.draw(self, g2d)
	self:_drawLightSprite(g2d)
end


--============================ API ==============================

--============================ Internals ==============================

function Player:_drawLightSprite(g2d)
	local sw, sh = GAME:getGameDimensions()
	local iw, ih = self.lightSprite:getDimensions()
	local sz = self.lightSpriteSx * iw
	local x = self.pos.x - sz / 3
	local y = self.pos.y - sz / 3
--	print(sw, sh, sz, (sw - sz) / 2, x, y)

	print('light', self.pos.x, x)
	g2d.draw(self.lightSprite, x, y, nil, self.lightSpriteSx, self.lightSpriteSy)
end


--============================ Getters / Setters ==============================

return Player
