DEBUG = {
	SKIP_LOGOS = true,

	DEV_MODE = true,

	SHOW_LOVE_VERSION = false,
	SHOW_FPS = false,

	DISABLE_SHADERS = true,
	MUTE_AUDIO = false,

	DRAW_BOUNDING_BOXES = false,
	DRAW_INTERACT_BOX = false,
	
}



 
AUDIO = {
	SFX = {
		-- gameover.mp3 by bsp7176 -- https://freesound.org/s/570633/ -- License: Attribution NonCommercial 3.0
		pickup = love.audio.newSource("assets/sfx/pickup.mp3", "static"),
		-- open door by sound reality -- https://pixabay.com/sound-effects/household-opening-door-411632/ -- License: Attribution 4.0
		opendoor = love.audio.newSource("assets/sfx/opendoor.mp3", "static"),
		heartbeat = love.audio.newSource("assets/sfx/heartbeat.wav", "static"),
		typing = love.audio.newSource("assets/sfx/typing.mp3", "static"),

		-- j1game_over_mono.wav by jivatma07 -- https://freesound.org/s/173859/ -- License: Creative Commons 0
		doorknock = love.audio.newSource("assets/sfx/doorknocking.wav", "static"),

		basmentsound = love.audio.newSource("assets/sfx/basmenthorrorsound.wav", "static"),

		basmentsound2 = love.audio.newSource("assets/sfx/basmenthorrorsound2.wav", "static"),
		
		raining = love.audio.newSource("assets/sfx/raining.mp3", "stream"),
 
	 

		walkingg = love.audio.newSource("assets/sfx/walk.mp3", "static"),
  

		rainingthunder = love.audio.newSource("assets/sfx/rainingthunder.mp3", "static"),

		thunder = love.audio.newSource("assets/sfx/thunder.mp3", "static"),

		clockticking = love.audio.newSource("assets/sfx/clockticking.mp3", "static"),

		draggingwood = love.audio.newSource("assets/sfx/draggingwood.wav", "static"),

		callinghorror = love.audio.newSource("assets/sfx/callinghorror.mp3", "static"),

		horro2 = love.audio.newSource("assets/sfx/horro2.mp3", "static"),

		horror1 = love.audio.newSource("assets/sfx/horror1.mp3", "static"),

		horror3 = love.audio.newSource("assets/sfx/horror3.mp3", "static"),

		knocking = love.audio.newSource("assets/sfx/knocking.wav", "static"),

		rain = love.audio.newSource("assets/sfx/rain.mp3", "static"),

		rainmedium = love.audio.newSource("assets/sfx/rainmedium.wav", "static"),

		scaryroomnoise = love.audio.newSource("assets/sfx/scaryroomnoise.wav", "static"),

		staticnoise = love.audio.newSource("assets/sfx/staticnoise.mp3", "static"),

		swoshhorror = love.audio.newSource("assets/sfx/swoshhorror.mp3", "static"),

	},
}

---Play a sound, optionally with some variance. Pauses previous instances, if any.
---@param src love.Source The audio source to play.
---@param volume number? The volume. [default=1]
---@param pitch number? The pitch variance, if any. between 1 and 100. [default=nil]
---@param chance number? The chance of actually playing the audio. 1 is guranteed. Between 0 and 1. [default=1]
function PLAY_SOUND(src, volume, pitch, chance)
	if not src then return end

	volume = volume or 1
	chance = chance or 1

	src:setPitch(1)
	src:setVolume(volume)

	if pitch then
			local dir = love.math.random(1, 2)
		if dir == 1 then
			local variance = (100 - love.math.random(1, pitch)) / 100
			print(variance)
			src:setPitch(variance)
		else
			local variance = 1 + love.math.random(1, pitch) / 100
			print(variance)
			src:setPitch(variance)
		end
	end

	if chance < 1 then
		if love.math.random() < chance then
			src:stop()
			src:play()
		end
	else
		src:stop()
		src:play()
	end
end

local os = love.system.getOS()
if os == "Web" or os == "Android" then
	DEBUG.SKIP_LOGOS = false
	DEBUG.DEV_MODE = false
	DEBUG.MUTE_AUDIO = false
	DEBUG.INITIAL_SCENE = nil
	DEBUG.DRAW_INTERACT_BOX = false
end
if os == "Android" then
end

if love.filesystem.isFused() then
	DEBUG.SKIP_LOGOS = false
	DEBUG.DEV_MODE = false
	DEBUG.MUTE_AUDIO = false
	DEBUG.SHOW_FPS = false
	DEBUG.SHOW_LOVE_VERSION = false
	DEBUG.DRAW_INTERACT_BOX = false
end

if DEBUG.MUTE_AUDIO then
	love.audio.setVolume(0)
end
