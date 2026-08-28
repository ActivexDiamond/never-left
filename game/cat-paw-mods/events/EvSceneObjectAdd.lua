local middleclass = require "libs.middleclass"
local EvSceneChange = require "cat-paw-mods.events.EvSceneChange"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
local EvSceneObjectAdd = middleclass("EvSceneObjectAdd", EvSceneChange)
function EvSceneObjectAdd:initialize(scene, obj)
	EvSceneChange.initialize(self, scene)
	self.object = obj	
end

------------------------------ Core API ------------------------------

------------------------------ API ------------------------------

------------------------------ Getters / Setters ------------------------------

return EvSceneObjectAdd
