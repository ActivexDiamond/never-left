local uMath = {}

local math_min = math.min
local math_max = math.max

function uMath.bind(x, min, max)
	return math_min(math_max(x, min), max)
end

function uMath.map(x, from1, to1, from2, to2)
	return (x - from1) / (to1 - from1) * (to2 - from2) + from2;
end
	
return uMath


