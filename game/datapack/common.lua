--Author:    Dulfiqar 'Active Diamond' H. Al-Safi
--Year:      (C) 2026
--File:      common.lua

data{"logos_scene",
	LOGOS = {{
			ID = "love_logo",
			DURATION = 2,
			TEXT = "A GAME BY:",
			FONT = 2,

			w = 160,
			h = 90,
		},{
			ID = "cat_paw_logo",
			DURATION = 2,
			TEXT = "MADE WITH:",
	
			w = 160,
			h = 90,
	}},

	FADE_IN = true,
	FADE_OUT = true,

	--The distance from the center for the text displayed above the logos ("Made By", etc...). Percentage of window height.
	TEXT_Y_CENTER_OFFSET = 0.2
}
