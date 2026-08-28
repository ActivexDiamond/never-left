local middleclass = require "cat-paw.core.patterns.oop.middleclass"
--[[
local function xlock(self)
	local inv = {}
	for k, v in pairs(self) do
		inv[k] = v
		self[k] = nil
	end
	
	local mt = getmetatable(self)
	local oopindex = mt.__index
	local function index(_, k)
		local o = inv[k] 
		if o and k ~= "class" then return o end
		return oopindex(self, k)
	end
	
	function self:iter()
		return function(_, k)
			local nk, v = next(inv, k)
			if nk == "class" then nk, v = next(inv, nk) end
			return nk, v
		end
	end
	
	mt.__index = index
	mt.__newindex = function() error "All Event fields are read-only." end,
	setmetatable(self, mt)
end
--]]

local function lock(self)
	function self.iterator()
		return function(_, k)
			local _k, _v = next(self, k)
			while _k == "class" or _k == "iterator" do
				_k, _v = next(self, _k) 
			end
			return _k, _v
		end
	end
		
	return setmetatable({}, {
		__index = self,
		__newindex = function() error "All Event fields are read-only." end,
		__tostring = self.__tostring,
	})
end

local Event = middleclass("Event")
function Event:initialize()
end

local new = Event.new
function Event.static:new(...)
	local inst = new(self, ...)
	return lock(inst)
end

--Useful for re-using Event instances for performance reasons but remove the runtime safety check of modifying an Event's fields.
function Event.static:newUnlocked(...)
	local inst = new(self, ...)
	return inst
end
return Event

--[[

print(Event)
local e = Event:newUnlocked(42)

print(e)
print(e.k)
-- e:instanceMethod()
print(e.class)
print(e.super)

print(e.iter)
--print(e:iter())
print ' --------- '
for k, v in pairs(e) do print(k, v) end c = next;
print ' --------- '
-- for k, v in e:iterator() do print(k, v) end

print ' --------- '

e.k = 3
e.y = 3
print('k, y', e.k, e.y)
e = lock(e)
print('k, y', e.k, e.y)
--]]
