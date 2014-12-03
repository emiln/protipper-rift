Protipper = {	
	Abilities = {},
	ActiveSpec = nil,
	Priorities = {},
	Settings = {
		Alpha = 0.9,
		Border = {
			R = 0,
			G = 0,
			B = 0,
			Width = 2
		},
		Font = {
			Family = "",
			Size = 11
		},
		Height = 64,
		Width = 64,
		X = 0,
		Y = 0
	},
	State = {},
	RequiredAbilities = {},
	UI = {
		Text = nil,
		Texture = nil,
		Wrap = nil
	}
}

Protipper_Persistent = {
	X = 10,
	Y = 10
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
	local entry = Protipper.Abilities[ability]
	if entry == nil then
		return nil
	end
	return Inspect.Ability.New.Detail(entry)
end

---------------
-- GUI stuff --
---------------

local function CreateMainFrame()
	local s = Protipper.Settings
	local pp = Protipper_Persistent
	if pp == nil then
		pp = {X = 10, Y = 10}
	end

	local context = UI.CreateContext("Protipper")
	local wrap = UI.CreateFrame("Frame", "Protipper Wrapper", context)
	local texture = UI.CreateFrame("Texture", "Protipper Ability", wrap)
	local text = UI.CreateFrame("Text", "Protipper Text", wrap)
	Protipper.UI.Texture = texture
	Protipper.UI.Text = text
	Protipper.UI.Wrap = wrap

	texture:SetVisible(true)
	texture:SetHeight(s.Height - 2 * s.Border.Width)
	texture:SetWidth(s.Width - 2 * s.Border.Width)
	texture:SetPoint("TOPLEFT", wrap, "TOPLEFT", s.Border.Width, s.Border.Width)
	texture:SetAlpha(s.Alpha)

	text:SetVisible(true)
	text:SetBackgroundColor(s.Border.R, s.Border.G, s.Border.B, s.Alpha)
	text:SetPoint("TOPCENTER", wrap, "BOTTOMCENTER", 0, s.Border.Width)
	text:SetText("Loading...")
	text:SetFontColor(1, 1, 1)
	text:SetFontSize(s.Font.Size)

	wrap:SetVisible(true)
	wrap:SetHeight(s.Height)
	wrap:SetWidth(s.Width)
	wrap:SetBackgroundColor(s.Border.R, s.Border.G, s.Border.B, s.Alpha)
	local x = 
	wrap:SetPoint("TOPLEFT", UIParent, "TOPLEFT", pp.X, pp.Y)

	function wrap.Event:LeftDown()
		local mouse = Inspect.Mouse()
		wrap:SetAlpha(s.Alpha * 0.7)
		Protipper.State.MouseDown = true
		Protipper.State.StartX = Protipper.UI.Wrap:GetLeft()
		Protipper.State.StartY = Protipper.UI.Wrap:GetTop()
		Protipper.State.MouseStartX = mouse.x
		Protipper.State.MouseStartY = mouse.y
	end

	function wrap.Event:MouseMove()
		if Protipper.State.MouseDown then
			local mouse = Inspect.Mouse()
			local x = mouse.x - Protipper.State.MouseStartX +
				Protipper.State.StartX
			local y = mouse.y - Protipper.State.MouseStartY +
				Protipper.State.StartY
			Protipper.UI.Wrap:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
			pp.X = x
			pp.Y = y
		end
	end

	function wrap.Event:LeftUp()
		wrap:SetAlpha(s.Alpha)
		Protipper.State.MouseDown = false
	end
end

function Protipper.SetTexture(icon)
	Protipper.UI.Texture:SetTexture("Rift", icon)
end

function Protipper.SetText(name)
	Protipper.UI.Text:SetText(name)
end

function Protipper.UpdateTexture()
	if Protipper.Busy then return end

	Protipper.Busy = true
	local suggestion = Abi(Protipper.Suggestion())
	if not (suggestion == nil) then
		Protipper.SetTexture(suggestion.icon)
		Protipper.SetText(suggestion.name)
	end
	Protipper.Busy = false
end

--------------------
-- Initialization --
--------------------

function Protipper.Init(addon)
	if addon == "Protipper" then
		-- Initialize the UI
		Protipper.UpdateActiveSpec()
		Protipper.Frame = CreateMainFrame()

		table.insert(Event.Unit.Detail.Role, {Protipper.UpdateActiveSpec, "Protipper", "Populate ability list"})
		table.insert(Event.Ability.New.Add, {Protipper.UpdateActiveSpec, "Protipper", "Populate ability list"})

		table.insert(Event.Unit.Detail.Energy, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
		table.insert(Event.Unit.Detail.Health, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
		table.insert(Event.Unit.Detail.Mana, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
		table.insert(Event.Unit.Detail.Power, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
		table.insert(Event.Unit.Detail.Vitality, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
		table.insert(Event.Ability.New.Usable.True, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
		table.insert(Event.Ability.New.Usable.False, {Protipper.UpdateTexture, "Protipper", "Update Texture"})
	end
end

function Protipper.PopulateAbilityList()
	print("Populating ability list")
	Protipper.Abilities = {}
	local abilities = Inspect.Ability.New.List()

	if abilities == nil then
		return
	end

	for index in pairs(abilities) do
		ability = Inspect.Ability.New.Detail(index)
		Protipper.Abilities[ability.name] = index
	end
end

function Protipper.UpdateActiveSpec()
	Protipper.ActiveSpec = Protipper.GetActiveSpec()
end

--------------------
-- Core functions --
--------------------

Protipper.Suggestion = function()
	local spec = Protipper.Priorities[Protipper.ActiveSpec]
	if spec == nil then
		spec = {}
	end

	for index, ability in ipairs(spec) do
		local name = ability[1]
		local valid = ability[2]
		if valid() then
			return name
		end
	end
	return nil
end

Protipper.GetActiveSpec = function()
	Protipper.PopulateAbilityList()
	for spec, abilities in pairs(Protipper.RequiredAbilities) do
		local allTrue = true
		for _, name in pairs(abilities) do
			if not Abi(name) then
				allTrue = false
			end
		end

		if allTrue then
			return spec
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

table.insert(Event.Addon.SavedVariables.Load.End, {Protipper.Init, "Protipper", "Initital Setup"})
table.insert(Command.Slash.Register("pt"), {Protipper.API.HasBuff, "Protipper", "Slash Command"})