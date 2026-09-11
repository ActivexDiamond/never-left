--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      MenuScene.lua

local middleclass = require "libs.middleclass"
local Scene = require "cat-paw-mods.Scene"
local uMath = require "cat-paw.core.utilities.uMath"

local AssetRegistry = require "core.AssetRegistry"
local DataRegistry = require "core.DataRegistry"

local EvWindowResize = require "cat-paw.core.patterns.event.os.EvWindowResize"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"
local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class MenuScene : Scene
---@field LOGOS {ID: string, DURATION: number, w: number, h: number}[] An array holding some data about each logo.
---@field BACKGROUND_COLOR number[3] The color to use for the background of this scene.
---@field FADE_IN boolean Whether to fade each logo in slowly, or pop it in immediately.
---@field FADE_OUT boolean Whether to fade each logo out slowly, or remove it in immediately.
---@overload fun(): self
local MenuScene = middleclass("MenuScene", Scene)
	
function MenuScene:initialize()
	Scene.initialize(self)
	local sw, sh = GAME:getGameDimensions()
	self.spr, self.sx, self.sy = AssetRegistry:getSprGui({
		ID = "main_menu",
		w = sw,
		h = sh,
	})
	self.spr:setFilter('linear')
	self.cooldown = 2
end

--============================ Core API ==============================
function MenuScene:update(dt)
	Scene.update(self, dt)
	self.cooldown = self.cooldown - dt
end

function MenuScene:draw(g2d)
	Scene.draw(self, g2d)
	g2d.push('all')
		g2d.setColor(1, 1, 1, 1)
		g2d.draw(self.spr, 0, 0, 0, self.sx, self.sy)
	g2d.pop()
end

--============================ API ==============================

--============================ Callbacks ==============================
MenuScene[EvKeyPress] = function(self, e)
	if self.fsm:getCurrentState() ~= self then return end

	if self.cooldown > 0 then return end

	GAME:goTo(GAME.ESceneIds.IN_GAME)
end

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return MenuScene
