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
	self.sprite = love.graphics.newImage("assets/spr/obj/gameover.png")
end

function GameOverScene:draw(g2d)
	Scene.draw(self, g2d)
	local iw, ih = self.sprite:getDimensions()
	local x = (160 - iw) / 2
	local y = (90 - ih) / 2
	g2d.draw(self.sprite, x, y)
end

--============================ API ==============================

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return GameOverScene
