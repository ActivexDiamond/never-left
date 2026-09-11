local middleclass = require "libs.middleclass"
local ItemManager = require "core.ItemManager"

local Scene = require "cat-paw-mods.Scene"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"
local EvMousePresss = require "cat-paw.core.patterns.event.mouse.EvMousePress"

local Map = require "core.Map"
local Player = require "core.Player"

local push = require "libs.push"
local shack = require "libs.shack"

--============================ Helper Methods ==============================

--============================ Constructor ==============================
---@class InGameScene : Scene
---@overload fun(): self
local InGameScene = middleclass("InGameScene", Scene)
	
function InGameScene:initialize()

	Scene.initialize(self)
	self.map = Map(self)
	self:addObject(self.map)

	self.player = Player(self, self.map:getSpawnPoint())
	self:addObject(self.player)
--	self:addObject(ItemManager(self))

	self.font = love.graphics.newFont("assets/fonts/smallest_pixel-7.ttf")
	self.horrorCooldown = 0
	self.horrorTracks = {
		"basmentsound",
		"basmentsound2",
		"callinghorror",
		"horro2",
		"horror1",
		"horror3",
		"knocking",
		"thunder",
	}
end

--============================ Constants ==============================

--============================ Core API ==============================

function InGameScene:update(dt)
	Scene.update(self, dt)

	if self.horrorCooldown > 0 then
		self.horrorCooldown = self.horrorCooldown - dt
		if self.horrorCooldown <= 0 then
			self:_playRandomHorrorCue()
			shack:setShake(10)
			self.horrorCooldown = love.math.random(8, 18)
		end
	end
end

function InGameScene:draw(g2d)
	--FULLY OVERRIDES Scene.draw
	g2d.push('all')
		self.font = love.graphics.newFont("assets/fonts/smallest_pixel-7.ttf", 10)
		self.font:setFilter('nearest', 'nearest', 0)
		g2d.setFont(self.font)
		local px, py, pw, ph = self.player:getBoundingBox()
		local sw, sh = GAME:getGameDimensions()
		self.cameraX = -px +((sw - pw) / 2)
		self.cameraY = -py +((sh - ph) / 2)

		g2d.translate(self.cameraX, self.cameraY)

	--	Scene.draw(self, g2d)
		self.player:earlyDraw(g2d)
		self.map:draw(g2d)
		self.player:draw(g2d)
		self.bookshelf:draw(g2d)
		self.candleManager:draw(g2d)
	g2d.pop()
		g2d.setColor(1,0,0)
		g2d.setPointSize(8)
--		g2d.points(sw/2, sh/2)	
end

--============================ API ==============================

--============================ Callbacks ==============================

InGameScene[EvMousePresss] = function(self, e)
	local mx, my = push:toGame(e.x ,e.y)

	--FIXME: Manual overrides for `candle_desk`.
	if TMP.highlightedSlot and TMP.highlightedSlot.inventory.ID == "candle_manager_inventory" then
	--Holding an item and clicked on a slot with an item.
	if TMP.mouseItem and TMP.highlightedSlot and TMP.highlightedSlot.item then
		TMP.highlightedSlot.inventory:_attemptCombine()
		TMP.mouseSlot.selected = false
		TMP.mouseSlot.color = TMP.mouseSlot.colors.DEFAULT
		TMP.mouseItem = nil
		TMP.mouseSlot = nil
		return
	end
		return
	end

	--Not holding item and clicked on a slot.
	if not TMP.mouseItem and TMP.highlightedSlot then
		--Only select it and pick up, if it is non-empty.
		if TMP.highlightedSlot.item then
			TMP.highlightedSlot.selected = true
			TMP.mouseItem = TMP.highlightedSlot.item
			TMP.mouseSlot = TMP.highlightedSlot
			TMP.highlightedSlot.color = TMP.highlightedSlot.colors.SELECTED
		end
		return
	end					

	--Holding an item, and clicked on an empty slot.
	if TMP.mouseItem and TMP.highlightedSlot and not TMP.highlightedSlot.item then
		TMP.highlightedSlot.item = TMP.mouseItem
		TMP.mouseSlot.item = nil

		TMP.mouseSlot.selected = false
		TMP.mouseSlot.color = TMP.mouseSlot.colors.DEFAULT
		TMP.mouseItem = nil
		TMP.mouseSlot = nil
		return
	end
	
	--Holding an item and clicked on a slot with an item.
	if TMP.mouseItem and TMP.highlightedSlot and TMP.highlightedSlot.item then
		TMP.highlightedSlot.inventory:_attemptCombine()
		TMP.mouseSlot.selected = false
		TMP.mouseSlot.color = TMP.mouseSlot.colors.DEFAULT
		TMP.mouseItem = nil
		TMP.mouseSlot = nil
		return
	end
	
	--Holding an item, and click in-world.
	--TODO: RANGE CHECK
	if TMP.mouseItem then
		local worldX = mx - self.cameraX
		local worldY = my - self.cameraY
		local filter = TMP.mouseSlot.inventory.mouseInteractFilter
		local obj = self.map.bumpWorld:queryPoint(worldX, worldY, filter)[1]
		if obj then
			self.player.inv:_attemptUse(obj)
		end
		return
	end
end

InGameScene[EvKeyPress] = function(self, e)
	if e.key == 'space' then
	end
end

function InGameScene:enter()
	Scene.enter(self)
	GAME:setBackgroundColor({0, 0, 0})

	local rain = AUDIO and AUDIO.SFX and AUDIO.SFX.raining
	if rain then
		rain:setLooping(true)
		rain:setVolume(0.35)
		rain:stop()
		rain:play()
	end

	self.horrorCooldown = love.math.random(4, 16)
end

function InGameScene:_playRandomHorrorCue()
	if not AUDIO or not AUDIO.SFX then return end

	local index = love.math.random(1, #self.horrorTracks)
	local key = self.horrorTracks[index]
	local source = AUDIO.SFX[key]
	if source then
		source:setVolume(0.45)
		source:setPitch(1)
		PLAY_SOUND(source, 0.45, 10, 1)
	end
end

--============================ Internals ==============================

--============================ Getters / Setters ==============================

return InGameScene
