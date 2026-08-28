local middleclass = require "libs.middleclass"
local EvSceneChange = require "cat-paw-mods.events.EvSceneChange"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local EvSceneObjectRemove = middleclass("EvSceneObjectRemove", EvSceneChange)
function EvSceneObjectRemove:initialize(scene, obj)
	EvSceneChange.initialize(self, scene)
	self.object = obj	
end

------------------------------ Core API ------------------------------

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------

return EvSceneObjectRemove
