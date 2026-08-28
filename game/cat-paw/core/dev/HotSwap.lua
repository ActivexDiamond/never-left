local middleclass = require "libs.middleclass"

local succ, EvFileChange = pcall(require, "cat-paw.core.patterns.event.dev.EvFileChange")
EvFileChange = succ and EvFileChange or nil

--TODO: Remove dependency on lurker and lume.
local lurker = require "cat-paw.core.dev.lurker"

--============================ Constructor ==============================

---@class HotSwap : Middleclass
---@field EErrorModes EErrorModes_class Used for the `protect` and `pauseExecution` configs.
---@field enabled EErrorModes (false) Config. Whether HotSwapping is enabled at all. This disables everything (auto-scanning, pcall wrapping, etc...).
---@field scanInterval number (0.5) Config. How often to check for changed files. Lower numbers decrease latency but decrease performance.
---@field protect EErrorModes (EErrorModes.ALL) Config. What kinds of potential errors to catch. What happens when an error is caught is defined by `pauseExecution`. If an error is not caught, you simply crash as normal.
---@field pauseExecution EErrorModes (EErrorModes.ALL) Config. What kinds of errors to pause and show `errorScreen` for. Even if disabled, you will still get a message logged to the console and `HotSwap` will continue to watch for file updates. The last valid version of the file is used until a swap fixes the error.
---@field emitChangeEvents boolean (true) Config. Whether to emit EvFileChange events, only relevant if used with the `engine` layer, or if a custom EventSystem has been set.
---@field errorScreen fun() (HotSwap._defaultErrorScreen) Can be used to customize the screen shown when an error is caught and paused for.
---@field update fun(self: HotSwap, dt: number) Required for auto-scanning.
---@field protected _setupConfig fun() Internal.
---@field protected preSwapListeners table Since pre-swap offers a chance to cancel, we cannot rely on EventSystem and hence need this.
---@overload fun(): self
local HotSwap = middleclass("HotSwap")

function HotSwap:initialize()
	error("Attempting to initialize static class!" .. HotSwap)
end

--============================ Constants ==============================

---How HotSwap should handle thrown errors. These enum is used to set values for  `protect` and `pauseExecution`.
---@class EErrorModes_class
HotSwap.static.EErrorModes = { ---@enum EErrorModes
	---Nothing is wrapped behind `pcalls` or paused for, so even a 
	---    syntax error in a changed file will crash you.
	NONE = -1,

	---Errors thrown by swapped files on parsing (syntax error) or initial 
	---    execution (errors that are thrown directly from the body of the swapped file.) 
	---    are wrapped in `pcalls` or paused for.
	---Errors thrown by the new code in that file "later" on (almost always traced back 
	---    to a later call of a callback such as `update` or `onKeyPress` or similar) are 
	---    NOT caught or paused for.
	---(Note: Callbacks registered to `EventSystem`s actually face a level of indirection, 
	---    so their calltrace actually traces back to `update`, not the given event. If
	---    you're using the `engine` layer or above, you're never directly responding 
	---    to callbacks)
	FILES = 1,

	---Errors originating from callbacks (any callbacks called after HotSwap is done
	---    setting up, whether from a changed file or not) will be caught or paused for.
	CALLBACKS = 2,

	---Includes errors listed under `FILES` and `CALLBACKS`.
	ALL = 3,
}

--============================ Defaults ==============================
--TODO: Properly implement all of these once I switch out Lurker for my own code.

--Those defaults are only used if you take this standalone, leaving the entry-points
--    of the `core` layer (`main_template.lua` and `default_cat_paw_config.lua`).
--Otherwise; defaults will be taken from `default_cat_paw_config.lua` and 
--    user-configs from your `cat_paw_config.lua` with this table being fully ignored.
--Lowercase constants because they need to match the user-config ones, for quick copying.
local DEFAULT_CONFIG = {
	enabled = false,
	scanInterval = 0.5,
	protect = HotSwap.EErrorModes.ALL,
	pauseExecution= HotSwap.EErrorModes.ALL,
	emitChangeEvents = true,
}

--============================ Core API ==============================

function HotSwap.static:update(dt)
	if HotSwap.enabled and HotSwap.scanInterval ~= -1 then
		lurker:update()
	end
end

--============================ API ==============================
function HotSwap.static:attachPreSwapListener(obj)
	table.insert(HotSwap.preSwapListeners, obj)
end

function HotSwap.static:removePreSwapListener(obj)
	for k, v in pairs(HotSwap.preSwapListeners) do
		if v == obj then
			table.remove(HotSwap.preSwapListeners, k)
			return true
		end
	end
	return false
end

--============================ Internals ==============================

function HotSwap.static:_defaultErrorScreen()
end


---@param filename string
function HotSwap.static:_onPreSwap(filename)
	--FIXME: Hacky
	if filename:match("datapack") then 
		GAME:getEventSystem():queue(EvFileChange(filename))
		return true 
	end
	local shouldCancel = false
	for _, v in pairs(HotSwap.preSwapListeners) do
		if v.onPreSwap then 
			shouldCancel = v:onPreSwap(filename) 
		end
	end
	return shouldCancel
end

function HotSwap.static:_onPostSwap(filename)
	local es = HotSwap.eventSystem or (type(GAME) == 'table' and GAME:getEventSystem())
	if not es then return end
	if not EvFileChange then
		print("[WARNING] HotSwap is configured to emit `EvFileChange`, but cannot locate the `EvFileChange` class.")
		return
	end
	print("FIRE")

	es:queue(EvFileChange(filename))
end


function HotSwap.static:_setupConfig()
	local opt = type(CAT_PAW_CONFIG) == 'table' and
			CAT_PAW_CONFIG.core.hotSwap or DEFAULT_CONFIG
 	HotSwap.enabled = opt.enabled
 	HotSwap.scanInterval = opt.scanInterval
 	HotSwap.protect = opt.protect
 	HotSwap.pauseExecution = opt.pauseExecution
 	HotSwap.emitChangeEvents = opt.emitChangeEvents
	HotSwap.errorScreen = HotSwap._defaultErrorScreen

	lurker.preswap = function(f) return HotSwap:_onPreSwap(f) end
	lurker.postswap = function(f) HotSwap:_onPostSwap(f) end

 	if HotSwap.enabled and HotSwap.protect ~= HotSwap.EErrorModes.NONE then
 		--Wrap callbacks and what not.
 	end
end

--============================ Getters / Setters ==============================
function HotSwap.static:isEnabled() return HotSwap.enabled end
function HotSwap.static:doesEmitChangeEvents() return HotSwap.emitChangeEvents end
function HotSwap.static:getScanInterval() return HotSwap.scanInterval end
function HotSwap.static:getProtectMode() return HotSwap.protect end
function HotSwap.static:getPauseExecutionMode() return HotSwap.pauseExecution end

function HotSwap.static:setEnabled(state)
	HotSwap.enabled = state
 	if HotSwap.enabled and HotSwap.protect ~= HotSwap.EErrorModes.NONE then
 		--Wrap callbacks and what not.
 	end
end

function HotSwap.static:setEventSystem(es)
	HotSwap.eventSystem = es
end

HotSwap.static.preSwapListeners = {}
HotSwap:_setupConfig()
return HotSwap
