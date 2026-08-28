local middleclass = require "cat-paw.core.patterns.oop.middleclass"

------------------------------ Helpers ------------------------------
--@return table 
local function deepCopyTable(t, dest)
	dest = dest or {}
	for k, v in pairs(t) do
		if type(v) == 'table' then 
			deepCopyTable(v, dest)
		else 
			dest[k] = v
		end
	end
	return dest 
end

--@return table 
local function copyTable(t, dest)
	dest = dest or {}
	for k, v in pairs(t) do
		dest[k] = v
	end
	return dest 
end

--FIXME: The capitalization (mainly, of constants/SCREAMING_CASE) of this module is all over the place!

---Returns a new table which is the combination of `a` and `b`. Does NOT modify `a` or `b`. If a key is in both, `b`s value takes priority.
local function immutableTableMerge(a, b)
	return copyTable(b, copyTable(a))
end

--- Use this instead of constantly creating new blank funcs. Much faster.
local function blankFunction() end


------------------------------ Constructor ------------------------------
---@class Logger: Middleclass
---@field debug fun(...: any): nil Log a DEBUG level message.
---@field info fun(...: any): nil Log a INFO level message.
---@field warn fun(...: any): nil Log a WARN level message.
---@field error fun(...: any): nil Log a ERROR level message.
---
---@field logPriorities {logName: integer} A table of valid `logName`s and their corresponding levels.
---@field logFunctions {logName: fun(str: string)} A table of valid `logName`s and their corresponding log functions.
---@field logColors {logName: string} A table of valid `logName`s and their corresponding colors, used for printing when ansiMode is active for that stream.
---@field E_COLOR_MODE EColorMode A field holding the singleton reference of the enum EColorMode, which is used to define which parts of the message are colored.
---@field E_ANSI_MODE EAnsiMode A field holding the singleton reference of the enum EAnsiMode, which is used to define which streams use ANSI codes.
---i.e. Whether to use ANSI codes in the console, log files, both or neither)
---@field E_ANSI_CODE EAnsiCode A field holding the singleton reference of the enum EAnsiCode, which is used to define which parts of the message are colored.
---
---@field exampleConfigs table UNDOCUMENTED
---@field private _DEFAULTS table UNDOCUMENTED
---@overload fun(opts: table): self
local Logger = middleclass("Logger")
function Logger:initialize(opts)
	opts = opts or Logger.exampleConfigs.BASIC
	local defaultedOpts = deepCopyTable(opts, copyTable(Logger._DEFAULTS))
	deepCopyTable(defaultedOpts, self)
	
	--Log functions.
	--Log Priorities
	--ANSI-stuff (colors, etc...)
	--Streams
	

end

---Do stuff.
---function Logger.debug() end

------------------------------ Config Templates  ------------------------------
local configs = {}
configs.BASIC = {
}

configs.OPTIMIZED = immutableTableMerge(configs.BASIC, {
})

configs.PERFORMANT = immutableTableMerge(configs.BASIC, {
})

--TODO: Better name.
Logger.static.exampleConfigs = configs

------------------------------ Constants ------------------------------
--For logName, will set to longest found logName.
--For time, will set based on format.
--For caller, will set to a `Logger.DEFAULT_CALLER_PAD_WIDTH`.
Logger.static.AUTO_PAD = -1 	
Logger.static.DEFAULT_CALLER_PAD_WIDTH = 20

---@enum EColorMode NOT PROPERLY ANNOTATED
Logger.static.ECOLOR_MODE = {
	LOG_NAME = 1,
	LOG_NAME_AND_MSG = 2,
	CALLER = 3,
	MSG = 4,
	FULL = 5,
}

---@enum EAnsiMode
Logger.static.ansiModes = {
	NEVER = false,
	ALWAYS = true,
	FUNCTIONS_ONLY = 1,
	FILES_ONLY = 2,
}

print(Logger.ansiModes.NEVER)

---@enum EAnsiCode NOT PROPERLY ANNOTATED
Logger.static.ansiCodes = {
	
}

------------------------------ Core API ------------------------------
function Logger:update(dt)
end

------------------------------ Log API ------------------------------
---Add add a new log level, optionally with a custom log function.
---@param logName string The name to be used for that level. Used for printing, logLevel functions, coloring, etc...
---@param f fun(self: Logger, ...: string)? A custom log function. If blank, will use the same one as the default levels.
function Logger:addLogFunction(logName, f)
	if self.logFunctions[logName] then return end
	self.logFunctions[logName] = f or function(self, ...) self:_log(logName, ...) end 				---@diagnostic disable-line: redefined-local
end

Logger:addLogFunction("he")

---@return boolean didRemove Whether it actually removed anything (aka if that logName existed or not).
function Logger:removeLogFunction(logName)
	local previous = self.logFunctions[logName]
	self.logFunctions[logName] = nil
	return previous ~= nil 				--nil check here is to make sure to return a boolean, not the log function itself.
end

------------------------------ Other ------------------------------
------------------------------ Internals - Defaults ------------------------------
Logger.static._DEFAULTS = {
	logFunctions = {
		debug = function(self, ...) self:_log("debug", ...) end,
		info = function(self, ...) self:_log("info", ...) end,
		warn = function(self, ...) self:_log("warn", ...) end,
		error = function(self, ...) self:_log("error", ...) end,
	},
	logPriorities = {
		debug = -1,
		info = 1,
		warn = 2,
		error = 3,
	},

	logColores = {
		debug = Logger.ansiCodes.GRAY_ITALIC,
		info = Logger.ansiCodes.WHITE,
		warn = Logger.ansiCodes.YELLOW,
		error = Logger.ansiCodes.RED,
	},

	streams = {
		{
			stream = io.write,
			style = {
				overallFormat = "[$logName] [$caller]: $message IN CONSOLE"
			},
		},
		"logs/",
	},
	
	maxFileSize = -1, 								--The max size a single log file can reach before splitting it[1].
	maxDirectorySize = 100*1024*1024, 				--The max size a log dir can reach before deleting old ones. In bytes[1].
	maxLogFiles = -1, 								--The max number of log files to keep. Number of files, NOT their size.
													--[1] Only checked after every message print. So may exceed this number, but usually not by a lot.
	---boolean|ansiMode
	ansiMode = Logger.ansiModes.FUNCTIONS_ONLY,

	style = {
		overallFormat = "[$time] [$logName] [$caller]: $message message",
		timeFormat = "yyyy-mm-dd hh:mm:ss",

		timePad = Logger.AUTO_PAD,
		logNamePad = Logger.AUTO_PAD, 					
		callerPad = Logger.AUTO_PAD,

		colorMode = Logger.ECOLOR_MODE.FULL,
		capitalizeLogName = true,
	},
}


------------------------------ Internals - Printing ------------------------------
function Logger:_log(logName, ...)
	local logColor = self.logColors[logName]
	local logFunc = self.logFunctions[logName]

	for _, stream in ipairs(self.streams) do

		self:_logToStream(logName, logColor, useAnsi, logStyles)
	end
end

function Logger:_logToStream(logName, logColor, useAnsi, logStyles)
	
end

------------------------------ Internals - State Management ------------------------------
function Logger:_updateLogFunctionPointers()
	for name, f in pairs(self.logFunctions) do
		self[name] = self.logPriorities >= self.logLevel and f or blankFunction
	end
end

function Logger:_updateLogStyle()
	error "WIP"
end

------------------------------ Getters / Setters ------------------------------
function Logger:setLogPriority(logName, priority)
	self.logPriorities[logName] = priority
	self:_updateLogFunctionPointers()
end

function Logger:setLogColor(logName, color)
	self.logColors[logName] = color
	self:_updateLogStyle()
end

function Logger:setLogLevel(level) self.logLevel = level end

function Logger:getLogPriority(logName) return self.logPriorities[logName] end
function Logger:getLogLevel() return self.logLevel end

return Logger
