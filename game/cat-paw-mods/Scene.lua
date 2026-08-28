local middleclass = require "libs.middleclass"
local State = require "cat-paw.core.patterns.state.State"
local utils = require "libs.utils"

local Event = require "cat-paw.core.patterns.event.Event"
local EvSceneObjectAdd = require "cat-paw-mods.events.EvSceneObjectAdd"
local EvSceneObjectRemove = require "cat-paw-mods.events.EvSceneObjectRemove"
local EventSystem = require "cat-paw.core.patterns.event.EventSystem"

------------------------------ Helpers ------------------------------

------------------------------ Constructor ------------------------------
---@class Scene : Middleclass
---@overload fun(): self
local Scene = middleclass("Scene", State)
function Scene:initialize()
	State.initialize(self)
	GAME:getEventSystem():attach(self, EventSystem.ATTACH_TO_ALL)
	self.objects = {}
end

------------------------------ Core API ------------------------------

function Scene:update(dt)
	State.update(self, dt)
	for obj, _ in pairs(self.objects) do
		obj:update(dt)
	end
end

function Scene:draw(g2d)
	State.draw(self, g2d)
--	local depthSorted = self.bumpWorld:getItems()
--	table.sort(depthSorted, function(a, b)
--		if not (a.depth and b.depth) then 
--			return true		--Doesn't really matter, they don't have depth values.
--		end
--		return a.depth < b.depth
--	end)
	for obj, _ in pairs(self.objects) do
		obj:draw(g2d)
	end
end

------------------------------ API ------------------------------
function Scene:enter(from, ...)
	State.enter(self, from, ...)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneEnter then obj:onSceneEnter(from, ...) end
	end
end

function Scene:leave(to)
	State.leave(self, to)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneLeave then obj:onSceneLeave(to) end
	end
end

function Scene:activate(fsm)
	State.activate(self, fsm)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneActivate then obj:onSceneActivate(fsm) end
	end
end

function Scene:destroy()
	State.destroy(self)
	for obj, _ in pairs(self.objects) do
		if obj.onSceneDestroy then obj:onSceneDestroy() end
	end
end

------------------------------ Object API ------------------------------
function Scene:addObject(obj)
	if not self.objects[obj] then
		self.objects[obj] = true
		GAME:getEventSystem():queue(EvSceneObjectAdd(self, obj))
		return true
	end
	return false
end

function Scene:removeObject(obj)
	if self.objects[obj] then 
		self.objects[obj] = nil
		GAME:getEventSystem():queue(EvSceneObjectRemove(self, obj))
		return true
	end
	return false
end

------------------------------ Internals ------------------------------

------------------------------ Getters / Setters ------------------------------
-- Returns a direct reference to its internal buffer. Changes will be reflected!
function Scene:getObjects() return self.objects end

function Scene:hasObject(obj) return self.objects[obj] end

-- `protection` Just in case someone confuses this with `removeObject`.
-- Note calling this will also invalidate any reference to the buffer previously
-- gotten through `getObjects()`
function Scene:clearObjects(protection)
	if protection then
		error("You seem to have passed something. Did you mean to call `Scene:removeObject(obj`)?"
				.. "\nCareful, this clears the entire object buffer!")
	end
	self.objects = {}
end

return Scene
