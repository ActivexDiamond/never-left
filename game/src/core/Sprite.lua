--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      Sprite.lua

local middleclass = require "libs.middleclass"
local anim8 = require "libs.anim8"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Sprite : Middleclass
---@overload fun(x: number?, y: number?, image: love.image?, frameRange: number?, frameW: number?, frameH: number?, duration: number?, idealW: number?, idealH: number?, allowStretch: boolean?): self
local Sprite = middleclass("Sprite")

---@param x? number
---@param y? number
---@param image? love.Image
---@param frameRange? [number, string]|[string, number]
---@param frameW? number
---@param frameH? number
---@param duration? number
---@param idealW? number The smaller of the two is selected, unless stretching is allowed.
---@param idealH? number The smaller of the two is selected, unless stretching is allowed.
---@param allowStretch? boolean
function Sprite:initialize(x, y, image, frameRange, frameW, frameH, duration, idealW, idealH, allowStretch)
	--World vars.
	self.x = x or 0
	self.y = y or 0
	
	--Animation vars.
	self.image = image or love.graphics.newImage("assets/themes/common/missing_sprite.png")
	self.frameRange = frameRange or {1, 1}
	self.frameW = frameW or self.image:getWidth()
	self.frameH = frameH or self.image:getHeight()
	self.duration = duration or 1

	--Scaling vars.
	self.rotation = 0

	idealW = idealW or self.frameW
	idealH = idealH or idealW
	if allowStretch then
		self.xScale = idealW / self.frameW
		self.yScale = idealH / self.frameH
	elseif idealW < idealH then
		self.xScale = idealW / self.frameW
		self.yScale = self.xScale
	else
		self.yScale = idealH / self.frameH
		self.xScale = self.yScale
	end

	--Setup animation.
	local iw, ih = self.image:getDimensions()
	self.grid = anim8.newGrid(self.frameW, self.frameH, iw, ih)
	self.frames = self.grid(self.frameRange[1], self.frameRange[2])
	--TODO: Multiple animations per sprite.
	self.animation = anim8.newAnimation(self.frames, self.duration, DO_STUFF and "pauseAtEnd")
end

--============================ Core API ==============================

function Sprite:update(dt)
	self.animation:update(dt)
end

function Sprite:draw(g2d)
	self.animation:draw(self.image, self.x, self.y, self.rotation, self.xScale, self.yScale)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================
function Sprite:getX() return self.x end
function Sprite:getY() return self.y end
function Sprite:getPosition()
	return self.x, self.y
end

function Sprite:setX(x) self.x = x end
function Sprite:setY(y) self.y = y end
function Sprite:setPosition(x, y)
	self.x, self.y = x, y
end


function Sprite:getW() return self.frameW end
function Sprite:getH() return self.frameH end
function Sprite:getDimensions()
	return self.frameW, self.frameH
end

function Sprite:getXScale() return self.xScale end
function Sprite:getYScale() return self.yScale end
function Sprite:getScale() 
	return self.xScale, self.yScale
end

function Sprite:setXScale(x) self.xScale = x end
function Sprite:setYScale(y) self.yScale = y end
---@param x number? The x scale, or the scale of both axises if `y` is nil.
---@param y number? The y scale.
function Sprite:setScale(x, y) 
	self.xScale = x
	self.yScale = y or x
end

function Sprite:getRotation() return self.rotation end
---@param r number The sprite's rotation, in radians.
function Sprite:setRotation(r) self.rotation = r end


return Sprite
