-- The implicit third row is always 0, 0, 1
local matrix = {1,0,0,
                0,1,0}

local function getMatrix(t)
  if t == nil then
    -- Return a copy
    return {matrix[ 1], matrix[ 2], matrix[ 3],
            matrix[ 4], matrix[ 5], matrix[ 6]}
  end
  -- Assign the elements (enables reusing tables)
  -- (unrolled loop)
  t[1] = matrix[1]; t[2] = matrix[2]; t[3] = matrix[3]
  t[4] = matrix[4]; t[5] = matrix[5]; t[6] = matrix[6]
  return t
end

local function origin()
  matrix[1] = 1  matrix[2] = 0  matrix[3] = 0
  matrix[4] = 0  matrix[5] = 1  matrix[6] = 0
end

local function scale(x, y)
  y = y or x
  matrix[1] = matrix[1] * x; matrix[2] = matrix[2] * y
  matrix[4] = matrix[4] * x; matrix[5] = matrix[5] * y
end

local function rotate(a)
  local c, s = math.cos(a), math.sin(a)
  matrix[1], matrix[2] = matrix[1]*c + matrix[2]*s, matrix[1]*-s + matrix[2]*c
  matrix[4], matrix[5] = matrix[4]*c + matrix[5]*s, matrix[4]*-s + matrix[5]*c
end

local function shear(x, y)
  matrix[1], matrix[2] = matrix[1] + matrix[2]*y, matrix[1]*x + matrix[2]
  matrix[4], matrix[5] = matrix[4] + matrix[5]*y, matrix[4]*x + matrix[5]
end

local function translate(x, y)
  matrix[3] = matrix[3] + matrix[1]*x + matrix[2]*y
  matrix[6] = matrix[6] + matrix[4]*x + matrix[5]*y
end

local function xform(matrix, x, y)
  return matrix[1]*x + matrix[2]*y + matrix[3], matrix[4]*x + matrix[5]*y + matrix[6]
end

local function xformBack(matrix, x, y)
  x, y = x - matrix[3], y - matrix[6]
  local det = matrix[1] * matrix[5] - matrix[2] * matrix[4]
  if det ~= 0 then
    return (matrix[5] * x - matrix[2] * y) / det,
           (matrix[1] * y - matrix[4] * x) / det
  end
  -- The transform is 1D or 0D
  return x, y
end

return {getMatrix=getMatrix, xform = xform, xformBack = xformBack, origin=origin,
        scale=scale, rotate=rotate, shear=shear, translate=translate}
