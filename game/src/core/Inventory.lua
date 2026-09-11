local middleclass = require "libs.middleclass"
local Object = require "core.Object"

local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"

local push = require "libs.push"

--============================ Helper Methods ==============================

--Stolen from bump.
---@param px number The point to check.
---@param py number The point to check.
---@param x number The rectangle to check.
---@param y number The rectangle to check.
---@param w number The rectangle to check.
---@param h number The rectangle to check.
---@return boolean
---@overload fun(px: number, py: number, rect: {x: number, y: number, w: number, h: number}): boolean
local function pointInRect(px, py, x, y, w, h)
	local DELTA = 1e-10 -- floating-point margin of error
	if not y then
		x, y, w, h = x.x, x.y, x.w, x.h
	end

	return px - x > DELTA and 
			py - y > DELTA and
			x + w - px > DELTA and 
			y + h - py > DELTA
end

--============================ Constructor ==============================

---@class Inventory : Object
---@field slotVisualSize number
---@field slotVisualPadding number
---@field slotColor number[]
---@field selectedSlotColor number[]
---@field highlightedSlotColor number[]
---@overload fun(id: string, parent: WorldObject): self
local Inventory = middleclass("Inventory", Object)
	
function Inventory:initialize(id, parent)
	Object.initialize(self, id)
	self.parent = parent
	self.slots = {}

	local sw, sh = GAME:getGameDimensions()
	self.x = sw - (self.slotVisualSize * 3) - (self.slotVisualPadding * 3)
	self.y = self.slotVisualSize * 4 + self.slotVisualPadding * 4 + 2

	self.mouseItem = nil
	self.mouseSlot = nil
	self.highlightedSlot = nil
	
	local x, y = self.x, self.y
	for slotX = 1, 3 do
		for slotY = 1, 4 do
			y = y - (self.slotVisualSize + self.slotVisualPadding)
			table.insert(self.slots, {
				x = x,
				y = y,
				w = self.slotVisualSize,
				h = self.slotVisualSize,
				color = self.slotColor,

				selected = false,
				item = nil,
			})
		end
		x = x + (self.slotVisualSize + self.slotVisualPadding)
		y = self.y
	end
end

--============================ Core API ==============================

function Inventory:update(dt)
	Object.update(self, dt)
	local mx, my = push:toGame(love.mouse.getPosition())
	self.highlightedSlot = nil
	for k, v in ipairs(self.slots) do
		if not v.selected then
			if mx and my and pointInRect(mx, my, v) then
				v.color = self.highlightedSlotColor
				self.highlightedSlot = v
			else
				v.color = self.slotColor
			end
		end
	end
end

function Inventory:draw(g2d)
	Object.draw(self, g2d)
	g2d.push('all')
		g2d.setStencilTest()
		g2d.translate(-self.parent.scene.cameraX, -self.parent.scene.cameraY)
		g2d.setLineWidth(1)
		
		local sz = self.slotVisualSize - 1
		for k, v in ipairs(self.slots) do
			g2d.setColor(v.color)
			g2d.rectangle('line', v.x, v.y, v.w, v.h)
			if v.item and not v.selected then
				g2d.setColor(1, 1, 1, 1)
				local iw, ih = v.item.sprite:getDimensions()
				g2d.draw(v.item.sprite, v.x + 0.5, v.y + 0.5, nil, sz / ih, sz / ih)
			end
		end
		if self.mouseItem then
			local mx, my = push:toGame(love.mouse.getPosition())
			mx = mx or 50
			my = my or 50
			g2d.setColor(1, 1, 1, 1)
			local iw, ih = self.mouseItem.sprite:getDimensions()
			g2d.draw(self.mouseItem.sprite, mx - sz / 2, my - sz / 2, nil, sz / ih, sz / ih)
		end
	g2d.pop()
end

--============================ Internals ==============================

function Inventory:_attemptCombine()
	print("Combined: ", self.mouseItem.ID, self.highlightedSlot.item.ID)
end


function Inventory:_attemptUse(obj)
	print("Used on: ", obj.ID)
end

--============================ Callbacks ==============================

local function mouseInteractFilter(item)
	if item.layer == "walls" then
		return false
	end

	return true
end


Inventory[EvMousePress] = function(self, e)
	local mx, my = push:toGame(e.x ,e.y)

	--Not holding item and clicked on a slot.
	if not self.mouseItem and self.highlightedSlot then
		--Only select it and pick up, if it is non-empty.
		if self.highlightedSlot.item then
			self.highlightedSlot.selected = true
			self.mouseItem = self.highlightedSlot.item
			self.mouseSlot = self.highlightedSlot
			self.highlightedSlot.color = self.selectedSlotColor
		end
		return
	end

	--Holding an item, and clicked on an empty slot.
	if self.mouseItem and self.highlightedSlot and not self.highlightedSlot.item then
		self.highlightedSlot.item = self.mouseItem
		self.mouseSlot.item = nil

		self.mouseSlot.selected = false
		self.mouseSlot.color = self.slotColor
		self.mouseItem = nil
		self.mouseSlot = nil
		return
	end
	
	--Holding an item and clicked on a slot with an item.
	if self.mouseItem and self.highlightedSlot and self.highlightedSlot.item then
		self:_attemptCombine()
		self.mouseSlot.selected = false
		self.mouseSlot.color = self.slotColor
		self.mouseItem = nil
		self.mouseSlot = nil
		return
	end
	
	--Holding an item, and click in-world.
	--TODO: RANGE CHECK
	if self.mouseItem then
		local scene = self.parent.scene
		local worldX = mx - scene.cameraX
		local worldY = my - scene.cameraY
		local obj = scene.map.bumpWorld:queryPoint(worldX, worldY, mouseInteractFilter)[1]
		if obj then
			self:_attemptUse(obj)
		end
		return
	end
end

--============================ API ==============================

function Inventory:addItem(item)
	for k, v in ipairs(self.slots) do
		if not v.item then
			v.item = item
			return true
		end
	end
	return false
end

--============================ Getters / Setters ==============================

return Inventory
