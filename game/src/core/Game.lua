--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      Game.lua

local middleclass = require "libs.middleclass"

local AbstractGame = require "cat-paw.engine.AbstractGame"

local LogosScene = require "scenes.LogosScene"
local InGameScene = require "scenes.InGameScene"
local GameOverScene = require "scenes.GameOverScene"

local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local EvWindowResize = require "cat-paw.core.patterns.event.os.EvWindowResize"
local EvMousePress = require "cat-paw.core.patterns.event.mouse.EvMousePress"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"

local uColor = require "cat-paw.core.utilities.uColor"

local shack = require "libs.shack"
local push = require "libs.push"

--============================ Constructor ==============================

---@class Game : AbstractGame
---@overload fun(title: string, targetWindowW: number, targetWindowH: number): self
local Game = middleclass("Game", AbstractGame)

function Game:initialize(...)
	AbstractGame.initialize(self, ...)
	math.randomseed(os.time())
	
	GAME = self

	self.eventSystem:attach(self, EventSystem.ATTACH_TO_ALL)
	
	local w = Game.WINDOW_TARGET_CONFIGS

	--Force fullscreen for mobile. See: https://github.com/Ulydev/push#mobile-support
	local osName = love.system.getOS()
	local fullscreen = w.FULLSCREEN
	if osName == 'iOS' or osName == 'Android' then fullscreen = true end

	push:setupScreen(w.GAME_W, w.GAME_H, w.INITIAL_W, w.INITIAL_H, {
			fullscreen = fullscreen, resizable = w.RESIZABLE,
			pixelperfect = w.PIXEL_PERFECT, stretched = w.STRETCHED,
			canvas = w.CANVAS, highdpi = w.HIGH_DPI
		})
	self.lastWindowW, self.lastWindowH = love.graphics.getDimensions()
	love.window.updateMode(nil, nil, {centered = true})    ---@diagnostic disable-line: param-type-mismatch

	self.backgroundColor = w.INITIAL_BACKGROUND_COLOR
	self:_loadAllAssets()

	self:add(Game.ESceneIds.LOGOS, LogosScene())
	self:add(Game.ESceneIds.IN_GAME, InGameScene())
	self:add(Game.ESceneIds.GAME_OVER, GameOverScene())
	
	if DEBUG and DEBUG.INITIAL_SCENE then
		self:goTo(DEBUG.INITIAL_SCENE)
	else
		self:goTo(self.ESceneIds.LOGOS)
	end
end

--============================ Constants ==============================

Game.WINDOW_TARGET_CONFIGS = {
	GAME_W = 160,
	GAME_H = 90,
	INITIAL_W = 640 * 2,
	INITIAL_H = 360 * 2,
	
	RESIZABLE = true,
	FULLSCREEN = false,
	
	CANVAS = false,
	HIGH_DPI = false,
	
	PIXEL_PERFECT = true,
	STRETCHED = false,

	--Putting this here because `push` breaks `love.graphics.setBackgroundColor()`.
	INITIAL_BACKGROUND_COLOR = {uColor.fromHex("#2e3bb7ff")},
}

Game.ESceneIds = {
	LOGOS = 1,
	IN_GAME = 2,
	GAME_OVER = 3,
}

--============================ Core APi ==============================

function Game:update(dt)
	AbstractGame.update(self, dt)
	shack:update(dt)
end

function Game:draw()
	local g2d = love.graphics
	g2d.push('all')
		g2d.setColor(self.backgroundColor)
		love.graphics.rectangle('fill', 0, 0, g2d.getDimensions())
	g2d.pop()

	push:start()
	shack:apply()

	if not DEBUG.DISABLE_SHADERS then
		error("Shader drawing NYI.")
	else
		--Draw without shaders.
		AbstractGame.draw(self)
	end

	push:finish()
end

--============================ Callbacks ==============================
Game[EvKeyPress] = function(self, e)
	if e.key == "s" then 
	--	DEBUG.DISABLE_SHADERS = not DEBUG.DISABLE_SHADERS 
	elseif e.key == 'f11' then
		push:switchFullscreen(self.lastWindowW, self.lastWindowH)
	elseif e.key == 'escape' then
		love.event.quit()
	end
end

Game[EvWindowResize] = function(self, e)
	self.lastWindowW, self.lastWindowH = e.w, e.h
	push:resize(e.w, e.h)
end

--============================ Internals ==============================

function Game:_loadAllAssets()
	local tAll, tData, tInv, tObj, tGui
	local time = love.timer.getTime
	
	tAll = time() 
	local DataRegistry = require "core.DataRegistry"
	print "------------------------------ Loading Data... ------------------------------"
		tData = time(); DataRegistry:loadData(); tData = time() - tData
	print "Done!\n"
		
	local AssetRegistry = require "core.AssetRegistry"
	print "------------------------------ Loading Sprites (inv)... ------------------------------"
	tInv = time(); AssetRegistry:loadSprInv(); tInv = time() - tInv
	
	print "------------------------------ Loading Sprites (obj)... ------------------------------"
	tObj = time(); AssetRegistry:loadSprObj(); tObj = time() - tObj
	
	print "------------------------------ Loading Sprites (gui)... ------------------------------"
		tGui = time(); AssetRegistry:loadSprGui(); tGui = time() - tGui
	print "Done!"
	tAll = time() - tAll
	
local str = string.format([[
------------------------------------------------------------
	Loading dat took: %.2fms
	Loading Inv took: %.2fms
	Loading Obj took: %.2fms
	Loading Gui took: %.2fms
	>Total load-time: %.4fs
------------------------------------------------------------
	]], tData*1e3, tInv*1e3, tObj*1e3, tGui*1e3, tAll)
	print(str)
end

--============================ Getters / Setters ==============================

function Game:getGameDimensions()
	return Game.WINDOW_TARGET_CONFIGS.GAME_W,
			Game.WINDOW_TARGET_CONFIGS.GAME_H
end

function Game:setBackgroundColor(color)
	self.backgroundColor = color
end

return Game
