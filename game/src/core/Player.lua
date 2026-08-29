local middleclass = require "libs.middleclass"
local push = require "libs.push"

local EvFileChange = require "cat-paw.core.patterns.event.dev.EvFileChange"
local WorldObject = require "core.WorldObject"
local AssetRegistry = require "core.AssetRegistry"

local brinevector = require "libs.brinevector"

--============================ Helper Methods ==============================

local LIGHT_SHADER = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a < 0.0001)
      discard;
    return texturecolor;
}
]])

local CROP_SHADER = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a > 0.6)
    	texturecolor.a = 0.6;
    return texturecolor;
}
]])

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
		self.light:_nextFrame()
	end, {self})
	self:_setupLightVars()
	self._lightMaskWrapper = function()
		return self:_drawLightSprite(love.graphics)
	end
	self:setSpriteOffset(WorldObject.SPRITE_CENTER)
	self.scene.map.bumpWorld:add(self, self:getBoundingBox())

	self.scratchRotationVector = brinevector(0, 0)

	self._collisionFilterWrapper = function(item, other) 
		return self:_collisionFilter(item, other)
	end
end

--============================ Core API ==============================

function Player:update(dt)
	WorldObject.update(self, dt)
	self.vel.x, self.vel.y = 0, 0
	local isDown = love.keyboard.isDown
	---move
	local dirX, dirY = 0, 0
	if isDown('w') then dirY = dirY - 1 end
	if isDown('s') then dirY = dirY + 1 end
	if isDown('a') then dirX = dirX - 1 end
	if isDown('d') then dirX = dirX + 1 end
	if dirX ~= 0 or dirY ~= 0 then
		self.vel.x = dirX
		self.vel.y = dirY
		self.vel.length = self.SPEED * dt
		
		local targetX = self.pos.x + self.vel.x
		local targetY = self.pos.y + self.vel.y
		local newX, newY, cols = self.scene.map.bumpWorld:move(self, targetX, targetY, self._collisionFilterWrapper)
		self.pos.x = newX
		self:_collisionHandler(cols)
		self.pos.y = newY
	end

	self.scratchRotationVector.x = dirX
	self.scratchRotationVector.y = dirY
	self:setRotation(self.scratchRotationVector.angle + math.pi/2)
	self.light.pos.x = self.pos.x - self.light.w / 2.2
	self.light.pos.y = self.pos.y - self.light.h / 2.2
	self.light:update(dt) 
end

function Player:earlyDraw(g2d)
	--push:setupCanvas("stencil_canvas")
--	g2d.rectangle('fill', self:getBoundingBox())
	g2d.setShader(LIGHT_SHADER)
	g2d.stencil(self._lightMaskWrapper, 'replace', 1)
	g2d.setShader()
	g2d.setStencilTest('equal', 1)
end

function Player:draw(g2d)
	local b = 0
	g2d.setColor(b, b, b, 0.5)
	g2d.rectangle('fill', self.pos.x - 500, self.pos.y - 500, 1000, 1000)

--	g2d.setColor(1, 1, 1, 0.3)
--	self:_drawLightSprite(g2d)

	g2d.setColor(1, 1, 1, 1)
	WorldObject.draw(self, g2d)
	
	g2d.setColor(1, 1, 1, 0.3)
	self:_drawLightSprite(g2d)
end


--============================ Callbacks ==============================

Player[EvFileChange] = function(self, e)
	self:_setupLightVars()
end

--============================ API ==============================
function Player:pickupItem(item)
	print("Picked up", item)
end

--============================ Internals ==============================

function Player:_collisionHandler(cols)
	for k, v in ipairs(cols or {}) do
		local other = v.other	
		if other.layer == "walls" then
		elseif other.layer == "doors" and not other.opened then
		elseif other.layer == "pickables" then
			self:pickupItem(other.ID)
			self.scene.map.bumpWorld:remove(other)
			self.scene.map.objs.pickables[other.ID] = nil
		end
		print(other.ID)
	end
end


function Player:_collisionFilter(item, other)
	if other.layer == "walls" then
		return 'slide'
	elseif other.layer == "doors" and not other.opened then
		return 'slide'
	elseif other.layer == "pickables" then
		return 'cross'
	else
		return false
	end
end


function Player:_setupLightVars()
	self.INITIAL_LIGHT_SIZE = self.light.w
	self.MAX_LIGHT_SIZE = self.light.w * 0.011
	self.lightGrowDir = 1
	self.lightGrowAmount = self.MAX_LIGHT_SIZE / 11

	GAME:getScheduler():cancel(self.flicker)

	self.flicker = GAME:getScheduler():callEvery(0.05, function(dt, per, self)
		self.light.w = self.light.w + self.lightGrowAmount * self.lightGrowDir
		self.light.h = self.light.h + self.lightGrowAmount * self.lightGrowDir
		local diff = math.abs(self.INITIAL_LIGHT_SIZE - self.light.w)
		if diff > self.MAX_LIGHT_SIZE then
			self.lightGrowDir = self.lightGrowDir * -1
		end
	end, {self})
end

function Player:_drawLightSprite(g2d)
	self.light:draw(g2d)
	--[[
	local sw, sh = GAME:getGameDimensions()
	local iw, ih = self.lightSprite:getDimensions()
	local sz = self.lightSpriteSx * iw
	local x = self.pos.x - sz / 3
	local y = self.pos.y - sz / 3
--	print(sw, sh, sz, (sw - sz) / 2, x, y)

	print('light', self.pos.x, x)
	g2d.draw(self.lightSprite, x, y, nil, self.lightSpriteSx, self.lightSpriteSy)
	--]]
end


--============================ Getters / Setters ==============================

return Player
