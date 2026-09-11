local middleclass = require "libs.middleclass"
local Inventory = require "core.Inventory"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Bookshelf : Inventory
---@overload fun(scene: Scene, obj: TiledObject): self
local Bookshelf = middleclass("Bookshelf", Inventory)

function Bookshelf:initialize(scene, obj)
	Inventory.initialize(self, "bookshelf", self)
	self.scene = scene
	self.tiledObject = obj
	
	local sw, sh = GAME:getGameDimensions()
	self.x = sw / 2
	self.y = sh / 2
	self.shown = false
end

--============================ Core API ==============================

function Bookshelf:update(dt)
	Inventory.update(self, dt)
end

function Bookshelf:draw(g2d)
	Inventory.draw(self, g2d)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

function Bookshelf:isShown() return self.shown end

function Bookshelf:toggleShown()
	self.shown = not self.shown
	print(self.shown)
end

return Bookshelf
