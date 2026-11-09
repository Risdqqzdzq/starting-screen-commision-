-- Central configuration for the main menu: identity, audio, settings defaults,
-- character previews, credits and update log. Edit content here, not in the UI code.

local MenuConfig = {}

MenuConfig.Title = "EVERGREEN"
MenuConfig.Subtitle = "THE LOST KINGDOM"
MenuConfig.Version = "v0.1.0 · Prototype"
-- Optional logo image (rbxassetid://...). When set, it replaces the text title.
MenuConfig.LogoImage = ""

MenuConfig.Theme = {
	Ivory = Color3.fromRGB(250, 244, 228),
	Gold = Color3.fromRGB(226, 186, 108),
	GoldBright = Color3.fromRGB(255, 220, 146),
	Ink = Color3.fromRGB(14, 26, 30),
	Panel = Color3.fromRGB(16, 32, 36),
	Teal = Color3.fromRGB(70, 168, 150),
	TitleFont = Font.fromEnum(Enum.Font.Garamond),
	BodyFont = Font.fromEnum(Enum.Font.Merriweather),
	UIFont = Font.fromEnum(Enum.Font.Garamond),
}

-- Audio. Asset IDs below were found in the Creator Store (free, public). Replace
-- any of them with your own; an empty string disables that sound.
MenuConfig.Audio = {
	MenuTheme = "rbxassetid://1845719717", -- "Moonlight Magic D" (APM Music)
	AmbientWind = "", -- no suitable gentle wind loop found; add one here
	Birdsong = "rbxassetid://9112832297", -- "Mountain Birds 2" (Pro Sound Effects)
	UIHover = "rbxassetid://82676714368656", -- "Select"
	UIClick = "rbxassetid://8816939097", -- "Button Click" (ZapSplat)
	Transition = "rbxassetid://124113820339492", -- "INSTRUMENT Wind Chime"
	MusicFadeTime = 2.5,
}

MenuConfig.DefaultSettings = {
	MusicVolume = 0.7,
	SFXVolume = 0.8,
	CameraMotion = true,
	VFXQuality = "High", -- Low | Medium | High
	SceneDetail = "Cinematic", -- Performance | Balanced | Cinematic
}
MenuConfig.VFXQualities = { "Low", "Medium", "High" }
MenuConfig.SceneDetails = { "Performance", "Balanced", "Cinematic" }

-- Placeholder preview characters. Selection is sent with the Play request and
-- validated by the server (stored as the player's "SelectedClass" attribute).
MenuConfig.Characters = {
	{
		Id = "Warden",
		Name = "Aldric the Warden",
		Description = "A steadfast guardian of the village gates. Heavy armour, a broad shield and an oath he has never broken.",
		Colors = { Body = Color3.fromRGB(90, 110, 130), Accent = Color3.fromRGB(226, 186, 108), Skin = Color3.fromRGB(234, 196, 160), Hair = Color3.fromRGB(90, 60, 40) },
		Gear = "Shield",
	},
	{
		Id = "Sage",
		Name = "Lyra the Sage",
		Description = "A wandering scholar who hears the old songs in the wind. Her staff remembers the kingdom that was lost.",
		Colors = { Body = Color3.fromRGB(110, 80, 160), Accent = Color3.fromRGB(120, 230, 240), Skin = Color3.fromRGB(246, 214, 186), Hair = Color3.fromRGB(240, 236, 226) },
		Gear = "Staff",
	},
	{
		Id = "Ranger",
		Name = "Fen the Ranger",
		Description = "Raised in the turquoise woods beyond the mill. Quick, quiet and never far from the treeline.",
		Colors = { Body = Color3.fromRGB(60, 120, 90), Accent = Color3.fromRGB(176, 124, 78), Skin = Color3.fromRGB(214, 168, 130), Hair = Color3.fromRGB(150, 70, 40) },
		Gear = "Bow",
	},
}

MenuConfig.Credits = {
	{ Section = "Direction & Design", Names = { "aziAADtje" } },
	{ Section = "World & Environment", Names = { "JaydenPeyden" } },
	{ Section = "Programming", Names = { "aziAADtje" } },
	{ Section = "Music", Names = { "\"Moonlight Magic\" courtesy of APM Music" } },
	{ Section = "Sound Effects", Names = { "Pro Sound Effects", "ZapSplat", "Creator Store contributors" } },
}

-- Newest first. Add entries without touching the UI code.
MenuConfig.UpdateLog = {
	{
		Version = "0.1.0",
		Date = "2026-10-27",
		Title = "The Windmill Village",
		Notes = {
			"New cinematic main menu with a five-shot camera sequence.",
			"Handcrafted windmill village with animated sails, foliage and banners.",
			"Ambient magic: glowing gardens, motes, butterflies, birds and falling leaves.",
			"Settings for audio, camera motion, VFX quality and scene detail.",
		},
	},
	{
		Version = "0.0.1",
		Date = "2026-10-01",
		Title = "First Light",
		Notes = { "Project created." },
	},
}

return MenuConfig
