#11045744
begin
  module PBWeather
    SUNNYDAY        = 1
    RAINDANCE       = 2
    SANDSTORM       = 3
    HAIL            = 4
    HARSHSUN        = 5
    HEAVYRAIN       = 6
    STRONGWINDS     = 7
    PLAGUE          = 9 
    ECLIPSE         = 10
    THUNDERSTORM    = 11
    ANCESTRALAURORA = 12
    MAGICWIND       = 13
    FERALBREEZE     = 14
    CROWD           = 15
    TORNADO         = 16
    SCARYFOG        = 17
    POLLENSEASON    = 18
    TREMORS         = 19
    STRONGBLIZZARD  = 20
    ACIDRAIN        = 21
    STARRYNIGHT     = 22
    METEORSHOWER    = 23
    MAGNETICSTORM   = 24  
    # Shadow Sky is weather 8
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end