-- Client-side menu state machine and settings store shared by every menu controller.
-- INITIALIZING -> MENU_ACTIVE -> TRANSITIONING -> GAMEPLAY
-- TRANSITIONING may fall back to MENU_ACTIVE if the server rejects the request.

local MenuConfig = require(script.Parent.MenuConfig)

local MenuState = {}

MenuState.States = {
	INITIALIZING = "INITIALIZING",
	MENU_ACTIVE = "MENU_ACTIVE",
	TRANSITIONING = "TRANSITIONING",
	GAMEPLAY = "GAMEPLAY",
}

local ALLOWED = {
	INITIALIZING = { MENU_ACTIVE = true },
	MENU_ACTIVE = { TRANSITIONING = true },
	TRANSITIONING = { GAMEPLAY = true, MENU_ACTIVE = true },
	GAMEPLAY = {},
}

local current = MenuState.States.INITIALIZING
local changed = Instance.new("BindableEvent")
local settingChanged = Instance.new("BindableEvent")

MenuState.Changed = changed.Event -- (newState, oldState)
MenuState.SettingChanged = settingChanged.Event -- (key, value)

function MenuState.get(): string
	return current
end

function MenuState.is(state: string): boolean
	return current == state
end

-- Returns true if the transition was valid and applied.
function MenuState.set(newState: string): boolean
	if not ALLOWED[current] or not ALLOWED[current][newState] then
		warn(string.format("[MenuState] rejected transition %s -> %s", current, newState))
		return false
	end
	local old = current
	current = newState
	changed:Fire(newState, old)
	return true
end

-- Resolves immediately if already in `state`, otherwise yields until it is entered.
function MenuState.waitFor(state: string)
	while current ~= state do
		changed.Event:Wait()
	end
end

------------------------------------------------------------------------
-- Settings
------------------------------------------------------------------------

local settings = table.clone(MenuConfig.DefaultSettings)

local function valid(key: string, value: any): boolean
	local default = MenuConfig.DefaultSettings[key]
	if default == nil or typeof(value) ~= typeof(default) then
		return false
	end
	if key == "VFXQuality" then
		return table.find(MenuConfig.VFXQualities, value) ~= nil
	elseif key == "SceneDetail" then
		return table.find(MenuConfig.SceneDetails, value) ~= nil
	elseif typeof(value) == "number" then
		return value >= 0 and value <= 1
	end
	return true
end

function MenuState.getSetting(key: string): any
	return settings[key]
end

function MenuState.getSettings()
	return table.clone(settings)
end

function MenuState.setSetting(key: string, value: any)
	if not valid(key, value) or settings[key] == value then
		return
	end
	settings[key] = value
	settingChanged:Fire(key, value)
end

-- Apply a table loaded from the server; unknown or invalid keys are ignored.
function MenuState.applySettings(t: { [string]: any }?)
	if type(t) ~= "table" then
		return
	end
	for key, value in pairs(t) do
		MenuState.setSetting(key, value)
	end
end

function MenuState.resetSettings()
	for key, value in pairs(MenuConfig.DefaultSettings) do
		MenuState.setSetting(key, value)
	end
end

MenuState.SelectedCharacter = MenuConfig.Characters[1].Id

return MenuState
