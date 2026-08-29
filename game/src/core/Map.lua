local middleclass = require "libs.middleclass"
local WorldObject = require "core.WorldObject"

local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"
local bump = require "cat-paw.core.physics.bump"

local DataRegistry = require "core.DataRegistry"
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
	self.objs = {}
	local level = require("assets.map.main")
	local emptyIndex = 0
	for _, layer in pairs(level.layers or {}) do
		self.objs[layer.name] = {}
		print("Processing layer: ", layer.name)
		for _, tiledObj in pairs(layer.objects or {}) do
			local obj = {
				x = tiledObj.x, y = tiledObj.y, 
				phyW = tiledObj.width + 0.0001, phyH = tiledObj.height + 0.0001,
				ID = tiledObj.name,
				layer = layer.name,
				currentFrame = 0,
			}
			
			self.bumpWorld:add(obj, obj.x, obj.y, obj.phyW, obj.phyH)

			--Highlight / sparkle
			if layer.name ~= "walls" then	
				obj.centerX = obj.x + obj.phyW / 2
				obj.centerY = obj.y + obj.phyH / 2
			end
			if layer.name == "walls" then
				obj.ID = "wall"
			elseif layer.name == "doors" then
				obj.opened = false
			elseif layer.name == "dialogues" then
			elseif layer.name == "searchables" then
				if #obj.ID == 0 then
					obj.ID = "empty_container_" .. tostring(emptyIndex)
					emptyIndex = emptyIndex + 1
				end
				obj.collected = false
			elseif layer.name == "pickables" then
				obj.sprite = true
			elseif layer.name == "pz_candles" then
			elseif layer.name == "pz_push" then
			elseif layer.name == "pz_symbol_sorter" then
			elseif layer.name == "pz_ritual" then
			end

			assert(obj.ID and #obj.ID > 0, "Object with no ID from layer: " .. tostring(layer.name))
			self.objs[layer.name][obj.ID] = obj
			DataRegistry:applyStats(obj)
			if obj.sprite then
				print(obj.ID)
				obj.sprite, obj.sx, obj.sy = AssetRegistry:getSprObj(obj)
			end
		end
	end

--	self.objs.doors.outside = {}

	self.objs.doors.ritual.opened = true
	self.objs.doors.basement.opened = true

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

	for k, v in pairs(self.objs.pickables) do
		g2d.draw(v.sprite, v.x, v.y, nil, v.sx, v.sy)
	end

	if DEBUG.DRAW_BOUNDING_BOXES then
		for k, v in pairs(self.bumpWorld:getItems()) do
			g2d.rectangle('fill', self.bumpWorld:getRect(v))
			g2d.setColor(1, 0, 0, 1)
		end
	end
end

--============================ API ==============================

--============================ Internals ==============================
Map[EvKeyPress] = function(self, e)
	if e.key == 'space' then
--		PLAY_SOUND(AUDIO.SFX.clockticking, nil, nil, 0.1)
	end
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
