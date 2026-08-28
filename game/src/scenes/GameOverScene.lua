--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      GameOverScene.lua

local middleclass = require "libs.middleclass"
local Scene = require "cat-paw-mods.Scene"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class GameOverScene : Scene
---@overload fun(): self
local GameOverScene = middleclass("GameOverScene", Scene)
	
function GameOverScene:initialize()
	Scene.initialize(self)
end

--============================ Core API ==============================
function GameOverScene:update(dt)
	Scene.update(self, dt)
end

function GameOverScene:draw(g2d)
	Scene.draw(self, g2d)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return GameOverScene
