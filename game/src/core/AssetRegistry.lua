local middleclass = require "libs.middleclass"
local utils = require "libs.utils"

local DataRegistry = require "core.DataRegistry"

------------------------------ Constructor ------------------------------
local AssetRegistry = middleclass("AssetRegistry")
function AssetRegistry:initialize()
	self.allAssets = {}
	self.spr = {inv = {}, obj = {}, gui = {}}
	self.sfx = {}
	self.bgm = {}
	
	self.MISSING_TEXTURE = love.graphics.newImage("assets/spr/obj/missing_texture.png")
	
	--dirs config
	self.dirs = {
		spr = {
			inv = [[assets/spr/inv]], 
			obj = [[assets/spr/obj]], 
			gui = [[assets/spr/gui]],
		},
		sfx = [[assets/sfx]],
		bgm = [[assets/bgm]],
	}
	
	self.sprDirs = [[
		datapack/items
		datapack/blocks
		
	]]

	--keeps pixels sharp	
	love.graphics.setDefaultFilter('nearest', 'nearest')

	--cleanDirList
 	self.dirs.spr.inv = self:_cleanDirs(self.dirs.spr.inv)
 	self.dirs.spr.obj = self:_cleanDirs(self.dirs.spr.obj)
 	self.dirs.spr.gui = self:_cleanDirs(self.dirs.spr.gui)
 	self.dirs.sfx = self:_cleanDirs(self.dirs.sfx)
 	self.dirs.bgm = self:_cleanDirs(self.dirs.bgm)
end

------------------------------ API ------------------------------
--TODO: Un-hardcode "obj/inv/gui/etc..." and instead have them be put into those groups based on
-- the folders they are grouped into in the filesystem.
-- Thus, this same style is supported but dictated by the project's filesystem-layout instead of
-- being hardcoded. Other assets (audio, map?, etc...) should follow a similar concept.
---API
function AssetRegistry:getSprInv(obj, w, h, path)
	return self:_fetchSpr(obj, w, h, path or obj.pathSprInv, self.spr.inv)
end
function AssetRegistry:getSprObj(obj, w, h, path)
	return self:_fetchSpr(obj, w, h, path or obj.pathSprObj, self.spr.obj)
end
function AssetRegistry:getSprGui(obj, w, h, path)
	return self:_fetchSpr(obj, w, h, path or obj.pathSprGui, self.spr.gui)
end
function AssetRegistry:getSpr(obj, w, h, path)
	return self:_fetchSpr(obj, w, h, path, self.allAssets)
end
------------------------------ Loaders ------------------------------
function AssetRegistry:loadSprInv()
	self:_loadImages(self.dirs.spr.inv, self.spr.inv, self.allAssets)
end
function AssetRegistry:loadSprObj()
	self:_loadImages(self.dirs.spr.obj, self.spr.obj, self.allAssets)
end
function AssetRegistry:loadSprGui()
	self:_loadImages(self.dirs.spr.gui, self.spr.gui, self.allAssets)
end

function AssetRegistry:loadSfx()
	self:_loadAudio(self.dirs.sfx, self.sfx, 'static', self.allAssets)
end
function AssetRegistry:loadBgm()
	self:_loadAudio(self.dirs.bgm, self.bgm, 'stream', self.allAssets)
end
	
------------------------------ Internals ------------------------------
function AssetRegistry:_fetchSpr(obj, w, h, objPath, storage)
	local path = objPath or obj.ID
	local spr = storage[path] or self.MISSING_TEXTURE
	if spr[0] and spr[0].typeOf and spr[0]:typeOf("Drawable") then
		--Is animation
		local frame = spr[obj.currentFrame]
		local sprW, sprH = frame:getDimensions()
		return spr, (w or obj.w)/sprW, (h or obj.h)/sprH
	else
		--Single image
		local sprW, sprH = spr:getDimensions()
		return spr, (w or obj.w)/sprW, (h or obj.h)/sprH
	end
end

function AssetRegistry:_cleanDirs(dirs)
	dirs = utils.str.rem(dirs, "%s")			--remove spaces
	dirs = utils.str.rem(dirs, "\t")			--remove tabs
	return utils.str.sep(dirs, '\n')			--cut into arr
end	

function AssetRegistry:_loadImages(dirs, destGroup, destPile)	--TODO: Better noun than 'pile'.
	for _, dir in ipairs(dirs) do
		local files, snFiles = utils.listDirItems(dir)
		print("Total images to load: " .. #files)
		for i = 1, #files do
			local file, snFile = files[i], snFiles[i]
			
			local loaded;
			if love.filesystem.getInfo(file).type == 'file' then 
				print("Loading image: " .. file)
				loaded = love.graphics.newImage(tostring(file))
				snFile = snFile:sub(1, -5)		--Remove the ".png" extension from the name. TODO: Use regex.
			elseif love.filesystem.getInfo(file).type == 'directory' then
				local f, snf = utils.listFiles(file)
				print(string.format("Loading animation (%d frames): %s", #f, file))
				loaded = {}
				for i = 0, #f - 1 do
					--E.g. "assets/spr/obj/crackels/crackels_i.png"
					local str = string.format("%s/%d.png", file, i)
					local frame = love.graphics.newImage(str)
					loaded[i] = frame
				end
			end
			destPile[file] = loaded
			destGroup[snFile] = loaded
		end
	end
end
	
function AssetRegistry:_loadAudio(dir, dest, type)
	error "WIP"
end

return AssetRegistry()
