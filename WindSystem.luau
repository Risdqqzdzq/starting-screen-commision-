-- Client-side decorative wind. One shared source of truth for foliage sway, cloth,
-- terrain grass (workspace.GlobalWind), leaves and particles. Gusts are triggered
-- by the ambient event scheduler through WindSystem.gust().

local VFXConfig = require(script.Parent.VFXConfig)

local WindSystem = {}

local cfg = VFXConfig.Wind
local gustStart = -math.huge
local gustDir = cfg.Direction
local gustEvent = Instance.new("BindableEvent")

WindSystem.GustStarted = gustEvent.Event -- (direction: Vector3, duration: number)

function WindSystem.direction(): Vector3
	return cfg.Direction
end

-- 0..1 envelope of the current gust (smooth rise, longer fall).
function WindSystem.gustAmount(now: number?): number
	local t = (now or os.clock()) - gustStart
	if t < 0 or t > cfg.GustDuration then
		return 0
	end
	local x = t / cfg.GustDuration
	if x < 0.25 then
		local k = x / 0.25
		return k * k * (3 - 2 * k)
	end
	local k = 1 - (x - 0.25) / 0.75
	return k * k
end

-- Overall strength: gentle breathing base plus the gust envelope.
function WindSystem.strength(now: number?): number
	local t = now or os.clock()
	local breathe = 0.75 + 0.25 * math.sin(t * 0.37) * math.sin(t * 0.11 + 1.3)
	return cfg.BaseStrength * breathe + cfg.GustStrength * WindSystem.gustAmount(t)
end

function WindSystem.vector(now: number?): Vector3
	return gustDir * WindSystem.strength(now)
end

function WindSystem.isGusting(): boolean
	return WindSystem.gustAmount() > 0
end

function WindSystem.gust()
	if WindSystem.isGusting() then
		return
	end
	local jitter = math.rad(math.random(-20, 20))
	gustDir = (CFrame.Angles(0, jitter, 0) * cfg.Direction).Unit
	gustStart = os.clock()
	gustEvent:Fire(gustDir, cfg.GustDuration)
end

return WindSystem
