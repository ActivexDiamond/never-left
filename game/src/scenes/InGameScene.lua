local middleclass = require "libs.middleclass"
local ItemManager = require "core.ItemManager"

local Scene = require "cat-paw-mods.Scene"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local Map = require "core.Map"
local Player = require "core.Player"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class InGameScene : Scene
---@overload fun(): self
local InGameScene = middleclass("InGameScene", Scene)
	
function InGameScene:initialize()
	Scene.initialize(self)
	self.map = Map(self)
	self:addObject(self.map)

	
	self.player = Player(self, self.map:getCenterPoint())
	self:addObject(self.player)
--	self:addObject(ItemManager(self))
end

--============================ Constants ==============================

--============================ Core API ==============================

function InGameScene:update(dt)
	Scene.update(self, dt)
end

function InGameScene:draw(g2d)
	g2d.push('all')
		local px, py, pw, ph = self.player:getBoundingBox()
		local sw, sh = GAME:getGameDimensions()
		local cameraX = -px +((sw - pw) / 2)
		local cameraY = -py +((sh - ph) / 2)

		g2d.translate(cameraX, cameraY)

	--	Scene.draw(self, g2d)
		self.player:earlyDraw(g2d)
		self.map:draw(g2d)
		self.player:draw(g2d)
	g2d.pop()
		g2d.setColor(1,0,0)
		g2d.setPointSize(8)
--		g2d.points(sw/2, sh/2)	
end

--============================ API ==============================

--============================ Callbacks ==============================
InGameScene[EvKeyPress] = function(self, e)
	if e.key == 'space' then
	end
end

function InGameScene:enter()
	Scene.enter(self)
	GAME:setBackgroundColor({0, 0, 0})
end

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return InGameScene
