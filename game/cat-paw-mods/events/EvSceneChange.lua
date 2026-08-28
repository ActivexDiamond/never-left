local middleclass = require "libs.middleclass"
local Event = require "cat-paw.core.patterns.event.Event"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local EvSceneChange = middleclass("EvSceneChange", Event)
function EvSceneChange:initialize(scene)
	Event.initialize(self)
	self.scene = scene
end

------------------------------ Core API ------------------------------

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------

return EvSceneChange