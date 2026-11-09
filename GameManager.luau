-- Server authority for the menu -> gameplay flow.
-- Players join without a character (they sit in the client-side main menu). The
-- client asks to start via Remotes.StartGameplay; the server validates the request,
-- records the chosen class and spawns the character. Deaths in gameplay respawn
-- normally and never send the player back to the menu.
-- Also persists per-player menu settings with DataStoreService.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local MenuConfig = require(ReplicatedStorage.Shared.MenuConfig)
local SpawnManager = require(script.Parent.SpawnManager)

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local StartGameplay: RemoteFunction = Remotes:WaitForChild("StartGameplay")
local LoadSettings: RemoteFunction = Remotes:WaitForChild("LoadSettings")
local SaveSettings: RemoteEvent = Remotes:WaitForChild("SaveSettings")

Players.CharacterAutoLoads = false

local PlayerState = { Menu = "Menu", Entering = "Entering", Gameplay = "Gameplay" }
local states: { [Player]: string } = {}
local lastRequest: { [Player]: number } = {}

local validClasses = {}
for _, c in ipairs(MenuConfig.Characters) do
	validClasses[c.Id] = true
end

------------------------------------------------------------------------
-- Gameplay entry
------------------------------------------------------------------------

local function onCharacterAdded(player: Player, character: Model)
	local humanoid = character:WaitForChild("Humanoid", 10) :: Humanoid?
	if not humanoid then
		return
	end
	humanoid.Died:Once(function()
		task.wait(Players.RespawnTime)
		-- Only respawn players who are still in gameplay and still on this character.
		if states[player] == PlayerState.Gameplay and player.Parent == Players and player.Character == character then
			SpawnManager.spawn(player)
		end
	end)
end

StartGameplay.OnServerInvoke = function(player: Player, payload: any)
	local now = os.clock()
	if lastRequest[player] and now - lastRequest[player] < 1 then
		return false, "Too many requests"
	end
	lastRequest[player] = now

	if states[player] ~= PlayerState.Menu then
		return false, "Already in game"
	end
	local classId = MenuConfig.Characters[1].Id
	if type(payload) == "table" and type(payload.CharacterId) == "string" and validClasses[payload.CharacterId] then
		classId = payload.CharacterId
	end

	states[player] = PlayerState.Entering
	player:SetAttribute("SelectedClass", classId)
	local ok, err = pcall(SpawnManager.spawn, player)
	if not ok or not player.Character then
		warn("[GameManager] spawn failed for", player.Name, err)
		states[player] = PlayerState.Menu
		return false, "Spawn failed"
	end
	states[player] = PlayerState.Gameplay
	player:SetAttribute("InGameplay", true)
	return true
end

------------------------------------------------------------------------
-- Settings persistence
------------------------------------------------------------------------

local store: DataStore? = nil
do
	local ok, result = pcall(function()
		return DataStoreService:GetDataStore("EvergreenMenuSettings_v1")
	end)
	if ok then
		store = result
	else
		warn("[GameManager] settings will not persist (DataStore unavailable):", result)
	end
end

local cache: { [Player]: { [string]: any } } = {}
local dirty: { [Player]: boolean } = {}
local persistent: { [Player]: boolean } = {}

local function sanitize(input: any): { [string]: any }
	local out = {}
	if type(input) ~= "table" then
		return out
	end
	for key, default in pairs(MenuConfig.DefaultSettings) do
		local v = input[key]
		if typeof(v) == typeof(default) then
			if type(v) == "number" then
				if v == v then -- not NaN
					out[key] = math.clamp(v, 0, 1)
				end
			elseif key == "VFXQuality" then
				if table.find(MenuConfig.VFXQualities, v) then
					out[key] = v
				end
			elseif key == "SceneDetail" then
				if table.find(MenuConfig.SceneDetails, v) then
					out[key] = v
				end
			else
				out[key] = v
			end
		end
	end
	return out
end

local function save(player: Player)
	if not store or not persistent[player] or not dirty[player] or not cache[player] then
		return
	end
	dirty[player] = false
	local data = cache[player]
	local ok, err = pcall(function()
		store:SetAsync("u_" .. player.UserId, data)
	end)
	if not ok then
		warn("[GameManager] settings save failed:", err)
	end
end

-- Returns (settings, persistent). persistent is false when the DataStore is
-- unreachable (e.g. Studio without API access), so the client can say so honestly.
LoadSettings.OnServerInvoke = function(player: Player)
	if cache[player] then
		return cache[player], persistent[player] == true
	end
	local data = {}
	persistent[player] = false
	if store then
		local ok, result = pcall(function()
			return store:GetAsync("u_" .. player.UserId)
		end)
		if ok then
			data = sanitize(result)
			persistent[player] = true
		else
			warn("[GameManager] settings load failed:", result)
		end
	end
	cache[player] = data
	return data, persistent[player]
end

SaveSettings.OnServerEvent:Connect(function(player: Player, payload: any)
	local clean = sanitize(payload)
	local merged = cache[player] or {}
	for k, v in pairs(clean) do
		merged[k] = v
	end
	cache[player] = merged
	dirty[player] = true
end)

-- Throttled background saves.
task.spawn(function()
	while true do
		task.wait(15)
		for _, player in ipairs(Players:GetPlayers()) do
			if dirty[player] then
				task.spawn(save, player)
			end
		end
	end
end)

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

local function onPlayerAdded(player: Player)
	states[player] = PlayerState.Menu
	player:SetAttribute("InGameplay", false)
	player.CharacterAdded:Connect(function(character)
		onCharacterAdded(player, character)
	end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do
	onPlayerAdded(p)
end

Players.PlayerRemoving:Connect(function(player)
	save(player)
	states[player] = nil
	lastRequest[player] = nil
	cache[player] = nil
	dirty[player] = nil
	persistent[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		save(player)
	end
end)
