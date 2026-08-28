local uColor = {}

--============================ Performance Locals ==============================
local math_min = math.min
local math_max = math.max
local math_abs = math.abs
local math_sqrt = math.sqrt

--============================ Format Helpers ==============================
---Converts a hex color code to normalized RGB/RGBA, i.e. [0-1], values.
---
---Specifically, matches the first occurence of 8-consecutive hexadecimal digits in the string ignoring any other characters before or after them.
---If 8-consecutive ones aren't found (alpha is not specified), it looks for 6-consecutive ones instead.
---Otherwise, returns nil.
---Single-hex-per-color codes (e.g. #F7B instead of #FF77BB) are not accepted.
---
---@param colorCode string A hex RGB/RGBA color code. Preceding hashtags optional. See description for details.
---@return number? red The red component, in the range [0-1]. Or nil, on failure.
---@return number? green The green component, in the range [0-1]. Or nil, on failure.
---@return number? blue The blue component, in the range [0-1]. Or nil, on failure.
---@return number? alpha The alpha component, if any, in the range [0-1]. Or nil, on failure.
function uColor.fromHex(colorCode)
	--Attempt conversion with defined alpha.
	local _, _, r, g, b, a = colorCode:find("(%x%x)(%x%x)(%x%x)(%x%x)")
	--Any of the above work for this check
	if not r then 
		--Attempt conversion with no alpha.
		_, _, r, g, b = colorCode:find("(%x%x)(%x%x)(%x%x)")
	end

	--Conversion failed.
	if not r then return end

	return tonumber(r, 16) / 255,
			tonumber(g, 16) / 255,
			tonumber(b, 16) / 255,
			a and (tonumber(a, 16) / 255)
end

--============================ Color Space Helpers ==============================
---Credit: https://github.com/iskolbin/lhsx/blob/master/hsx.lua
function uColor.rgbToHsl(r, g, b)
	--FIXME: Update naming to follow CatPaw conventions.
	local M, m = math_max(r, g, b), math_min(r, g, b)
	local C = M - m
	local K = 1.0 / (6 * C)
	local h = 0
	if C ~= 0 then
		if M == r     then h = ((g - b) * K) % 1.0
		elseif M == g then h = (b - r) * K + 1.0 / 3.0
		else               h = (r - g) * K + 2.0 / 3.0
		end
	end
	local l = 0.5 * (M + m)
	local s = 0
	if l > 0 and l < 1 then
		s = C / (1 - math_abs(l + l - 1))
	end
	return h, s, l
end

---Credit: https://github.com/iskolbin/lhsx/blob/master/hsx.lua
function uColor.hslToRgb(h, s, l)
	--FIXME: Update naming to follow CatPaw conventions.
	local C = (1 - math_abs( l + l - 1 )) * s
	local m = l - 0.5 * C
	local r, g, b = m, m, m
	if h == h then
		local h_ = (h % 1.0) * 6.0
		local X = C * (1 - math_abs(h_ % 2 - 1))
		C, X = C + m, X + m
		if     h_ < 1 then r, g, b = C, X, m
		elseif h_ < 2 then r, g, b = X, C, m
		elseif h_ < 3 then r, g, b = m, C, X
		elseif h_ < 4 then r, g, b = m, X, C
		elseif h_ < 5 then r, g, b = X, m, C
		else               r, g, b = C, m, X
		end
	end
	return r, g, b
end
--============================ Gradients ==============================
--TODO: Use `overload.lua` to provide overrides with alpha support.

--    0 = col1    ;    1 = col2
function uColor.blendRgb(percentage, r1, g1, b1, r2, g2, b2)
	if percentage == 0 then return r1, g1, b1 end
	if percentage == 1 then return r2, g2, b2 end
	
	local invP = 1 - percentage
	return  math_sqrt(invP * r1^2 + percentage * r2^2),
			math_sqrt(invP * g1^2 + percentage * g2^2),
			math_sqrt(invP * b1^2 + percentage * b2^2)
end

--    0 = col1    ;    1 = col2
--Avoids using square roots, is a lot faster but the middle-sections of the gradient may be a bit too dark.
function uColor.blendRgbFast(percentage, r1, g1, b1, r2, g2, b2)
	if percentage == 0 then return r1, g1, b1 end
	if percentage == 1 then return r2, g2, b2 end
	
	local mul = percentage * 2 - 1
	local mul1 = (mul + 1 ) / 2
	local mul2 = 1 - mul1

	return  (r1 * mul1 + r2 * mul2),
			(g1 * mul1 + g2 * mul2),
			(b1 * mul1 + b2 * mul2)
end

return uColor
