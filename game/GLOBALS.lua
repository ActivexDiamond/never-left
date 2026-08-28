DEBUG = {
	SKIP_LOGOS = true,

	DEV_MODE = true,

	SHOW_LOVE_VERSION = false,
	SHOW_FPS = false,
	
	DISABLE_SHADERS = true,
	MUTE_AUDIO = false,

	DRAW_BOUNDING_BOXES = false,
}

SFX = {
}

local os = love.system.getOS()
if os == "Web" or os == "Android" then
	DEBUG.SKIP_LOGOS = false
	DEBUG.DISABLE_SHADERS = false
	DEBUG.MUTE_AUDIO = false
	DEBUG.INITIAL_SCENE = nil
end
if os == "Android" then
	DEBUG.DISABLE_SHADERS = true
end

if love.filesystem.isFused() then
	DEBUG.SKIP_LOGOS = false
	DEBUG.MUTE_AUDIO = false
	DEBUG.SHOW_FPS = false
	DEBUG.SHOW_LOVE_VERSION = false
end

if DEBUG.MUTE_AUDIO then
	love.audio.setVolume(0)
end
