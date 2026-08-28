local middleclass = require "cat-paw.core.patterns.oop.middleclass"
local Event = require "cat-paw.core.patterns.event.Event"

local EvFileChange = middleclass("EvFileChange", Event)
function EvFileChange:initialize(filename)
	Event.initialize(self)
	self.filename = filename
end

return EvFileChange
