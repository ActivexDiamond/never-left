local middleclass = require "libs.middleclass"
local Object = require "core.Object"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class Inventory : Object
---@field slotVisualSize number
---@field slotVisualPadding number
---@field slotColor number
---@overload fun(): self
local Inventory = middleclass("Inventory", Object)
	
function Inventory:initialize(id, parent)
	Object.initialize(self, id)
	self.parent = parent
	self.items = {}

	local sw, sh = GAME:getGameDimensions()
	self.x = sw - (self.slotVisualSize * 3) - (self.slotVisualPadding * 3)
	self.y = self.slotVisualSize * 3 +self.slotVisualPadding * 3 + 2
end

--============================ Core API ==============================

function Inventory:update(dt)
	Object.update(self, dt)

end

function Inventory:draw(g2d)
	Object.draw(self, g2d)
	g2d.push('all')
		g2d.setStencilTest()
		g2d.translate(-self.parent.scene.cameraX, -self.parent.scene.cameraY)
		g2d.setColor(self.slotColor, self.slotColor, self.slotColor, 1)
		g2d.setLineWidth(1)
		
		local x, y = self.x, self.y
		for slotX = 1, 3 do
			for slotY = 1, 3 do
				y = y - (self.slotVisualSize + self.slotVisualPadding)
				g2d.rectangle('line', x, y, self.slotVisualSize, self.slotVisualSize)
				local item = self.items[slotX + slotY * 3] 
				if item then
					g2d.draw(item.sprite, x, y, nil, item.sx, item.sy)
				end
			end
				x = x + (self.slotVisualSize + self.slotVisualPadding)
				y = self.y
		end
	g2d.pop()
end

--============================ API ==============================

function Inventory:addItem(item)
	table.insert(self.items, item)	
end


--============================ Internals ==============================

--============================ Getters / Setters ==============================

return Inventory
