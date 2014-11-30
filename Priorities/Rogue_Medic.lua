local a = Protipper.API
local cd = 0.75

Protipper.RequiredAbilities["Medic"] = {
	"Emergency Response"
}

Protipper.Priorities["Medic"] = {
	{	
		"Maintenance Therapy",
		function()
			return a.ComboPoints() == 5
		end
	},

	{
		"Causal Treatment",
		function()
			return true
		end
	}
}