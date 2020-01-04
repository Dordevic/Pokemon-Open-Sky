#70925035
begin
  module PBStatuses
    SLEEP       = 1
    POISON      = 2
    BURN        = 3
    PARALYSIS   = 4
    FROZEN      = 5
    WET         = 6
    RASH        = 7
    BRUISED     = 8
    DIRTY       = 9
    UNBALANCED  = 10
    MINDCONTROL = 11
    STUNG       = 12 
    PETRIFY     = 13
    FEAR        = 14
    AWAKENED    = 15
    BLINDED     = 16
    SHRAPNEL    = 17
    ENCHANTED   = 18
    BLEEDING    = 19
    
    def PBStatuses.getName(id)
      names = [
         _INTL("healthy"),
         _INTL("asleep"),
         _INTL("poisoned"),
         _INTL("burned"),
         _INTL("paralyzed"),
         _INTL("frozen"),
         _INTL("wet"),
         _INTL("affected by a rash"),
         _INTL("dirty"),
         _INTL("unbalanced"),
         _INTL("out of its mind"),
         _INTL("stung"),
         _INTL("petrified"),
         _INTL("afraid"),
         _INTL("awakened"),
         _INTL("blinded"),
         _INTL("covered in sharpnel"),
         _INTL("enchanted"),
         _INTL("bleeding")
      ]
      return names[id]
    end  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end