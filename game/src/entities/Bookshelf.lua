local middleclass = require "libs.middleclass"
local Inventory = require "core.Inventory"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Bookshelf : Inventory
---@overload fun(scene: Scene, obj: TiledObject): self
local Bookshelf = middleclass("Bookshelf", Inventory)

function Bookshelf:initialize(scene, obj)
	local sw, sh = GAME:getGameDimensions()
	Inventory.initialize(self, "bookshelf_inventory", self, sw / 2, sh / 2)

	self.x = self.x - self.background.w / 2
	self.y = self.y + self.background.h
	self:setPosition()
	self.drawBackground = true

	self.scene = scene
	self.tiledObject = obj

	self.shown = false
end

--============================ Core API ==============================

function Bookshelf:update(dt)
	if self.shown then
		Inventory.update(self, dt)
	end
end

function Bookshelf:draw(g2d)
	if self.shown then
		Inventory.draw(self, g2d)
	end
end

--============================ API ==============================

--============================ Internals ==============================

function Bookshelf:_attemptCombine()
	PLAY_SOUND(dw
	local i1 = TMP.mouseSlot.item
	local i2 = TMP.highlightedSlot.item
	TMP.mouseSlot.item = i2
	TMP.highlightedSlot.item = i1
	
end


--============================ Getters / Setters ==============================

function Bookshelf:isShown() return self.shown end

function Bookshelf:toggleShown()
	self.shown = not self.shown
	print(self.shown)
end

return Bookshelf
