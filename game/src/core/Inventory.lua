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
---@field slotRows number
---@field slotCols number
---@field selectedSlotColor number[]
---@field highlightedSlotColor number[]
---@field backgroundColor number[]
---@field outlineColor number[]
---@overload fun(id: string, parent: WorldObject, x: number, y: number): self
---@overload fun(id: string, parent: WorldObject, anchor: string): self
local Inventory = middleclass("Inventory", Object)
	
function Inventory:initialize(id, parent, x, y)
	Object.initialize(self, id)
	self.parent = parent
	if type(x) == 'number' then
		self.x = x
		self.y = y
	elseif type(x) == 'string' then
		if x == 'top_right' then
			local sw, sh = GAME:getGameDimensions()
			self.x = sw - (self.slotVisualSize * self.slotCols) - (self.slotVisualPadding * self.slotCols)
			self.y = self.slotVisualSize * self.slotRows + self.slotVisualPadding * self.slotRows + 2
		end
	else
		self.x = 0
		self.y = 0
	end

	self.slotCount = self.slotRows * self.slotCols
	self.slots = {}

	self.drawBackground = false

	TMP.mouseItem = nil
	TMP.mouseSlot = nil
	TMP.highlightedSlot = nil

	self:setPosition()
end

--============================ Core API ==============================

function Inventory:update(dt)
	Object.update(self, dt)
	local mx, my = push:toGame(love.mouse.getPosition())
	
	--FIXME: Terrible performance
	--Ducttape fix for cross-inv interaction. Only clear the highlighted slot if it belongs to you.

	for k, v in ipairs(self.slots) do
	 	if TMP.highlightedSlot == v then 
	 		TMP.highlightedSlot = nil
	 	end
	end

	for k, v in ipairs(self.slots) do
		if not v.selected then
			if mx and my and pointInRect(mx, my, v) then
				v.color = self.highlightedSlotColor
				TMP.highlightedSlot = v
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

		if self.drawBackground then
			local b = self.background
			local out = b.outlineThickness

			g2d.setColor(self.outlineColor)
			g2d.rectangle('fill', b.x - out, b.y - out, b.w + out * 2, b.h + out * 2)

			g2d.setColor(self.backgroundColor)
			g2d.rectangle('fill', b.x, b.y, b.w, b.h)
		end		

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
		if TMP.mouseItem then
			local mx, my = push:toGame(love.mouse.getPosition())
			mx = mx or 50
			my = my or 50
			g2d.setColor(1, 1, 1, 1)
			local iw, ih = TMP.mouseItem.sprite:getDimensions()
			g2d.draw(TMP.mouseItem.sprite, mx - sz / 2, my - sz / 2, nil, sz / ih, sz / ih)
		end
	g2d.pop()
end

--============================ Internals ==============================

function Inventory:_attemptCombine()
	print("Combined: ", TMP.mouseItem.ID, TMP.highlightedSlot.item.ID)
	
	if (TMP.mouseItem.ID == "chalk_floor" and TMP.highlightedSlot.item.ID == "missing_page") or
			(TMP.mouseItem.ID == "missing_page" and TMP.highlightedSlot.item.ID == "chalk_floor") then
	TMP.mouseSlot.item = nil
	TMP.highlightedSlot.item = nil

	CHALK_DONE = true

	GAME:getCurrentState().player:_showItemMenu({
		dialogue = [[> I think if I copy the symbol on this page...
> Onto the floor... Something might happen.
]]
	})
	return
	end

	GAME:getCurrentState().player:_showItemMenu({
		dialogue = "> These two don't go together..."
	}, true)
end


function Inventory:_attemptUse(obj)
	print("Used on: ", obj.ID)

	if obj.layer and obj.layer == "doors" then
		if obj.keyItem == TMP.mouseItem.ID then
			PLAY_SOUND(AUDIO.SFX.crowbar_use)
			obj.opened = true
--			self.parent.scene.map.bumpWorld:remove(obj)
			
			TMP.mouseSlot.item = nil
			TMP.mouseSlot.selected = false
			TMP.mouseSlot = nil
			TMP.mouseItem = nil
			return
		end
	end

	GAME:getCurrentState().player:_showItemMenu({
		dialogue = "> I can't use this here..."
	}, true)
end

--============================ Callbacks ==============================

function Inventory.mouseInteractFilter(item)

	if item.layer then
		if item.layer == "walls" then
			return false
		end
	end

	if item.ID then
		if item.ID == "player_interact_box" or
				item.ID == "player" then
			return false
		end
	end

	return true
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

function Inventory:removeItemById(id)
	for k, v in ipairs(self.slots) do
		if v.item and v.item.ID == id then
			v.item = nil
			return true
		end
	end
	return false
end


--============================ Getters / Setters ==============================

---@param x number?
---@param y number?
function Inventory:setPosition(x, y)
	--FIXME: Clears stored items!!!
	self.slots = {}

	x = x or self.x
	y = y or self.y
	local i = 0
	for slotX = 1, self.slotCols do
		for slotY = 1, self.slotRows do
			y = y - (self.slotVisualSize + self.slotVisualPadding)
			i = i + 1
			table.insert(self.slots, {
				index = i,
				x = x,
				y = y,
				w = self.slotVisualSize,
				h = self.slotVisualSize,
				color = self.slotColor,

				colors = {
					DEFAULT = self.slotColor,
					SELECTED = self.selectedSlotColor,
					HIGHLIGHTED = self.highlightedSlotColor,
				},
				inventory = self,
				selected = false,
				item = nil,
			})
		end
		x = x + (self.slotVisualSize + self.slotVisualPadding)
		y = self.y
	end

	local first = self.slots[1]
	local last = self.slots[#self.slots]
	local PAD = 2

	self.background = {
		x = first.x - PAD,
		y = first.y - PAD,
		w = last.x - (first.x - PAD) + last.w + PAD,
		h = last.y - (first.y - PAD) + last.h + PAD,
		outlineThickness = 0.5
	}


end

return Inventory
