--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      ItemSpawner.lua

local middleclass = require "libs.middleclass"
local CraftingItem = require "core.CraftingItem"

local push = require "libs.push"

local AssetRegistry = require "core.AssetRegistry"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"
local EvMouseRelease = require "cat-paw.core.patterns.event.mouse.EvMouseRelease"

local utils = require "libs.utils"

--============================ Helper Methods ==============================
local function drawRect(g2d, r, dontFill)
	local mode = dontFill and 'line' or 'fill'
	g2d.rectangle('fill', r.x, r.y, r.w, r.h)
end


--============================ Constructor ==============================

---@class ItemManager : Middleclass
---@overload fun(scene: Scene): self
local ItemManager = middleclass("ItemManager")

function ItemManager:initialize(scene)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)

	self.grabbedItem = nil
	self.oldGrabbedPosition = nil
	self.items = {}
	self.scene = scene
	self.currentRecipe = {}
	self.grinder = {
		x = 74, y = 72,
		w = 92 - 74, h = 85 - 72,
	}
	self.shelf = {
		x = 0,       y = 20,
		w = 36, h = 90 - 20,
	}
	self.btnMix = {
		x = 68, y = 53,
		w = 100 - 68, h = 63 - 53
	}

	self:_spawnItem("ginger", 15, 20)
	self:_spawnItem("rosemary", 15, 40)
	self:_spawnItem("camomile", 15, 60)

end

--============================ Core API ==============================

function ItemManager:update(dt)
	if self.grabbedItem then
		local mx, my = push:toGame(love.mouse.getPosition())
		if mx and my then
			self.grabbedItem.x = mx - self.grabbedItem.w / 2
			self.grabbedItem.y = my - self.grabbedItem.h / 2
		end
	end
end

function ItemManager:draw(g2d)
	if DEBUG.DRAW_BOUNDING_BOXES then
		g2d.push('all')
			g2d.setColor(1, 1, 1, 0.3)
			drawRect(g2d, self.shelf)
			drawRect(g2d, self.grinder)

			for _, item in ipairs(self.items) do
				drawRect(g2d, item)
			end
		g2d.pop()
	end
	g2d.print(#self.currentRecipe, 50, 50)

	if self.valid ~= nil then
		local spr, sx, sy = AssetRegistry:getSprInv({ID = "bag", w = 16, h = 16})
		g2d.draw(spr, 98, 70, 0, sx, sy)	
	end
end

--============================ API ==============================

--FIXME: Proper recipes.
local TARGET = {
	"camomile", "rosemary", "ginger"
}

function ItemManager:mixIngredients()
	local valid = true
	for i = 1, #self.currentRecipe do
		if self.currentRecipe[i] ~= TARGET[i] then
			valid = false
		end
	end
	self.valid = valid
	self.currentRecipe = {}
	self:_spawnItem("ginger", 15, 20)
	self:_spawnItem("rosemary", 15, 40)
	self:_spawnItem("camomile", 15, 60)
end

function ItemManager:addIngredient(item)
	table.insert(self.currentRecipe, item.ID)

end

function ItemManager:addItem(item)
	table.insert(self.items, item)
	self.scene:addObject(item)
end

function ItemManager:removeItem(item)
	for k, v in ipairs(self.items) do
		if v == item then
			table.remove(self.items, k)
			self.scene:removeObject(item)
			return true
		end
	end
	return false
end


--============================ Callbacks ==============================
ItemManager[EvMousePress] = function(self, e)
	local x, y = push:toGame(e.x, e.y)
	if not (x and y) then return end
	local b = self.btnMix
	if utils.rectIntersects(x, y, 1, 1, b.x, b.y, b.w, b.h) then
		self:mixIngredients()
	end
		
	for _, v in ipairs(self.items) do
		if	utils.rectIntersects(x, y, 1, 1, v.x, v.y, v.w, v.h) then
			self.grabbedItem = v
			self.oldGrabbedPosition = {x = v.x, y = v.y}
			break
		end
	end
end

ItemManager[EvMouseRelease] = function(self, e)
	if not self.grabbedItem then return end
	local s = self.shelf
	local g = self.grinder
	local o = self.grabbedItem
	local iW = self.grabbedItem.w
	local iH = self.grabbedItem.h
	local mx, my = push:toGame(e.x, e.y)
	--If at grinder, fade out.
	if utils.rectIntersects(o.x, o.y, o.w, o.h, g.x, g.y, g.w, g.h) then
		self:addIngredient(self.grabbedItem)
		self:removeItem(self.grabbedItem)
	--elseif not at grinder and outside of shelf, snap back.
	elseif not utils.rectIntersects(s.x + iW, s.y + iH, s.w - iW * 2, s.h - iH * 2, 
			o.x, o.y, o.w, o.h) then
		o.x = self.oldGrabbedPosition.x
		o.y = self.oldGrabbedPosition.y
	end

	--Clear out the grabbed item.
	self.grabbedItem = nil
	self.oldGrabbedPosition = nil
end


--============================ Internals ==============================

function ItemManager:_spawnItem(id, x, y)
	local item = CraftingItem(id, self, x, y)
	self:addItem(item)
end


--============================ Getters / Setters ==============================

return ItemManager
