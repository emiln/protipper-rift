local a = Protipper.API
local cd = 0.75

Protipper.RequiredAbilities["Huntsman"] = {
	"Ace Shot"
}

Protipper.Priorities["Huntsman"] = {
	{	
		"Animalism",
		function()
			return (a.Cooldown("Animalism") < cd)
				and (a.RemainingTime("player.pet", "Feral Aggression") > 0)
		end
	},

	{
		"Feral Aggression",
		function()
			return (a.Cooldown("Feral Aggression") < cd) and (a.ComboPoints() == 5)
		end
	},

	{
		"Twin Shot",
		function()
			return a.ComboPoints() == 5
		end
	},

	{
		"Splinter Shot",
		function()
			return a.RemainingTime("player.target", "Splinter Shot") < cd
		end
	},

	{
		"Shadow Fire",
		function()
			return (a.Cooldown("Shadow Fire") < cd) and (a.ComboPoints() <= 3)
		end
	},

	{
		"Ace Shot",
		function()
			return a.RemainingTime("player.target", "Ace Shot") < 1
		end
	},

	{
		"Shadow Fire",
		function()
			return a.RemainingTime("player", "Shadow Fire") < cd
		end
	},

	{
		"Ace Shot",
		function()
			return true
		end
	}
}