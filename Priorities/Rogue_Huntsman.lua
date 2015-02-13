local cd = 0.75

Protipper.RequiredAbilities["Ranger"] = {
   "Ace Shot"
}

Protipper.Priorities["Ranger"] = {
   --[[
      Self-buffs. There is no reason why these should not all be active.
      Note that infinite duration translates into a RemainingTime of -1.
   ]]
   {
      "Virulent Poison",
      function(a)
         return (a.RemainingTime("player", "Virulent Poison") < cd)
      end
   },

   {
      "Leeching Poison",
      function(a)
         return (a.RemainingTime("player", "Leeching Poison") < cd)
      end
   },

   {
      "Feral Instincts",
      function(a)
         return not (a.RemainingTime("player", "Feral Instincts") == -1)
      end
   },

   {
      "Ravenous Instincts",
      function(a)
         return not (a.RemainingTime("player", "Ravenous Instincts") == -1)
      end
   },

   {
      "Spirit of the Wilderness",
      function(a)
         return (a.RemainingTime("player.pet",
                                 "Spirit of the Wilderness") < cd)
      end
   },

   --[[
      Actual priority list. This is based on the following to the best of
      my ability (excluding the line break):
      
      http://forums.riftgame.com/game-discussions/rift-guides-strategies/
      class-guides/rogue-guides/357047-61-ranger-dps-guide.html
   ]]

   -- Animalism should always be used right after Feral Aggression.
   {    
      "Animalism",
      function(a)
         return (a.Cooldown("Animalism") < cd)
            and (a.RemainingTime("player.pet", "Feral Aggression") > 0)
      end
   },

   --[[ Using Feral Aggression triggers Animalism. This is your main DPS
      cooldown and should be used whenever ready. ]]
   {
      "Feral Aggression",
      function(a)
         return (a.Cooldown("Feral Aggression") < cd)
            and (a.ComboPoints() == 5)
      end
   },

   --[[ Head Shot is tricky. You want Bestial Fury active at all times,
      but you don't want to "waste" your Animalism+Feral Aggression time
      on casting it. My approach is to demand that Animalism and
      Feral Aggression are both on cooldown and that they will become
      ready in [5;15] seconds. To see the sense of this, consider the
      following:

Head Shot-----|                   |-----Head Shot-----|
              |-----Head Shot-----|
       |-CD-|    |-CD-|    |-CD-|    |-CD-|
       |----|----|----|----|----|----|----|----|
       0         30s       60s       90s       120s

      The intention is to cast Head Shot during the cooldown and inactivity
      of the high DPS cooldowns.]]
   {
      "Head Shot",
      function(a)
         return ((a.ComboPoints() == 5)
               and (a.RemainingTime("player", "Bestial Fury") < 30)
               and (a.Cooldown("Feral Aggression") < 15))
      end
   },

   {
      "Twin Shot",
      function(a)
         return a.ComboPoints() == 5
      end
   },

   {
      "Ace Shot",
      function(a)
         return a.RemainingTime("player.target", "Ace Shot") < cd
      end
   },

   {
      "Shadow Fire",
      function(a)
         return a.Cooldown("Shadow Fire") < cd
            and a.ComboPoints() <= 3
            and a.RemainingTime("player", "Animalism") > 0
      end
   },

   {
      "Splinter Shot",
      function(a)
         return a.RemainingTime("player.target", "Splinter Shot") < cd
      end
   },

   {
      "Quick Shot",
      function(a)
         return true
      end
   }
}
