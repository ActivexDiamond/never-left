local middleclass = require "libs.middleclass"
local push = require "libs.push"

local EvFileChange = require "cat-paw.core.patterns.event.dev.EvFileChange"
local EvKeyPress = require "cat-paw.core.patterns.event.keyboard.EvKeyPress"
local WorldObject = require "core.WorldObject"
local AssetRegistry = require "core.AssetRegistry"
local DataRegistry = require "core.DataRegistry"
local uMath = require "cat-paw.core.utilities.uMath"

local Inventory = require "core.Inventory"

local shack = require "libs.shack"

local brinevector = require "libs.brinevector"

--============================ Shaders ==============================

local LIGHT_SHADER = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a < 0.0001)
      discard;
    return texturecolor;
}
]])

local CROP_SHADER = love.graphics.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a > 0.6)
    	texturecolor.a = 0.6;
    return texturecolor;
}
]])

--============================ Constructor ==============================

---@class Player : WorldObject
---@field SPEED number
---@field DIALOGUE_FADE_DURATION number
---@field lightRadius number
---@field lightFps number
---@overload fun(scene: Scene, x: number, y: number): self
local Player = middleclass("Player", WorldObject)
	
function Player:initialize(scene, x, y)
	WorldObject.initialize(self, "player", scene, x, y)	
	self.light = WorldObject("player_light", scene, x, y)
	self.interactSparkle = WorldObject("player_sparkle", scene, x, y)

	self.interactBox = WorldObject("player_interact_box", scene, x, y)
	self.scene.map.bumpWorld:add(self.interactBox, self.interactBox:getBoundingBox())

	self.inv = Inventory("player_inventory", self, 'top_right')

	self.itemMenu = {
		visible = false, 
		progress = 0,
		maxProgress = self.DIALOGUE_FADE_DURATION,
	}

	self.dialogueBoxSprite = love.graphics.newImage("assets/spr/obj/dialogue_box.png")

	GAME:getScheduler():callEvery(1 / self.lightFps, function(dt, per, self)
		self.light:_nextFrame()
	end, {self})
	self:_setupLightVars()
	self._lightMaskWrapper = function()
		return self:_drawLightSprite(love.graphics)
	end
	self:setSpriteOffset(WorldObject.SPRITE_CENTER)
	self.scene.map.bumpWorld:add(self, self:getBoundingBox())

	self.rotation = - math.pi / 2
	self.scratchRotationVector = brinevector(0, 0)
	self.walkStepCooldown = 0

	self._collisionFilterWrapper = function(item, other) 
		return self:_collisionFilter(item, other)
	end
end

--============================ Core API ==============================

function Player:update(dt)
	WorldObject.update(self, dt)
	self.vel.x, self.vel.y = 0, 0
	local isDown = love.keyboard.isDown
	---move
	local dirX, dirY = 0, 0
	if isDown('w') then dirY = dirY - 1 end
	if isDown('s') then dirY = dirY + 1 end
	if isDown('a') then dirX = dirX - 1 end
	if isDown('d') then dirX = dirX + 1 end
	if not self.frozen and (dirX ~= 0 or dirY ~= 0) then
		self.vel.x = dirX
		self.vel.y = dirY
		if DEBUG.DEV_MODE then
			self.vel.length = self.SPEED * 3 * dt
		else
			self.vel.length = self.SPEED * dt
		end 
		
		local targetX = self.pos.x + self.vel.x
		local targetY = self.pos.y + self.vel.y
		local newX, newY, cols = self.scene.map.bumpWorld:move(self, targetX, targetY, self._collisionFilterWrapper)
		self.pos.x = newX
		self:_playerCollisionHandler(cols)
		self.pos.y = newY

		self.scratchRotationVector.x = dirX
		self.scratchRotationVector.y = dirY
		self:setRotation(self.scratchRotationVector.angle + math.pi/2)

		--HASAN: I think this plays way too often.
		self.walkStepCooldown = self.walkStepCooldown - dt
		if self.walkStepCooldown <= 0 then
			PLAY_SOUND(AUDIO.SFX.walkingg, 0.15, 20, 1)
			self.walkStepCooldown = 0.35
		end
	else
		self.walkStepCooldown = 0
	end
	
	self.light.pos.x = self.pos.x - self.light.w / 2.2
	self.light.pos.y = self.pos.y - self.light.h / 2.2

	self.light:update(dt) 

	local targetX = self.pos.x - 3.5
	local targetY = self.pos.y - 3.5
	local newX, newY, cols = self.scene.map.bumpWorld:move(self.interactBox, targetX, targetY, self._collisionFilterWrapper)
	self.nearbyInteractable = nil
	self:_interactBoxCollisionHandler(cols)

	self.interactBox.pos.x = newX
	self.interactBox.pos.y = newY
	self.interactBox:update(dt)

	self.inv:update(dt)
	
	local m = self.itemMenu
	local rate = m.quick and 3 or 1
	if DEBUG.DEV_MODE then rate = 8 end
	m.progress = m.progress + dt * rate

	if m.progress > m.maxProgress then
		m.progress = m.maxProgress
	end
end

function Player:earlyDraw(g2d)
	--push:setupCanvas("stencil_canvas")
--	g2d.rectangle('fill', self:getBoundingBox())
	g2d.setShader(LIGHT_SHADER)
	g2d.stencil(self._lightMaskWrapper, 'replace', 1)
	g2d.setShader()
	g2d.setStencilTest('equal', 1)
end

function Player:draw(g2d)
	g2d.setColor(0, 1, 0, 0.7)
	if DEBUG.DRAW_INTERACT_BOX then
		g2d.rectangle('fill', self.interactBox:getBoundingBox())
	end

	local b = 0
	g2d.setColor(b, b, b, 0.5)
	g2d.rectangle('fill', self.pos.x - 500, self.pos.y - 500, 1000, 1000)

--	g2d.setColor(1, 1, 1, 0.3)
--	self:_drawLightSprite(g2d)

	g2d.setColor(1, 1, 1, 1)
	WorldObject.draw(self, g2d)
	
	g2d.setColor(1, 1, 1, 0.3)
	self:_drawLightSprite(g2d)

	if self.nearbyInteractable then
		local x = self.nearbyInteractable.centerX - 1
		local y = self.nearbyInteractable.centerY - 1
		self.interactSparkle:setPosition(x, y)
		g2d.setColor(1, 1, 1, 0.7)
		self.interactSparkle:draw(g2d)
	end

	self.inv:draw(g2d)

	local m = self.itemMenu
	if m.visible then	
		local pro = m.progress / m.maxProgress
		g2d.push('all')
			g2d.setStencilTest()
			g2d.translate(-self.scene.cameraX, -self.scene.cameraY)
			g2d.setColor(0, 0, 0, 0.6)
			g2d.rectangle('fill', 0, 0, GAME:getGameDimensions())
			g2d.setColor(1, 1, 1, pro)
			local sw, sh = GAME:getGameDimensions()
			if m.sprite then
				local iw, ih = m.sprite:getDimensions()
				local x = (sw - 36) / 2
				local y = ((sh - 36) / 2) - 23
				local sx = 1
				local sy = 1
				g2d.draw(m.sprite, x, y, nil, 36 / iw, 36 / ih)
			end
				local dw, dh = self.dialogueBoxSprite:getDimensions()
				local x = (sw - dw) / 2
				local y = sh - dh
				g2d.setColor(1, 1, 1, 1)
				local finalY = uMath.map(pro, 0, 1, sh, y)
				g2d.draw(self.dialogueBoxSprite, x, finalY) 
				g2d.printf(m.dialogue, x + 7, finalY + 2, dw - 11)
		g2d.pop()
	end
end


--============================ Callbacks ==============================

Player[EvKeyPress] = function(self, e)
	if e.key == 'e' then self:_onInteractInput() 
	elseif e.key == 'm' then
		DEBUG.MUTE_AUDIO = not DEBUG.MUTE_AUDIO
		love.audio.setVolume(DEBUG.MUTE_AUDIO and 0 or 1)
	end
end

Player[EvFileChange] = function(self, e)
	self:_setupLightVars()
end

function Player:_onInteractInput()
	if self.itemMenu.visible then
		if self.itemMenu.progress == self.itemMenu.maxProgress or DEBUG.DEV_MODE then
			self:_hideItemMenu()
		end
		return
	end

	if not self.nearbyInteractable then return end

	local obj = self.nearbyInteractable
	print("Interacting with: ", obj.ID)

	if obj.layer == "puzzles" then
		if obj.ID == "symbol_sorter_bookshelf" then
			--FIXME: The physics stuff should keep track of classes. Which may be TiledObjects or children of them,
			--    Or something similar. Not whatever this is.
			self.frozen = not self.scene.bookshelf:isShown()
			self.scene.bookshelf:toggleShown()
	elseif obj.ID == "candle_desk" then
			--FIXME: The physics stuff should keep track of classes. Which may be TiledObjects or children of them,
			--    Or something similar. Not whatever this is.
			self.frozen = not self.scene.candleManager:isShown()
			self.scene.candleManager:toggleShown()
		end
	elseif obj.layer == "doors" then
		--HASAN: Change the the volume and pitch to whatever sounds good.
		PLAY_SOUND(AUDIO.SFX.opendoor, 1, 8)
		self:_showItemMenu(obj)
		if obj.ID == 'outside' then
			self.scene.map.objs.doors.initial.opened = true
		end
	elseif obj.layer == "pickables" then
		self:_showItemMenu(obj)
		--HASAN: Change the the volume and pitch to whatever sounds good.
		PLAY_SOUND(AUDIO.SFX.pickup, 1, 8)
		print("Picked up", obj)
		self.inv:addItem(obj)

		self.scene.map.bumpWorld:remove(obj)
		self.scene.map.objs.pickables[obj.ID] = nil	
	elseif obj.layer == 'dialogues' then
		self:_showItemMenu(obj)
	elseif obj.layer == 'searchables' then
		--Show in all cases, as it handles searched containers and empty ones.
		self:_showItemMenu(obj)
		local sound = obj.typ and AUDIO.SEARCH_SOUNDS[obj.typ]
		if sound then
			--HASAN: Change the the volume and pitch to whatever sounds good.
			PLAY_SOUND(sound, 1)
		end
		if not obj.collected and obj.ID:sub(1, 8) ~= "empty_co" then
			print("Picked up", obj)
			self.inv:addItem(obj)
			obj.collected = true
		end
	end
end

--============================ API ==============================

--============================ Internals ==============================

function Player:_hideItemMenu()
	local m = self.itemMenu
	m.visible = false
	m.sprite = nil
	m.dialogue = ""
	m.quick = false
	self.frozen = false
end


function Player:_showItemMenu(item, quick)
	local m = self.itemMenu
	m.visible = true
	m.dialogue = ""
	m.sprite = nil
	m.progress = 0
	m.quick = quick
	self.frozen = true

	--Searched & collected container    -    SHORT CIRCUIT
	if item.layer == 'searchables' and item.collected then
--		m.dialogue = "> I picked up everything useful here."
		m.dialogue = "> I've already taken all that's useful from here."
		m.sprite = nil
		return
	end
	
	--Empty container    -    SHORT CIRCUIT
	if item.layer == 'searchables' and item.ID:sub(1, 8) == "empty_co" then
		local data = {ID = item.typ}
		DataRegistry:applyStats(data)
		m.dialogue = data.dialogue or "Lorem ipsum."
		return
	end

	m.dialogue = item.dialogue or "Lorem ipsum."
	
	--Sprite
	if item.pickUpItem then
		local data = {ID = item.pickUpItem}
		DataRegistry:applyStats(data)
		m.sprite = AssetRegistry:getSprObj(data)
	elseif item.sprite then
		m.sprite = item.sprite
	end
end


function Player:_interactBoxCollisionHandler(cols)
	for k, v in ipairs(cols or {}) do
		local other = v.other
		self.nearbyInteractable = other
	end
end

function Player:_playerCollisionHandler(cols)
	for k, v in ipairs(cols or {}) do
		local other = v.other	
		if other.layer == "walls" then
		elseif other.layer == "doors" and not other.opened then
		elseif other.layer == "pickables" then
		end
		if other.layer ~= "walls" then
		end
	end
end


function Player:_collisionFilter(item, other)
	if item.ID == "player_interact_box" then
		return (other.layer ~= "walls" and other.ID ~= "player")
				and 'cross' or false
	end

	if other.layer == "walls" then
		return 'slide'
	elseif other.layer == "doors" and not other.opened and not DEBUG.NOCLIP_DOORS then
		return 'slide'
	elseif other.layer == "pickables" then
		return 'cross'
	else
		return false
	end
end


function Player:_setupLightVars()
	self.INITIAL_LIGHT_SIZE = self.light.w
	self.MAX_LIGHT_SIZE = self.light.w * 0.011
	self.lightGrowDir = 1
	self.lightGrowAmount = self.MAX_LIGHT_SIZE / 11

	GAME:getScheduler():cancel(self.flicker)

	self.flicker = GAME:getScheduler():callEvery(0.05, function(dt, per, self)
		self.light.w = self.light.w + self.lightGrowAmount * self.lightGrowDir
		self.light.h = self.light.h + self.lightGrowAmount * self.lightGrowDir
		local diff = math.abs(self.INITIAL_LIGHT_SIZE - self.light.w)
		if diff > self.MAX_LIGHT_SIZE then
			self.lightGrowDir = self.lightGrowDir * -1
		end
	end, {self})
end

function Player:_drawLightSprite(g2d)
	self.light:draw(g2d)
	--[[
	local sw, sh = GAME:getGameDimensions()
	local iw, ih = self.lightSprite:getDimensions()
	local sz = self.lightSpriteSx * iw
	local x = self.pos.x - sz / 3
	local y = self.pos.y - sz / 3
--	print(sw, sh, sz, (sw - sz) / 2, x, y)

	print('light', self.pos.x, x)
	g2d.draw(self.lightSprite, x, y, nil, self.lightSpriteSx, self.lightSpriteSy)
	--]]
end


--============================ Getters / Setters ==============================

return Player
