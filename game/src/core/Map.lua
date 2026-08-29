local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"
local bump = require "cat-paw.core.physics.bump"

local AssetRegistry = require "core.AssetRegistry"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Map : WorldObject
---@field ZOOM number
---@overload fun(scene: Scene): self
local Map = middleclass("Map", WorldObject)
	
function Map:initialize(scene)
	WorldObject.initialize(self, "map", scene, 0, 0)

	self.bumpWorld = bump.newWorld()
	local level = require("assets.map.main")
	for _, layer in pairs(level.layers) do
		if layer.name == "walls" then
			for _, wall in pairs(layer.objects) do
				self.bumpWorld:add({}, wall.x, wall.y, wall.width + 0.0001, wall.height + 0.0001)
			end
		end
	end
end

--============================ Core API ==============================

function Map:update(dt)
	WorldObject.update(self, dt)
end

function Map:draw(g2d)
--	WorldObject.draw(self, g2d)
	local spr, sx, sy = AssetRegistry:getSprObj(self)
	local b = 1
	g2d.setColor(b, b, b, 1)
	g2d.draw(spr, self.pos.x, self.pos.y, 0, self.ZOOM, self.ZOOM)
	g2d.setColor(1, 1, 1, 1)

	if DEBUG.DRAW_BOUNDING_BOXES then
		for k, v in pairs(self.bumpWorld:getItems()) do
			g2d.setColor(1, 0, 0, 1)
			g2d.rectangle('fill', self.bumpWorld:getRect(v))
		end
	end
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
