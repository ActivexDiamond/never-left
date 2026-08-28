local middleclass = require "libs.middleclass"

local Fsm = require "cat-paw.core.patterns.state.Fsm"
local ApiHooks = require "cat-paw.hooks.LoveHooks"

--local suit = require "libs.suit"
local Scheduler = require "cat-paw.core.timing.Scheduler"
local EventSystem = require "cat-paw.core.patterns.event.EventSystem"
local HotSwap; --Must be imported after ApiHooks is called.

local ParticleSystem = require "cat-paw.core.graphics.ParticleSystem"
--TEMP: Fetch this from a config or something.
local particle_data = require "particles.particle_data"

------------------------------ Constructor ------------------------------
---@class AbstractGame : Fsm
---@overload fun(title: string, targetWindowW: number, targetWindowH: number): self
local AbstractGame = middleclass("AbstractGame", Fsm)

---@param name string ("Untitled Game")
---@param targetWindowW number 
---@param targetWindowH number
function AbstractGame:initialize(name, targetWindowW, targetWindowH)
	Fsm.initialize(self)
	self.title = name or "Untitled Game" 		--FIXME: AbstractGame does not use the new CAT_PAW_CONFIG setup.
	love.window.setTitle(name)
	love.filesystem.setIdentity(name)
	if targetWindowW == -1 and targetWindowH == -1 then
		love.window.setFullscreen(true)
	elseif targetWindowW > 0 and targetWindowH > 0 then
		love.window.updateMode(targetWindowW, targetWindowH, nil)
	else
		error(string.format("Invalid window size. w/h must both be -1, for fullscreen,"
		.. "or positive. Current size: " .. targetWindowW .. ", " .. targetWindowH))
	end
	self.windowW, self.windowH = love.window.getMode()
				
	self.particleSystem = ParticleSystem(particle_data)
	self.scheduler = Scheduler()
	self.eventSystem = EventSystem()
	ApiHooks.hookHandler(self)
	HotSwap = require "cat-paw.core.dev.HotSwap"
end

------------------------------ Constants ------------------------------

------------------------------ Core API ------------------------------
function AbstractGame:load(args)
end

function AbstractGame:update(dt)
	HotSwap:update(dt)
	Fsm.update(self, dt)
	self.particleSystem:update(dt)
	self.scheduler:update(dt)
	self.eventSystem:poll()
end

function AbstractGame:draw()
	local g2d = love.graphics
	Fsm.draw(self, g2d)
	self.particleSystem:draw(g2d)
end


------------------------------ Other ------------------------------
--Wrapper so AbstractGame can be directly passed to ApiHooks. Shouldn't be used anywhere else.
--If you want to queue stuff, use game:getEventSystem():queue(event)
--TODO: Find a better way to make this class and ApiHooks work nicely.
function AbstractGame:queue(...)
	self.eventSystem:queue(...)
end

------------------------------ Internals ------------------------------

------------------------------ Getters / Setters ------------------------------
function AbstractGame:getWindowW() return self.windowW end
function AbstractGame:getWindowH() return self.windowH end
function AbstractGame:getWindowSize() return self.windowW, self.windowH end

function AbstractGame:setWindowSize(w, h) 
	self.windowW, self.windowH = w, h
	love.window.setMode(w, h)
end

--TODO: Service locator
function AbstractGame:getEventSystem()
	return self.eventSystem
end

function AbstractGame:getScheduler()
	return self.scheduler
end
function AbstractGame:getParticleSystem()
	return self.particleSystem
end
return AbstractGame

