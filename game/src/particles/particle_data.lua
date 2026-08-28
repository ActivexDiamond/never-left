--[[
module = {
	x=emitterPositionX, y=emitterPositionY,
	[1] = {
		system=particleSystem1,
		kickStartSteps=steps1, kickStartDt=dt1, emitAtStart=count1,
		blendMode=blendMode1, shader=shader1,
		texturePreset=preset1, texturePath=path1,
		shaderPath=path1, shaderFilename=filename1,
		x=emitterOffsetX, y=emitterOffsetY
	},
	[2] = {
		system=particleSystem2,
		...
	},
	...
}
]]
local LG        = love.graphics
local particles = {x=-28.5, y=-20.125}

local image1 = LG.newImage("assets/particles/circle.png")
image1:setFilter("linear", "linear")

local ps = LG.newParticleSystem(image1, 59)
ps:setColors(0.453125, 0.453125, 0.453125, 1, 0.25, 0.25, 0.25, 1, 0, 0, 0, 1)
ps:setDirection(0)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(20.089294433594)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.11040227115154, 0.34557870030403)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.072022780776024)
ps:setSizeVariation(0)
ps:setSpeed(30.277151107788, 118.17275238037)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=38, kickStartDt=0, emitAtStart=59, blendMode="alpha", shader=nil, texturePath="assets/particles/circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=0, y=0})

local ps = LG.newParticleSystem(image1, 59)
ps:setColors(1, 0, 0, 1, 0.2265625, 0.27490234375, 1, 1, 0, 1, 0.015625, 1)
ps:setDirection(0)
ps:setEmissionArea("none", 0, 0, 0, false)
ps:setEmissionRate(20.089294433594)
ps:setEmitterLifetime(0)
ps:setInsertMode("top")
ps:setLinearAcceleration(0, 0, 0, 0)
ps:setLinearDamping(0, 0)
ps:setOffset(50, 50)
ps:setParticleLifetime(0.058957424014807, 0.37628230452538)
ps:setRadialAcceleration(0, 0)
ps:setRelativeRotation(false)
ps:setRotation(0, 0)
ps:setSizes(0.072022780776024)
ps:setSizeVariation(0)
ps:setSpeed(34.31697845459, 133.94032287598)
ps:setSpin(0, 0)
ps:setSpinVariation(0)
ps:setSpread(6.2831854820251)
ps:setTangentialAcceleration(0, 0)
table.insert(particles, {system=ps, kickStartSteps=38, kickStartDt=0, emitAtStart=59, blendMode="add", shader=nil, texturePath="assets/particles/circle.png", texturePreset="circle", shaderPath="", shaderFilename="", x=0, y=0})

return particles
