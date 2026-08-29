local middleclass = require "libs.middleclass"
local Object = require "core.Object"

local AssetRegistry = require "core.AssetRegistry"

local brinevector = require "libs.brinevector"

--============================ Helpers ==============================

--============================ Constructor ==============================

---@class WorldObject : Object
---@field rect boolean?
---@field filled 'fill'|'line'?
---@field useInvSpr boolean?
---@field w number
---@field h number
---@overload fun(id: string, scene: Scene, x: number, y: number): self
local WorldObject = middleclass("WorldObject", Object)
function WorldObject:initialize(id, scene, x, y)
	Object.initialize(self, id)
	self.scene = scene
	self.pos = brinevector(x, y)
	
	self.vel = brinevector(100, 90)
	self.currentFrame = 0
	self.rotation = 0
	self.spriteOffset = {x = 0, y = 0}
	self.flash = 0	
	
	self.flipSpriteX = 1
	self.flipSpriteY = 1
end

--============================ Constants ==============================

WorldObject.SPRITE_CENTER = {0.5, 0.5}
WorldObject.SPRITE_BOTTOM_CENTER = {0.5, 1}

--============================ Core API ==============================

function WorldObject:draw(g2d)
	Object.draw(self, g2d)
	---[[
	if self.rect then
		g2d.setColor(0.3, 0.3, 0.3, 0.7)
		local mode = self.filled and 'fill' or 'line'
		g2d.rectangle(mode, self:getBoundingBox())
		g2d.setColor(1, 1, 1, 1)
	end

	g2d.setColor(1, 1, 1, 1)
	local spr, sx, sy
	if self.useInvSpr then
		spr, sx, sy = AssetRegistry:getSprInv(self)
	else
		spr, sx, sy = AssetRegistry:getSprObj(self)
	end
	local frame;
	if spr[0] and spr[0].typeOf and spr[0]:typeOf("Drawable") then
		frame = spr[self.currentFrame]
	else
		frame = spr
	end

	sx = sx * self.flipSpriteX
	sy = sy * self.flipSpriteY
	local x = self.pos.x + self.w * self.spriteOffset.x
	local y = self.pos.y + self.h * self.spriteOffset.y
	local ox = frame:getWidth() * self.spriteOffset.x 
	local oy = frame:getHeight() * self.spriteOffset.y
	print(self.ID, self.pos.x, x)
	if self.flash > 0 then
		g2d.setColor(1, 0, 0, 1)
		self.flash = self.flash - 1
	end
	g2d.draw(frame, x, y, self.rotation, sx, sy, ox, oy)
	g2d.setColor(1, 1, 1, 1)
	--]]
end

--============================ Graphics ==============================
function WorldObject:_nextFrame()
	local spr, sx, sy
	if self.useInvSpr then
		spr, sx, sy = AssetRegistry:getSprInv(self)
	else
		spr, sx, sy = AssetRegistry:getSprObj(self)
	end

	if spr[0] and spr[0].typeOf and spr[0]:typeOf("Drawable") then
		self.currentFrame = self.currentFrame + 1
		if self.currentFrame >= #spr - 1 then
			self.currentFrame = 0
		end
	else
		return false
	end
end


--============================ API ==============================

--============================ Getters / Setters ==============================

--============================ Phyiscs ==============================

function WorldObject:getPosition() return self.pos end
function WorldObject:getRotation() return self.rotation end
--function WorldObject:getSpriteOffset() return self.spriteOffset end

function WorldObject:getCenter()
	return brinevector(self.pos.x + self.w / 2, 
			self.pos.y + self.h / 2)
end
function WorldObject:getBoundingBox()
	local x = self.pos.x
	local y = self.pos.y
	local w = self.w
	local h = self.h
	return x, y, w, h
end

function WorldObject:setPosition(x, y)
	self.pos.x = x
	self.pos.y = y
end

function WorldObject:setRotation(r)
	self.rotation = r
end

--Either x/y (factors to be multiplied by the sprite's pre-scaling size) or a SPRITE_ constant.
function WorldObject:setSpriteOffset(a, b)
	if type(a) == 'table' then
		self.spriteOffset.x = a[1]
		self.spriteOffset.y = a[2]
	else
		self.spriteOffset.x = a
		self.spriteOffset.y = b
	end
end

return WorldObject
