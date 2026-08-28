local middleclass = require "libs.middleclass"

local DataRegistry = require "core.DataRegistry"
local EvFileChange = require "cat-paw.core.patterns.event.dev.EvFileChange"

local Event = require "cat-paw.core.patterns.event.Event"
local EventSystem = require "cat-paw.core.patterns.event.EventSystem"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
---@class Object
---@overload fun(): self
--@field [parent=#core.Object] #string id (optional) A string-ID to be used for injecting stats into the object through the registry. Also stored in object.ID.
local Object = middleclass("Object")
function Object:initialize(id)
	if id then
		self.ID = id
		DataRegistry:applyStats(self)
	else
		self.ID = "undefined"
	end
	
	self.depth = 0
	--Not specifying which events will slow down the EventSystem as a whole,
	--but not by a lot.
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
end

------------------------------ Core API ------------------------------
function Object:update(dt)

end

---@param g2d love.graphics
function Object:draw(g2d)

end

function Object:setDepth(depth)
	self.depth = depth;
end

--============================ Callbacks ==============================
Object[EvFileChange] = function(self, e)
	DataRegistry:loadData()
	DataRegistry:applyStats(self)	
end

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------


return Object
