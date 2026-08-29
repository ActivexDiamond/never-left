local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local AssetRegistry = require "core.AssetRegistry"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Map : WorldObject
---@field ZOOM number
---@overload fun(scene: Scene): self
local Map = middleclass("Map", WorldObject)
	
function Map:initialize(scene)
	WorldObject.initialize(self, "map", scene, 0, 0)
end

--============================ Core API ==============================

function Map:update(dt)
	WorldObject.update(self, dt)
end

function Map:draw(g2d)
	WorldObject.draw(self, g2d)
	local spr, sx, sy = AssetRegistry:getSprObj(self)
	g2d.setColor(1, 1, 1)
	print(self.pos)
	g2d.draw(spr, self.pos.x, self.pos.y, 0, self.ZOOM, self.ZOOM)
end

--============================ API ==============================

--============================ Internals ==============================
Map[EvKeyPress] = function(self, e)
	
end

--============================ Getters / Setters ==============================

function Map:getCenterPoint()
	local spr, sx, sy = AssetRegistry:getSprObj(self)

	local w, h = spr:getDimensions()
	return w / 2, h / 2
end

function Map:getMapDimensions()
	local spr, sx, sy = AssetRegistry:getSprObj(self)
	return spr:getDimensions()
end


return Map
