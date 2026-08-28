--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      LogosScene.lua

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
---@class LogosScene : Scene
---@field LOGOS {ID: string, DURATION: number, w: number, h: number}[] An array holding some data about each logo.
---@field BACKGROUND_COLOR number[3] The color to use for the background of this scene.
---@field FADE_IN boolean Whether to fade each logo in slowly, or pop it in immediately.
---@field FADE_OUT boolean Whether to fade each logo out slowly, or remove it in immediately.
---@overload fun(): self
local LogosScene = middleclass("LogosScene", Scene)
	
function LogosScene:initialize()
	Scene.initialize(self)

	self.ID = "logos_scene"
	DataRegistry:applyStats(self)


	local w, h = GAME:getGameDimensions()
	self.centerX, self.centerY = w / 2, h / 2

	self.currentLogoIndex = 1
	self.currentLogo = self.LOGOS[self.currentLogoIndex]
	self.lastTransitionTime = love.timer.getTime()

end

--============================ Core API ==============================
function LogosScene:update(dt)
	Scene.update(self, dt)
	if DEBUG.SKIP_LOGOS then GAME:goTo(GAME.ESceneIds.IN_GAME) end
	if love.timer.getTime() - self.lastTransitionTime > self.currentLogo.DURATION then
		self:_nextLogo()
	end
end

function LogosScene:draw(g2d)
	Scene.draw(self, g2d)
	g2d.push('all')
		local spr, sx, sy = AssetRegistry:getSprGui(self.currentLogo)
		local x = self.centerX - self.currentLogo.w / 2
		local y = self.centerY - self.currentLogo.h / 2
		g2d.setColor(1, 1, 1, self:_getCurrentAlpha())
		g2d.draw(spr, x, y, 0, sx, sy)
	g2d.pop()
end

--============================ API ==============================

--============================ Callbacks ==============================
LogosScene[EvKeyPress] = function(self, e)
	if self.fsm:getCurrentState() ~= self then return end
	if e.key == 'space' then self:_nextLogo() end
end

--============================ Internals ==============================
function LogosScene:_getCurrentAlpha()
	local progress = (love.timer.getTime() - self.lastTransitionTime) / 2
	progress = uMath.bind(progress, 0, 1)
	if progress <= 0.5 and self.FADE_IN then
		return uMath.map(progress, 0, 0.5, 0, 1)
	elseif progress > 0.5 and self.FADE_OUT then
		return uMath.map(progress, 0.5, 1, 1, 0)
	end
	return 1
end

function LogosScene:_nextLogo()
	print(self.currentLogoIndex)
	self.currentLogoIndex = self.currentLogoIndex + 1
	self.currentLogo = self.LOGOS[self.currentLogoIndex]
	self.lastTransitionTime = love.timer.getTime()
	
	if not self.currentLogo then
		self.currentLogoIndex = 0
		GAME:goTo(GAME.ESceneIds.IN_GAME)
	end
end

--============================ Getters / Setters ==============================

return LogosScene
