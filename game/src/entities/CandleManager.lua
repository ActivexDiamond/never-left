local middleclass = require "libs.middleclass"
local Inventory = require "core.Inventory"

local DataRegistry = require "core.DataRegistry"
local AssetRegistry = require "core.AssetRegistry"

--============================ Helper Methods ==============================

--============================ Constructor ==============================

---@class CandleManager : Inventory
---@overload fun(scene: Scene, obj: TiledObject): self
local CandleManager = middleclass("CandleManager", Inventory)

function CandleManager:initialize(scene, obj)
	local sw, sh = GAME:getGameDimensions()
	Inventory.initialize(self, "candle_manager_inventory", self, sw / 2, sh / 2)

	self.x = self.x - self.background.w / 2
	self.y = self.y + self.background.h
	self:setPosition()
	self.drawBackground = true

	self.scene = scene
	self.tiledObject = obj

	self.shown = false

	self.candles = {}
	self.litCandles = {}

	for i = 1, 4 do
		local candle = {ID = "candle_" .. tostring(i), 
			w = 16, 
			h = 16
		}
		local litCandle = {ID = "candle_" .. tostring(i) .. "_lit",
			w = 8, 
			h = 8,
		}
		candle.sprite, candle.sx, candle.sy = AssetRegistry:getSprObj(candle)
		litCandle.sprite, litCandle.sx, litCandle.sy = AssetRegistry:getSprObj(litCandle)

		self.candles[i] = candle
		self.litCandles[i] = litCandle
		self.candleTracker = {false, false, false, false}

		self:addItem(candle)
	end
end

--============================ Core API ==============================

function CandleManager:update(dt)
	if self.shown then
		Inventory.update(self, dt)
	end
end

function CandleManager:draw(g2d)
	if self.shown then
		Inventory.draw(self, g2d)
	end
end

--============================ API ==============================

--============================ Internals ==============================

function CandleManager:_attemptCombine()
	if TMP.mouseItem.ID == "matches" then
		PLAY_SOUND(AUDIO.SFX.match_use)
		local i = TMP.highlightedSlot.index
		print(i)
		self.candleTracker[i] = not self.candleTracker[i]
		if self.candleTracker[i] then
			TMP.highlightedSlot.item = self.litCandles[i]
		else
			TMP.highlightedSlot.item = self.candles[i]
		end
		return
	end

	GAME:getCurrentState().player:_showItemMenu({
		dialogue = "> I can't use this here..."
	}, true)
end

function CandleManager:_checkSolution()
	--Only run the check if all slots are full.
	local itemCount = 0
	for k, v in ipairs(self.slots) do 
		if v.item then itemCount = itemCount + 1 end
	end
	if not DEBUG.DEV_MODE and itemCount < #self.slots then return false end

	if DEBUG.DEV_MODE or (self.slots[1].item.ID == "candle_1_lit" and
			self.slots[2].item.ID == "candle_2_lit" and
			self.slots[3].item.ID == "candle_3" and
			self.slots[4].item.ID == "candle_4_lit") then
		
		PLAY_SOUND(AUDIO.SFX.wood_break, 4)


		GAME:getCurrentState().player:_showItemMenu({
			dialogue = "> I think I just heard a door breaking...",
		})
		GAME:getCurrentState().map.objs.doors.basement.opened = true

		self.scene.player.inv:removeItemById("matches")
		self.scene.map.bumpWorld:remove(self.tiledObject)
		self.scene:removeObject(self)
		return true
	end
end


--============================ Getters / Setters ==============================

function CandleManager:isShown() return self.shown end

function CandleManager:toggleShown()
	self.shown = not self.shown
	if not self.shown then
		self:_checkSolution()
	end
end

return CandleManager
