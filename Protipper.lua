Protipper = {	
	Abilities = {},
	Priorities = {},
	Settings = {
		Alpha = 0.5,
		Height = 100,
		Width = 100
	},
	UI = {
		Texture = nil
	}
}

----------------------
-- Helper functions --
----------------------

local Any = function(items, predicate)
	if items == nil then
		return false
	end
	for i in pairs(items) do
		if predicate(i) then
			return true
		end
	end
	return false
end

local Some = function(items, predicate)
	if items == nil then
		return nil
	end
	for i in pairs(items) do
		if predicate(i) then
			return i
		end
	end
	return nil
end

local Abi = function(ability)
	return Inspect.Ability.New.Detail(Protipper.Abilities[ability])
end

---------------
-- GUI stuff --
---------------

local function CreateMainFrame()
	local s = Protipper.Settings

	local context = UI.CreateContext("Protipper")
	local wrap = UI.CreateFrame("Frame", "Protipper Wrapper", context)
	local texture = UI.CreateFrame("Texture", "Protipper Ability", wrap)
	Protipper.UI.Texture = texture

	texture:SetVisible(true)
	texture:SetHeight(s.Height - 10)
	texture:SetWidth(s.Width - 10)

	wrap:SetVisible(true)
	wrap:SetHeight(s.Height)
	wrap:SetWidth(s.Width)
	wrap:SetBackgroundColor(0,0,0,s.Alpha)
end

function Protipper.SetTexture(icon)
	Protipper.UI.Texture:SetTexture("Rift", icon)
end

function Protipper.UpdateTexture()
	if Protipper.Busy then return end

	Protipper.Busy = true
	Protipper.SetTexture(Abi(Protipper.Suggestion()).icon)
	Protipper.Busy = false
end

--------------------
-- Initialization --
--------------------

function Protipper.Init(addon)
	if addon == "Protipper" then
		-- Initialize the UI
		Protipper.Frame = CreateMainFrame()
	end
end

function Protipper.PopulateAbilityList()
	print("Populating ability list")
	for index in pairs(Inspect.Ability.New.List()) do
		ability = Inspect.Ability.New.Detail(index)
		Protipper.Abilities[ability.name] = index
	end
end

--------------------
-- Core functions --
--------------------

Protipper.Suggestion = function()
	for index,ability in ipairs(Protipper.Priorities["Huntsman"]) do
		local name = ability[1]
		local valid = ability[2]
		if valid() then
			return name
		end
	end
	return nil
end

---------------------
-- "API" functions --
---------------------

local GetBuff = function(unit, buffName)
	buffs = Inspect.Buff.List(unit)
	if buffs == nil then return nil end
	for i in pairs(buffs) do
		buff = Inspect.Buff.Detail(unit, i)
		if buff.name == buffName then
			return buff
		end
	end
	return nil
end

Protipper.API = {}
local p = Protipper.API

p.RemainingTime = function(unit, buffName)
	buff = GetBuff(unit, buffName)
	if buff == nil or buff.remaining == nil then return 0 end

	return buff.remaining
end

p.ComboPoints = function(min, max)
	return Inspect.Unit.Detail("player").combo
end

p.Cooldown = function(ability)
	local cooldown = Abi(ability).currentCooldownRemaining
	if cooldown == nil then
		return 0
	else
		return cooldown
	end
end

---------------------
-- Register Events --
---------------------

table.insert(Event.Addon.Load.End, {Protipper.Init, "Protipper", "Initital Setup"})
table.insert(Command.Slash.Register("pt"), {Protipper.API.HasBuff, "Protipper", "Slash Command"})
table.insert(Event.Unit.Detail.Role, {Protipper.PopulateAbilityList, "Protipper", "Populate ability list"})
table.insert(Event.Ability.New.Add, {Protipper.PopulateAbilityList, "Protipper", "Populate ability list"})

table.insert(Event.Unit.Detail.Energy, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
table.insert(Event.Unit.Detail.Health, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
table.insert(Event.Unit.Detail.Mana, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
table.insert(Event.Unit.Detail.Power, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
table.insert(Event.Unit.Detail.Vitality, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
table.insert(Event.Ability.New.Usable.True, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
table.insert(Event.Ability.New.Usable.False, {Protipper.UpdateTexture, "Protipper", "Update Texture"})