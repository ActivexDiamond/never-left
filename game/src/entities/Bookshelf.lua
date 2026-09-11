local middleclass = require "libs.middleclass"
local Inventory = require "core.Inventory"

local DataRegistry = require "core.DataRegistry"
local AssetRegistry = require "core.AssetRegistry"

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
	PLAY_SOUND(AUDIO.SFX.paperrustle)
	local i1 = TMP.mouseSlot.item
	local i2 = TMP.highlightedSlot.item
	TMP.mouseSlot.item = i2
	TMP.highlightedSlot.item = i1
	
end

function Bookshelf:_checkSolution()
	--Only run the check if all slots are full.
	local itemCount = 0
	for k, v in ipairs(self.slots) do 
		if v.item then itemCount = itemCount + 1 end
	end
	if not DEBUG.DEV_MODE and itemCount < 3 then return false end

	if DEBUG.DEV_MODE or (self.slots[1].item.ID == "symbol_1" and
			self.slots[2].item.ID == "symbol_2" and
			self.slots[3].item.ID == "symbol_3") then
		PLAY_SOUND(AUDIO.SFX.crowbar_pickup)
		local crowbar = {ID = "crowbar"}
		DataRegistry:applyStats(crowbar)
		crowbar.sprite, crowbar.sx, crowbar.sy = AssetRegistry:getSprObj(crowbar)

		self.scene.player.inv:addItem(crowbar)

		self.scene.map.bumpWorld:remove(self.tiledObject)
		self.scene:removeObject(self)
		return true
	end
end


--============================ Getters / Setters ==============================

function Bookshelf:isShown() return self.shown end

function Bookshelf:toggleShown()
	self.shown = not self.shown
	if not self.shown then
		self:_checkSolution()
	end
end

return Bookshelf
