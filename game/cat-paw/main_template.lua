--============================ USAGE ==============================
--If you wish to use only the  `core` layer, you may optionally use this as your entry point for
--    some extra niceties.
--You may also ignore this file entirely.

--If you wish to use the `engine` layer, or above, then you must use this file.

--See the docs for more details.

--============================ Config Loading - LoveJS Fixes ==============================

--============================ Config Loading - User Config ==============================
local succ, user_config = pcall(require, "cat_paw_config")

local defaultCatPawConfigFilename = "default_cat_paw_config"
local defaultCatPawConfigPaths = {
	"cat-paw/?.lua",
	"?.lua",
	"src/?.lua",
	"src/cat-paw/?.lua",

	--Must be the last entry! Otherwise, won't upack correctly.
	unpack(type(user_config) == 'table' and 
			type(user_config.core) == 'table' and 
			type(user_config.core.env) == 'table' and 
			type(user_config.core.env.extraPaths) == 'table' and
			user_config.core.env.extraPaths or {}
	) 
}
	
--============================ Config Loading - Default Config ==============================
succ = false
local default_config;
for _, pathSearcher in ipairs(defaultCatPawConfigPaths) do
	--Manual conversion of path.
	--Since the searchers are intended for `package.path`, we have to manually "undo" the
	--    directory seperators (back to dots) and remove the ".lua" extension.
	local path = pathSearcher:gsub("?", defaultCatPawConfigFilename):gsub("/", "."):sub(1, -5)
	succ, default_config = pcall(require, path)

	print(succ, pathSearcher, "\t", path)
	if succ then break end	
end

--============================ Config Loading - Prints ==============================
if type(user_config) == 'table' then print("Loaded user supplied CatPaw configs!")
else print("No user supplied CatPaw config found. Using all defaults.") end

if type(default_config) ~= 'table' then
	error("Failed to find default CatPaw configs. Many things will be broken!")
end

user_config = type(user_config) == 'table' and user_config or {}

--============================ Config Loading - Validation Helpers ==============================
local function concatTargetName(a, b, c, d, e, f)
	local str = a
	if b then str = str .. "." .. b end
	if c then str = str .. "." .. c end
	if d then str = str .. "." .. d end
	if e then str = str .. "." .. e end
	if f then str = str .. "." .. f end
	return str
end

---Checks one or more levels of nested keys to look up inside of `user_config`.
---The final result of user_config[a][b?][c?][d?][e?][f?] is will be referred to here as `target`.
---Important: Fails silently if the one of the given keys, except the last, returns a non-table value.
---    i.e. Make sure to call it to check that each step in a path is correct, so that the user is informed of all mistakes.
---@param expected string|table If string; will be compared to the value of `type(target`).
---        If table; should be an array of valid values. Equality comparision will be used.
---@param a string|number A key-index to use  for `user_config[a]`.
---@param b string|number? A key-index to use for `user_config[a][b]`.
---@param c string|number? A key-index to use for `user_config[a][b][c]`.
---@param d string|number? A key-index to use for `user_config[a][b][c][d]`.
---@param e string|number? A key-index to use for `user_config[a][b][c][d][e]`.
---@param f string|number? A key-index to use for `user_config[a][b][c][d][e][f]`.
local function validateConfig(expected, a, b, c, d, e, f)
	--Setup full target nested keys..
	local target = user_config[a]

	if b and type(target) ~= 'table' then return
	elseif b                         then target = target[b] end

	if c and type(target) ~= 'table' then return
	elseif c                         then target = target[c] end

	if d and type(target) ~= 'table' then return
	elseif d                         then target = target[d] end

	if e and type(target) ~= 'table' then return
	elseif e                         then target = target[e] end
	
	if f and type(target) ~= 'table' then return
	elseif f                         then target = target[f] end

	--All configs are optional. Anything not passed in by the user, is fine.
	--Explicit `nil` check, because `false` is a valid value.
	if target == nil then return true end

	--For multi-value configs.
	if type(expected) == 'table' then
		local valid = false
		for k, v in ipairs(expected) do
			if target == v then
				valid = true
				break
			end
		end
		--All good, done!
		if valid then return true end

		--Otherwise, prepare warning string.
		local str = "[WARNING] Invalid config for `cat_paw_config.%s`. Expected one of {%s} but instead got `%s`. Will ignore the user-supplied value for it."
		local targetName = concatTargetName(a, b, c, d, e, f)
		
		local validValues = ""
		for k, v in ipairs(expected) do
			validValues = tostring(v) .. ", "
		end
		validValues = validValues:sub(1, -3)
		print(str:format(targetName, validValues, target))
	else
		--For type-sensitive configs.
		--All good, done.
		if type(target) == expected then return true end
	
		--Otherwise, prepare warning string.
		local str = "[WARNING] Invalid config for `cat_paw_config.%s`. Expected a `%s` but instead got a `%s`. Will ignore the user-supplied value for it."
		local targetName = concatTargetName(a, b, c, d, e, f)
		print(str:format(targetName, expected, type(target)))
	end
	--Execution only gets here if the provided config field is invalid.
	--Get the last entry of the path, index into it and set the value to nil.
	if f     then user_config[a][b][c][d][e][f] = nil
	elseif e then user_config[a][b][c][d][e] = nil
	elseif d then user_config[a][b][c][d] = nil
	elseif c then user_config[a][b][c] = nil
	elseif b then user_config[a][b] = nil
	else          user_config[a] = nil
	end
	return false
end

--============================ Config Loading - Validation ==============================
local vc = validateConfig
vc('table',   'core')
vc('table',   'core', 'versionPrinters')
vc('boolean', 'core', 'versionPrinters', 'printCatPawVersion')
vc('boolean', 'core', 'versionPrinters', 'printFrameworkVersion')
vc('boolean', 'core', 'versionPrinters', 'printLuaVersion')
vc('boolean', 'core', 'versionPrinters', 'print3rdPartyVersions')

vc(        'table',                'core', 'env')
vc(        {'no', 'line', 'full'}, 'core', 'env', 'ioVBufMode') 
if vc(     'table',                'core', 'env', 'extraPaths') then
	for k, _ in pairs(user_config.core.env.extraPaths) do
		vc('string',               'core', 'env', 'extraPaths', k)
	end
end

vc('table',               'love2d')
vc('boolean',             'love2d', 'showDeprecationOutput')
vc({'linear', 'nearest'}, 'love2d', 'defaultImageFilterMin')
vc({'linear', 'nearest'}, 'love2d', 'defaultImageFilterMag')
vc('number',              'love2d', 'defaultImageFilterAnisotropy')

vc('table',   'engine')
vc('table',   'engine', 'game')
vc('number',  'engine', 'game', 'targetWindowW')
vc('number',  'engine', 'game', 'targetWindowH')
vc('string',  'engine', 'game', 'name')
vc('string',  'engine', 'game', 'globalsFile')
vc('string',  'engine', 'game', 'entryPoint')


--============================ Config Loading - Inject User Overrides ==============================
local inject;
function inject(t, cfg)
	for k, v in pairs(cfg) do
		if type(v) == 'table' then
			t[k] = t[k] or {}
			inject(t[k], cfg[k])

		--`nil` values are skipped in Lua tables, but sometimes they act funny.
		--So, just to be safe.
		elseif v ~= nil then
			t[k] = v
		end
	end
end

CAT_PAW_CONFIG = {}
inject(CAT_PAW_CONFIG, default_config or {})
inject(CAT_PAW_CONFIG, user_config or {})

--============================ Config Loading - Done ==============================
--=                                   DONE                                        =
--============================ Config Loading - Done ==============================

--============================ Env Setup ==============================
local envC = CAT_PAW_CONFIG.core.env

io.stdout:setvbuf(envC.ioVBufMode)
if envC.ioVBufMode == 'no' then
	print("Setting stdout's vbuf mode to 'no'. This is needed for some consoles to work properly.")
end

local extraPaths = ""
for _, path in ipairs(envC.extraPaths) do
	extraPaths = extraPaths .. path .. ";"
end

package.path = extraPaths .. package.path
--Love adds 2 extra loaders which are used for searching the .love archive and what not.
--They are not affected by `package.path`.
love.filesystem.setRequirePath(extraPaths .. love.filesystem.getRequirePath())

--============================ Love2D ==============================
local loveC = CAT_PAW_CONFIG.love2d

--TODO: Move this to LoveHooks
love.setDeprecationOutput(loveC.showDeprecationOutput)
love.graphics.setDefaultFilter(
		loveC.defaultImageFilterMin,
		loveC.defaultImageFilterMag,
		loveC.defaultImageFilterAnisotropy
)

--============================ Version Printers ==============================
local verC = CAT_PAW_CONFIG.core.versionPrinters

local catPawVersion;
succ, catPawVersion = pcall(require, "cat-paw.version")
if not succ then
	succ, catPawVersion = pcall(require, "version")
	if not succ then catPawVersion = "UNKNOWN" end		---@diagnostic disable-line
end

local printAnyVersions = verC.printCatPawVersion or verC.printFrameworkVersion or 
		verC.printLuaVersion or verC.print3rdPartyVersions
if printAnyVersions then print("============================================================") end
	
if verC.printLuaVersion then
	print("Running Lua version:      ", _VERSION)
	if jit then
		print("Running Luajit version:   ", jit.version)
	end
end
if verC.printFrameworkVersion then
	print("Running Love2d version: ", love.getVersion())
end
if verC.printCatPawVersion then
	print("Running CatPaw version: ", catPawVersion)
end
if verC.print3rdPartyVersions then
	print("\nCurrently using the following 3rd-party libraries (and possibly more):")
	print("middleclass\tBy Kikito\tSingle inheritance OOP in Lua\t[MIT License]")
	print("bump\t\tBy Kikito\tSimple platformer physics.\t[MIT License]")
	print("suit\t\tBy vrld\t\tImGUIs for Lua/Love2D\t\t[MIT License]")
	print("Huge thanks to (Kikito and vrld) for their wonderful contributions to the community; and for releasing their work under such open licenses!")
end

if printAnyVersions then print("============================================================") end

--============================ Globals File ==============================
local gameC = CAT_PAW_CONFIG.engine.game

if gameC.globalsFile ~= "" then
	succ = pcall(require, gameC.globalsFile)
	if succ then print("Loaded globals file from: " .. gameC.globalsFile) end
end

--============================ Entry Point ==============================
--gc defined above, in the Globals File region.

if gameC.entryPoint ~= "" then
	print("About to load game: " .. gameC.name)
	local Game = require(gameC.entryPoint)
	if love.system.getOS() == 'Web' and type(love.resize) == 'function' then
		print("[INFO/Web] Manually calling `love.resize` as a temporary fix for LoveJS not properly emitting resize events.")
		love.resize(love.graphics.getDimensions())
	end
	local game = Game(gameC.name, gameC.targetWindowW, gameC.targetWindowH)
	if love.system.getOS() == 'Web' and type(love.resize) == 'function' then
		print("[INFO/Web] Queueing a EvWindowResize as a temporary fix for LoveJS not properly emitting resize events.")
		local EvWindowResize = require "cat-paw.core.patterns.event.os.EvWindowResize"
		game:getEventSystem():queue(EvWindowResize(love.graphics.getDimensions()))
	end
end

