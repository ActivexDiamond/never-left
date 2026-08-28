--
--tl;dr: If you are only using the `core` layer, you may *mostly* ignore this file.
--

--TODO: Change this to INI, or similar.

--CatPaw modules will read their initial configuration setup from here.
--Most attempt to follow this, instead of requiring configuration at runtime.
--Note that this is a normal file which is loaded AFTER your framework's entrypoint.
--So if you need to set configs in your framework that require being set before running.
--    (such as disabling a Love2D module from loading inside of Love's `conf.lua`,
--    then this file will not suffice.
--However, for anything that can be set afterwards, this file will do.
--Similarly, most configs set here can later be modified at runtime, if you wish.

--The `core` layer only ever touches this file if you use the provided `main.lua` template.
--Which will print the versions of some tools, set some conveniences in Lua's default env,
--    and that's about it. Nothing critical.
--So even if you are using the entirety of the `core` layer, and with it's `main.lua` template,
--    you can still *mostly* ignore this file.

return {
--============================ Layer: Core ==============================
	core = {
		--Some info that is printed on program start.
		--If you disable these, make sure you still follow the license requirements for 
		--    the various tools we use! Most just require you show their name to the user.
		versionPrinters = { 
			printCatPawVersion    = true,            --Default: true
			--This currently prints Love2D's version. 
			--Once more framework hooks are added, this will 
			--    print the version of the currently active one.
			printFrameworkVersion = true,            --Default: true
			printLuaVersion       = true,            --Default: true
			--Ones such as Kikito's middleclass, etc...
			print3rdPartyVersions = true,            --Default: true
		},

		--Some modification to the usual/default Lua enviorenment.
		--Mostly work arounds for bugs in common terminals, or conveniences.
		env = {
			--Passed to `io.stdout:setvbuf(mode)`.
			--Some terminals dislike Lua's default buffering, so our default disables it.
			--May be one of 'no', 'line', or a'full'.
			ioVBufMode = 'no',                       --Default: 'no'
			--Extra paths to be setup in Lua's `package.path` and any other searchers your
			--    chosen framework may use (E.g. `love.filesystem.setRequirePath(path)`
			--    in the case of Love2D).
			--Those defaults are mainly used because Love2D does not allow reading 
			--    assets from a directory above where `main.lua` is located.
			--This helps you keep your `src` directory seperate from things.
			--    such as `assets` or `datapacks`.
			--Make sure to include the `init` version for whatever directories you add,
			--    so Lua's directory-requiring mechanisms work, as some libs expect it.
			--See here for format details: https://www.lua.org/pil/8.1.html
			extraPaths = {            --Default: {"src/?.lua", "src/?/init.lua"}
				"src/?.lua",
				"src/?/init.lua",
			},
		},
		--See "cat-paw.core.dev.HotSwap" for details on each option.
		hotSwap = {
			enabled = false,
			scanInterval = 0.5,
			protect = 3, --TODO: How should constants/enums be passed in here?
			pauseExecution = 3,
			emitChangeEvents = true,
		}
	},

--============================ Framework Specifics ==============================
	love2d = {
		--Passed to `love.setDeprecationOutput(enable)
		showDeprecationOutput = false,                --Default: false
		defaultImageFilterMin = 'nearest',            --Default: 'nearest'
		defaultImageFilterMag = 'nearest',            --Default: 'nearest'
		defaultImageFilterAnisotropy = nil,           --Default: nil

	},

--============================ Layer: Engine ==============================
	engine = {
		--If your game uses the `engine` layer or above, you will need to initialize
		--    by inheriting `engine.AbstractGame` and going from there.
		--Those are configs relating to that.
		game = {
			--May not match the actually obtainable window dimensions.
			--Set to -1 for fulslcreen.
			targetWindowW = 800,                     --Default: 800
			targetWindowH = 600,                     --Default: 600
			--Used for the window title, save directory identity, etc....
			name = "CatPaw's Purrfect Game",	     --Default: "CatPaw's Purrfect Game"
			--Just loaded before your game class is initialized, no more is done with it.
			--However, by convention, it's intended to be a place to bundle your globals.
			globalsFile = "",                        --Default: ""
			--The entry point of your project.
			entryPoint = "Game",                     --Default: "Game"
		},
	},
}
