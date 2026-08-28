local asserter = {}

--============================ Helpers ==============================
--Similar to helpers.oneOf but inlined here to keep this module standalone.
local function oneOf(object, t, checkKeys)
	--Check outside the loop, for slight performance improvement.
	if checkKeys then
		for k, _ in pairs(t) do
			if k == object then
				return true
			end
		end
	else
		for _, v in pairs(t) do
			if v == object then
				return true
			end
		end
	end
	return false
end

local function prettyPrintTable(t)
	error("Method stub.")
end

local function prettyPrintKeys(t)
	local stringTable = {}
	for k, v in pairs(t) do
		table.insert(stringTable, tostring(k))
	end
	return "{" .. table.concat(stringTable, ", ") .. "}"
end

local function prettyPrintValues(t)
	local stringTable = {}
	for k, v in pairs(t) do
		table.insert(stringTable, tostring(v))
	end
	return "{" .. table.concat(stringTable, ", ") .. "}"
end

local function assertUp(condition, message)
	if not condition then
		error(message, 3)
	end
end

--============================ API - Tables ==============================
---Asserts if `object` is the given type.
---@param object any The object to check the type of.
---@param typ string The desired type.
---@param message string? An error message prepended to a message that lists the expected and gotten values.
function asserter.isType(object, typ, message)
	assertUp(type(object) == typ, (message or "") .. ("\n\tExpected %s. Got: %s")
			:format(typ, type(object)))
end

--============================ API - Tables ==============================
---Asserts if `object` is one of the entries of `t`. Uses equals (`==`) for comparison.
---@param object any The object to look for inside `t`.
---@param t any[] An array of objectects to compare `obj` against.
---@param message string? An error message prepended to a message that lists the expected and gotten values.
function asserter.oneOf(object, t, message)
	assertUp(oneOf(object, t), (message or "") .. ("\n\tExpected one of %s. Got: %s")
			:format(prettyPrintValues(t), tostring(object)))
end

function asserter.oneOfKeys(object, t, message)
	assertUp(oneOf(object, t, true), (message or "") .. ("\n\tExpected one of %s. Got: %s")
			:format(prettyPrintKeys(t), tostring(object)))
end

--============================ API - Numbers ==============================
---Asserts if `n` is a number first, then if it is within the given range. 
---`message` is only used if the type check succeeds, otherwise shows a generic message.
---@param n number The number to check.
---@param min number Lower bound of the range. Inclusive.
---@param max number Upper bound of the range. Inclusive.
---@param message string? An error message prepended to a message that lists the expected and gotten values.
function asserter.inRange(n, min, max, message)
	assertUp(type(n) == 'number', "Expected a number. Got: " .. type(n))
	assertUp(max >= n and n >= min, (message or "") ..
			("\n\tNumber was outside the valid range. Should've been within [%d, %d]. Got: %d")
			:format(min, max, n))
end

---Asserts if a < b
---@param a number 
---@param b number 
---@param message string? An error message prepended to a message that lists the expected and gotten values.
function asserter.lessThan(a, b, message)
	assertUp(type(a) == 'number', "Expected a number. Got: " .. type(a))
	assertUp(type(b) == 'number', "Expected a number. Got: " .. type(b))
	assertUp(a < b, (message or "") ..
			("\n\tShould've been less than %d. Got: %d")
			:format(b, a))
end


--============================ API - Other ==============================
---If you're using Asserter, it is recommended to use this instead of Lua's builtin `error`.
---It currently does nothing, but is intended to hook into Asserter's logging and what not later on.
---@param message string? An error message prepended to a message that lists the expected and gotten values.
function asserter.err(message)
	error(message)
end

--============================ Activation Toggle ==============================
--TODO: Improve.

local function blank() print "noo" end

local FUNCTION_LIST = {}
for k, v in pairs(asserter) do
	if type(v) == 'function' then
		FUNCTION_LIST[k] = v
	end
end

---Restore normal functionality. Use after an `asserter.disable()`. `asserter` is enabled  by default.
function asserter.enable()
	for k, v in pairs(FUNCTION_LIST) do
		asserter[k] = v
	end
end

---Switch out all `asserter` functions for a dummy blank one. Mainly useful for performance.
function asserter.disable()
	for k, v in pairs(FUNCTION_LIST) do
		asserter[k] = blank
	end
end


return asserter

