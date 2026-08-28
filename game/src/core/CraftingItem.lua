--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      CraftingItem.lua

local middleclass = require "libs.middleclass"
local Object = require "core.Object"

local AssetRegistry = require "core.AssetRegistry"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class CraftingItem : Object
---@overload fun(id: string, itemManager: ItemManager, x: number, y: number): self
local CraftingItem = middleclass("CraftingItem", Object)
	
function CraftingItem:initialize(id, itemManager, x, y)
	Object.initialize(self, id)
	self.im = itemManager
	self.x, self.y = x, y

	self.w = 16
	self.h = 16
end

--============================ Core API ==============================

function CraftingItem:update(dt)
	Object.update(self, dt)
end

function CraftingItem:draw(g2d)
	Object.draw(self, g2d)
	local spr, sx, sy = AssetRegistry:getSprInv(self)
	g2d.draw(spr, self.x, self.y, 0, sx, sy)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return CraftingItem
