--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      cat_paw_config.lua

return {

--============================ Layer: Core ==============================

	core = {
		versionPrinters = { 
			printCatPawVersion    = true,
			printFrameworkVersion = true,
			printLuaVersion       = true,
			print3rdPartyVersions = true,
		},

		env = {
			ioVBufMode = 'no',
			extraPaths = {
				"src/?.lua",
				"src/?/init.lua",
			},
		},
		hotSwap = {
			enabled = true,
		}
	},

--============================ Framework Specifics ==============================
	
	love2d = {
		showDeprecationOutput = false,
		defaultImageFilterMin = 'nearest',
		defaultImageFilterMag = 'nearest',
		defaultImageFilterAnisotropy = nil,

	},

--============================ Layer: Engine ==============================

	engine = {
		game = {
			targetWindowH = 640 * 2,
			targetWindowW = 360 * 2,
			name = "Escape The Curse",
			globalsFile = "GLOBALS",
			entryPoint = "core.Game",
		},
	},
}
