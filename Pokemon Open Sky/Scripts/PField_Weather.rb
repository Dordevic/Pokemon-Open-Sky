begin
  module PBFieldWeather
    None            = 0 # None must be 0 (preset RMXP weather)
    Rain            = 1 # Rain must be 1 (preset RMXP weather)
    Storm           = 2 # Storm must be 2 (preset RMXP weather)
    Snow            = 3 # Snow must be 3 (preset RMXP weather)
    Blizzard        = 4
    Sandstorm       = 5
    HeavyRain       = 6
    Sun = Sunny     = 7
    Plague          = 8
    Eclipse         = 9
    AncestralAurora = 10
    MagicWind       = 11
    FeralBreeze     = 12
    Crowd           = 13
    Tornado         = 14
    ScaryFog        = 15
    PollenSeason    = 16
    Tremors         = 17 
    AcidRain        = 18
    StarryNight     = 19
    MeteorShower    = 20
    MagneticStorm   = 21

    def PBFieldWeather.maxValue; 21; end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end



module RPG
  class Weather
    attr_reader :type
    attr_reader :max
    attr_reader :ox
    attr_reader :oy

    def prepareSandstormBitmaps
      if !@sandstormBitmap1
        bmwidth  = 200
        bmheight = 200
        @sandstormBitmap1 = Bitmap.new(bmwidth,bmheight)
        @sandstormBitmap2 = Bitmap.new(bmwidth,bmheight)
        sandstormColors = [
           Color.new(31*8,28*8,17*8),
           Color.new(23*8,16*8,9*8),
           Color.new(29*8,24*8,15*8),
           Color.new(26*8,20*8,12*8),
           Color.new(20*8,13*8,6*8),
           Color.new(31*8,30*8,20*8),
           Color.new(27*8,25*8,20*8)
        ]
        for i in 0..540
          @sandstormBitmap1.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,sandstormColors[rand(7)])
          @sandstormBitmap2.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,sandstormColors[rand(7)])
        end
        @weatherTypes[PBFieldWeather::Sandstorm][0][0] = @sandstormBitmap1
        @weatherTypes[PBFieldWeather::Sandstorm][0][1] = @sandstormBitmap2
      end
    end
    
    def preparePlagueBitmaps
      if !@plagueBitmap1
        bmwidth  = 200
        bmheight = 200
        @plagueBitmap1 = Bitmap.new(bmwidth,bmheight)
        @plagueBitmap2 = Bitmap.new(bmwidth,bmheight)
        plagueColors = [
           Color.new(6*8,26*8,6*8),
           Color.new(26*8,26*8,0*8),
           Color.new(19*8,26*8,0*8),
           Color.new(13*8,19*8,0*8),
           Color.new(0*8,16*8,0*8),
           Color.new(0*8,13*8,0*8),
           Color.new(0*8,6*8,0*8)
        ]
        for i in 0..540
          @plagueBitmap1.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,plagueColors[rand(7)])
          @plagueBitmap2.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,plagueColors[rand(7)])
        end
        @weatherTypes[PBFieldWeather::Plague][0][0] = @plagueBitmap1
        @weatherTypes[PBFieldWeather::Plague][0][1] = @plagueBitmap2
      end
    end
    
    def prepareMagicWindBitmaps
      if !@magicWindBitmap1
        bmwidth  = 200
        bmheight = 200
        @magicWindBitmap1 = Bitmap.new(bmwidth,bmheight)
        @magicWindBitmap2 = Bitmap.new(bmwidth,bmheight)
        magicWindColors = [
           Color.new(32*8,26*8,32*8),
           Color.new(32*8,0*8,32*8),
           Color.new(32*8,13*8,26*8),
           Color.new(32*8,19*8,14*8),
           Color.new(26*8,16*8,32*8),
           Color.new(19*8,13*8,32*8),
           Color.new(26*8,6*8,19*8)
        ]
        for i in 0..540
          @magicWindBitmap1.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,magicWindColors[rand(7)])
          @magicWindBitmap2.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,magicWindColors[rand(7)])
        end
        @weatherTypes[PBFieldWeather::MagicWind][0][0] = @magicWindBitmap1
        @weatherTypes[PBFieldWeather::MagicWind][0][1] = @magicWindBitmap2
      end
    end
    
    def prepareFeralBreezeBitmaps
      if !@feralBreezeBitmap1
        bmwidth  = 1000
        bmheight = 1000
        @feralBreezeBitmap1 = Bitmap.new(bmwidth,bmheight)
        @feralBreezeBitmap2 = Bitmap.new(bmwidth,bmheight)
        feralBreezeColors = [
           Color.new(32*8,6*8,0*8),
           Color.new(26*8,0*8*8,0*8),
           Color.new(32*8,26*8,0*8),
           Color.new(32*8,32*8,32*8)
        ]
        for i in 0..270
          @feralBreezeBitmap1.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*4,4,4,feralBreezeColors[rand(4)])
          @feralBreezeBitmap2.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,feralBreezeColors[rand(4)])
        end
        @weatherTypes[PBFieldWeather::FeralBreeze][0][0] = @feralBreezeBitmap1
        @weatherTypes[PBFieldWeather::FeralBreeze][0][1] = @feralBreezeBitmap2
      end
    end

    def prepareCrowdBitmaps
      if !@crowdBitmap1
        bmwidth  = 10
        bmheight = 10
        @crowdBitmap1 = Bitmap.new(bmwidth,bmheight)
        @crowdBitmap2 = Bitmap.new(bmwidth,bmheight)
        @crowdBitmap3 = Bitmap.new(bmwidth,bmheight)
        crowdcolor1 = Color.new(255, 153, 102, 255)
        crowdcolor2 = Color.new(255, 255, 153, 255)
        crowdcolor3 = Color.new(204, 236, 255, 255)
        @crowdBitmap1.fill_rect(4,2,2,2,crowdcolor1)
        @crowdBitmap1.fill_rect(2,4,6,2,crowdcolor1)
        @crowdBitmap1.fill_rect(4,6,2,2,crowdcolor1)
        @crowdBitmap2.fill_rect(2,0,4,2,crowdcolor2)
        @crowdBitmap2.fill_rect(0,2,8,4,crowdcolor2)
        @crowdBitmap2.fill_rect(2,6,4,2,crowdcolor2)
        @crowdBitmap3.fill_rect(4,0,2,2,crowdcolor3)
        @crowdBitmap3.fill_rect(2,2,6,2,crowdcolor3)
        @crowdBitmap3.fill_rect(0,4,10,2,crowdcolor3)
        @crowdBitmap3.fill_rect(2,6,6,2,crowdcolor3)
        @crowdBitmap3.fill_rect(4,8,2,2,crowdcolor3)
        @weatherTypes[PBFieldWeather::Crowd][0][0] = @crowdBitmap1
        @weatherTypes[PBFieldWeather::Crowd][0][1] = @crowdBitmap2
        @weatherTypes[PBFieldWeather::Crowd][0][2] = @crowdBitmap3
      end
    end

    def prepareSnowBitmaps
      if !@snowBitmap1
        bmwidth  = 10
        bmheight = 10
        @snowBitmap1 = Bitmap.new(bmwidth,bmheight)
        @snowBitmap2 = Bitmap.new(bmwidth,bmheight)
        @snowBitmap3 = Bitmap.new(bmwidth,bmheight)
        snowcolor = Color.new(224, 232, 240, 255)
        @snowBitmap1.fill_rect(4,2,2,2,snowcolor)
        @snowBitmap1.fill_rect(2,4,6,2,snowcolor)
        @snowBitmap1.fill_rect(4,6,2,2,snowcolor)
        @snowBitmap2.fill_rect(2,0,4,2,snowcolor)
        @snowBitmap2.fill_rect(0,2,8,4,snowcolor)
        @snowBitmap2.fill_rect(2,6,4,2,snowcolor)
        @snowBitmap3.fill_rect(4,0,2,2,snowcolor)
        @snowBitmap3.fill_rect(2,2,6,2,snowcolor)
        @snowBitmap3.fill_rect(0,4,10,2,snowcolor)
        @snowBitmap3.fill_rect(2,6,6,2,snowcolor)
        @snowBitmap3.fill_rect(4,8,2,2,snowcolor)
        @weatherTypes[PBFieldWeather::Snow][0][0] = @snowBitmap1
        @weatherTypes[PBFieldWeather::Snow][0][1] = @snowBitmap2
        @weatherTypes[PBFieldWeather::Snow][0][2] = @snowBitmap3
      end
    end

    def prepareAuroraBitmaps
      if !@auroraBitmap1
        bmwidth  = 10
        bmheight = 10
        @auroraBitmap1 = Bitmap.new(bmwidth,bmheight)
        @auroraBitmap2 = Bitmap.new(bmwidth,bmheight)
        @auroraBitmap3 = Bitmap.new(bmwidth,bmheight)
        auroracolor1 = Color.new(255, 255, 255, 255)
        auroracolor2= Color.new(0, 255, 255, 255)
        auroracolor3 = Color.new(0, 255, 0, 255)
        @auroraBitmap1.fill_rect(4,2,2,2,auroracolor1)
        @auroraBitmap1.fill_rect(2,4,6,2,auroracolor1)
        @auroraBitmap1.fill_rect(4,6,2,2,auroracolor1)
        @auroraBitmap2.fill_rect(2,0,4,2,auroracolor2)
        @auroraBitmap2.fill_rect(0,2,8,4,auroracolor2)
        @auroraBitmap2.fill_rect(2,6,4,2,auroracolor2)
        @auroraBitmap3.fill_rect(4,0,2,2,auroracolor3)
        @auroraBitmap3.fill_rect(2,2,6,2,auroracolor3)
        @auroraBitmap3.fill_rect(0,4,10,2,auroracolor3)
        @auroraBitmap3.fill_rect(2,6,6,2,auroracolor3)
        @auroraBitmap3.fill_rect(4,8,2,2,auroracolor3)
        @weatherTypes[PBFieldWeather::AncestralAurora][0][0] = @auroraBitmap1
        @weatherTypes[PBFieldWeather::AncestralAurora][0][1] = @auroraBitmap2
        @weatherTypes[PBFieldWeather::AncestralAurora][0][2] = @auroraBitmap3
      end
    end

    def prepareBlizzardBitmaps
      if !@blizzardBitmap1
        bmwidth = 10; bmheight = 10
        @blizzardBitmap1 = Bitmap.new(bmwidth,bmheight)
        @blizzardBitmap2 = Bitmap.new(bmwidth,bmheight)
        bmwidth = 200; bmheight = 200
        @blizzardBitmap3 = Bitmap.new(bmwidth,bmheight)
        @blizzardBitmap4 = Bitmap.new(bmwidth,bmheight)
        snowcolor = Color.new(224,232,240,255)
        @blizzardBitmap1.fill_rect(2,0,4,2,snowcolor)
        @blizzardBitmap1.fill_rect(0,2,8,4,snowcolor)
        @blizzardBitmap1.fill_rect(2,6,4,2,snowcolor)
        @blizzardBitmap2.fill_rect(4,0,2,2,snowcolor)
        @blizzardBitmap2.fill_rect(2,2,6,2,snowcolor)
        @blizzardBitmap2.fill_rect(0,4,10,2,snowcolor)
        @blizzardBitmap2.fill_rect(2,6,6,2,snowcolor)
        @blizzardBitmap2.fill_rect(4,8,2,2,snowcolor)
        for i in 0..540
          @blizzardBitmap3.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,snowcolor)
          @blizzardBitmap4.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,snowcolor)
        end
        @weatherTypes[PBFieldWeather::Blizzard][0][0] = @blizzardBitmap1
        @weatherTypes[PBFieldWeather::Blizzard][0][1] = @blizzardBitmap2
        @weatherTypes[PBFieldWeather::Blizzard][0][2] = @blizzardBitmap3 # Tripled to make them 3x as common
        @weatherTypes[PBFieldWeather::Blizzard][0][3] = @blizzardBitmap3
        @weatherTypes[PBFieldWeather::Blizzard][0][4] = @blizzardBitmap3
        @weatherTypes[PBFieldWeather::Blizzard][0][5] = @blizzardBitmap4 # Tripled to make them 3x as common
        @weatherTypes[PBFieldWeather::Blizzard][0][6] = @blizzardBitmap4
        @weatherTypes[PBFieldWeather::Blizzard][0][7] = @blizzardBitmap4
      end
    end

    def prepareTornadoBitmaps
      if !@tornadoBitmap1
        bmwidth  = 200
        bmheight = 200
        @tornadoBitmap1 = Bitmap.new(bmwidth,bmheight)
        @tornadoBitmap2 = Bitmap.new(bmwidth,bmheight)
        tornadoColors = [
           Color.new(204,236,255),
           Color.new(255,255,255),
           Color.new(234,234,234),
           Color.new(192,192,192),
           Color.new(192,192,192),
           Color.new(150,150,150),
           Color.new(120,120,120)
        ]
        for i in 0..540
          @tornadoBitmap1.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,tornadoColors[rand(6)])
          @tornadoBitmap2.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,tornadoColors[rand(6)])
        end
        @weatherTypes[PBFieldWeather::Tornado][0][0] = @tornadoBitmap1
        @weatherTypes[PBFieldWeather::Tornado][0][1] = @tornadoBitmap2
      end
    end
    
    def preparePollenSeasonBitmaps
      if !@pollenSeasonBitmap1
        bmwidth  = 200
        bmheight = 200
        @pollenSeasonBitmap1 = Bitmap.new(bmwidth,bmheight)
        @pollenSeasonBitmap2 = Bitmap.new(bmwidth,bmheight)
        pollenSeasonColors = [
           Color.new(255,204,0),
           Color.new(255,255,102),
           Color.new(255,255,0),
           Color.new(255,255,153),
           Color.new(255,255,0),
           Color.new(204,204,0),
           Color.new(153,208,0)
        ]
        for i in 0..540
          @pollenSeasonBitmap1.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,pollenSeasonColors[rand(7)])
          @pollenSeasonBitmap2.fill_rect(rand(bmwidth/2)*2,rand(bmheight/2)*2,2,2,pollenSeasonColors[rand(7)])
        end
        @weatherTypes[PBFieldWeather::PollenSeason][0][0] = @pollenSeasonBitmap1
        @weatherTypes[PBFieldWeather::PollenSeason][0][1] = @pollenSeasonBitmap2
      end
    end
    
    def prepareMeteorBitmaps
      if !@metorBitmap1
        bmwidth  = 48
        bmheight = 48
        @meteorBitmap1 = Bitmap.new(bmwidth,bmheight)
        @meteorBitmap2 = Bitmap.new(bmwidth,bmheight)
        @meteorBitmap3 = Bitmap.new(bmwidth,bmheight)
        @meteorBitmap4 = Bitmap.new(bmwidth,bmheight)
        meteorcolor1 = Color.new(255, 204, 0, 255)
        meteorcolor2= Color.new(150, 150, 150, 255)
        meteorcolor3 = Color.new(120, 120, 120, 255)
        @meteorBitmap1.fill_rect(38,2,2,6,meteorcolor1)
        @meteorBitmap1.fill_rect(36,6,2,6,meteorcolor1)
        @meteorBitmap1.fill_rect(34,8,2,8,meteorcolor1)
        @meteorBitmap1.fill_rect(30,10,4,2,meteorcolor1)
        @meteorBitmap1.fill_rect(24,12,10,10,meteorcolor1)
        @meteorBitmap1.fill_rect(16,14,16,14,meteorcolor1)
        @meteorBitmap1.fill_rect(12,16,18,18,meteorcolor1)
        @meteorBitmap1.fill_rect(2,22,24,20,meteorcolor2)
        @meteorBitmap1.fill_rect(0,26,2,12,meteorcolor2)
        @meteorBitmap1.fill_rect(26,26,2,12,meteorcolor2)
        @meteorBitmap1.fill_rect(4,20,20,2,meteorcolor2)
        @meteorBitmap1.fill_rect(4,42,20,2,meteorcolor2)
        @meteorBitmap1.fill_rect(8,18,12,2,meteorcolor2)
        @meteorBitmap1.fill_rect(8,44,12,2,meteorcolor2)
        @meteorBitmap1.fill_rect(10,22,2,2,meteorcolor3)
        @meteorBitmap1.fill_rect(8,28,4,4,meteorcolor3)
        @meteorBitmap1.fill_rect(6,36,2,4,meteorcolor3)
        @meteorBitmap1.fill_rect(8,38,2,2,meteorcolor3)
        @meteorBitmap1.fill_rect(2,30,2,4,meteorcolor3)
        @meteorBitmap1.fill_rect(14,34,2,2,meteorcolor3)
        @meteorBitmap1.fill_rect(16,32,2,2,meteorcolor3)
        @meteorBitmap1.fill_rect(16,34,4,4,meteorcolor3)
        @meteorBitmap1.fill_rect(20,28,2,2,meteorcolor3)
        @meteorBitmap1.fill_rect(16,22,2,4,meteorcolor1)
        @meteorBitmap1.fill_rect(18,24,2,2,meteorcolor1)
        @meteorBitmap1.fill_rect(18,40,4,2,meteorcolor3)
        @meteorBitmap1.fill_rect(22,34,2,6,meteorcolor3)
        @meteorBitmap1.fill_rect(10,34,2,2,meteorcolor1)
        @meteorBitmap1.fill_rect(4,24,2,2,meteorcolor1)
        @meteorBitmap2.fill_rect(0,4,4,2,meteorcolor1)
        @meteorBitmap2.fill_rect(4,2,6,2,meteorcolor1)
        @meteorBitmap3.fill_rect(0,8,2,4,meteorcolor1)
        @meteorBitmap3.fill_rect(2,2,6,2,meteorcolor1)
        @meteorBitmap4.fill_rect(2,0,2,2,meteorcolor3)
        @meteorBitmap4.fill_rect(0,2,6,2,meteorcolor3)
        @meteorBitmap4.fill_rect(2,4,2,2,meteorcolor3)
        @weatherTypes[PBFieldWeather::MeteorShower][0][0] = @meteorBitmap1
        @weatherTypes[PBFieldWeather::MeteorShower][0][1] = @meteorBitmap2
        @weatherTypes[PBFieldWeather::MeteorShower][0][2] = @meteorBitmap2
        @weatherTypes[PBFieldWeather::MeteorShower][0][3] = @meteorBitmap3
        @weatherTypes[PBFieldWeather::MeteorShower][0][4] = @meteorBitmap3
        @weatherTypes[PBFieldWeather::MeteorShower][0][5] = @meteorBitmap4
        @weatherTypes[PBFieldWeather::MeteorShower][0][6] = @meteorBitmap4
        @weatherTypes[PBFieldWeather::MeteorShower][0][7] = @meteorBitmap4
      end
    end
    
    
    def prepareMagneticBitmaps
      if !@magneticBitmap
        bmwidth  = 10
        bmheight = 10
        @magneticBitmap = Bitmap.new(bmwidth,bmheight)
        magneticcolor = Color.new(120, 120, 120, 255)
        @magneticBitmap.fill_rect(2,0,2,2,magneticcolor)
        @magneticBitmap.fill_rect(0,2,6,2,magneticcolor)
        @magneticBitmap.fill_rect(2,4,2,2,magneticcolor)
        @weatherTypes[PBFieldWeather::MagneticStorm][0][0] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][1] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][2] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][3] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][4] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][5] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][6] = @magneticBitmap
        @weatherTypes[PBFieldWeather::MagneticStorm][0][7] = @magneticBitmap
      end
    end
    
    
    def initialize(viewport = nil)
      @type = 0
      @max = 0
      @ox = 0
      @oy = 0
      @sunvalue = 0
      @sun = 0
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z = viewport.z+1
      @origviewport = viewport
      acid_color = Color.new(204,52,152,255)
      @acid_rain_bitmap = Bitmap.new(32,128)
      for i in 0...16
        @acid_rain_bitmap.fill_rect(30-(i*2),i*8,2,8,acid_color)
      end
      color = Color.new(255,255,255,255)
      @rain_bitmap = Bitmap.new(32,128)
      for i in 0...16
        @rain_bitmap.fill_rect(30-(i*2),i*8,2,8,color)
      end
      @storm_bitmap = Bitmap.new(192,192)
      for i in 0...96
        @storm_bitmap.fill_rect(190-(i*2),i*2,2,2,color)
      end
      # =[[],yspeed,xspeed,respawnspeed]
      @weatherTypes = []
      @weatherTypes[PBFieldWeather::None]            = nil
      @weatherTypes[PBFieldWeather::Rain]            = [[@rain_bitmap],-6,24,-8]
      @weatherTypes[PBFieldWeather::HeavyRain]       = [[@storm_bitmap],-24,24,-4]
      @weatherTypes[PBFieldWeather::Storm]           = [[@storm_bitmap],-24,24,-4]
      @weatherTypes[PBFieldWeather::Snow]            = [[],-4,8,0]
      @weatherTypes[PBFieldWeather::Blizzard]        = [[],-16,16,-4]
      @weatherTypes[PBFieldWeather::Sandstorm]       = [[],-12,4,-2]
      @weatherTypes[PBFieldWeather::Sun]             = nil
      @weatherTypes[PBFieldWeather::Plague]          = [[],-12,4,-2]
      @weatherTypes[PBFieldWeather::Eclipse]         = nil
      @weatherTypes[PBFieldWeather::AncestralAurora] = [[],-4,8,0]
      @weatherTypes[PBFieldWeather::MagicWind]       = [[],-12,4,-2]
      @weatherTypes[PBFieldWeather::FeralBreeze]     = [[],-1,0,-4]
      @weatherTypes[PBFieldWeather::Crowd]           = [[],0,4,-4]
      @weatherTypes[PBFieldWeather::Tornado]         = [[],-24,0,-2]
      @weatherTypes[PBFieldWeather::ScaryFog]        = nil
      @weatherTypes[PBFieldWeather::PollenSeason]    = [[],-2,0,-2]
      @weatherTypes[PBFieldWeather::Tremors]         = nil
      @weatherTypes[PBFieldWeather::AcidRain]        = [[@acid_rain_bitmap],-6,24,-8]
      @weatherTypes[PBFieldWeather::StarryNight]     = nil
      @weatherTypes[PBFieldWeather::MeteorShower]    = [[],-12,16,0]
      @weatherTypes[PBFieldWeather::MagneticStorm]   = [[],0,-1,0]
      @sprites = []
    end

    def ensureSprites
      return if @sprites.length>=40
      for i in 1..40
        sprite = Sprite.new(@origviewport)
        sprite.z       = 1000
        sprite.ox      = @ox
        sprite.oy      = @oy
        sprite.opacity = 0
        sprite.visible = (i<=@max)
        @sprites.push(sprite)
      end
    end

    def dispose
      for sprite in @sprites
        sprite.dispose
      end
      @viewport.dispose
      for weather in @weatherTypes
        next if !weather
        for bm in weather[0]
          bm.dispose
        end
      end
    end

    def type=(type)
      return if @type==type
      @type = type
      case @type
      when PBFieldWeather::Rain
        bitmap = @rain_bitmap
      when PBFieldWeather::AcidRain
        bitmap = @acid_rain_bitmap
      when PBFieldWeather::HeavyRain, PBFieldWeather::Storm
        bitmap = @storm_bitmap
      when PBFieldWeather::Snow
        prepareSnowBitmaps
      when PBFieldWeather::Blizzard
        prepareBlizzardBitmaps
      when PBFieldWeather::Sandstorm
        prepareSandstormBitmaps
      when PBFieldWeather::Plague
        preparePlagueBitmaps
      when PBFieldWeather::AncestralAurora
        prepareAuroraBitmaps
      when PBFieldWeather::MagicWind
        prepareMagicWindBitmaps
      when PBFieldWeather::FeralBreeze
        prepareFeralBreezeBitmaps
      when PBFieldWeather::Crowd
        prepareCrowdBitmaps
      when PBFieldWeather::Tornado
        prepareTornadoBitmaps
      when PBFieldWeather::PollenSeason
        preparePollenSeasonBitmaps
      when PBFieldWeather::MeteorShower
        prepareMeteorBitmaps
      when PBFieldWeather::MagneticStorm
        prepareMagneticBitmaps
      else
        bitmap = nil
      end
      if @type==PBFieldWeather::None
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
        return
      end
      weatherbitmaps = (@type==PBFieldWeather::None || @type==PBFieldWeather::Sun || @type==PBFieldWeather::Eclipse || @type==PBFieldWeather::ScaryFog || @type==PBFieldWeather::Tremors || @type==PBFieldWeather::StarryNight) ? nil : @weatherTypes[@type][0]
      ensureSprites
      for i in 1..40
        sprite = @sprites[i]
        if sprite!=nil
          if @type==PBFieldWeather::Blizzard || @type==PBFieldWeather::Sandstorm || @type==PBFieldWeather::Plague || @type==PBFieldWeather::MagicWind || @type==PBFieldWeather::Tornado || @type==PBFieldWeather::PollenSeason
            sprite.mirror = (rand(2)==0)
          else
            sprite.mirror = false
          end
          sprite.visible = (i<=@max)
          sprite.bitmap  = (@type==PBFieldWeather::None || @type==PBFieldWeather::Sun || @type==PBFieldWeather::Eclipse|| @type==PBFieldWeather::ScaryFog || @type==PBFieldWeather::Tremors|| @type==PBFieldWeather::StarryNight ) ? nil : weatherbitmaps[i%weatherbitmaps.length]
        end
      end
    end

    def ox=(ox)
      return if @ox==ox
      @ox = ox
      for sprite in @sprites
        sprite.ox = @ox
      end
    end

    def oy=(oy)
      return if @oy==oy
      @oy = oy
      for sprite in @sprites
        sprite.oy = @oy
      end
    end

    def max=(max)
      return if @max==max
      @max = [[max,0].max,40].min
      if @max==0
        for sprite in @sprites
          sprite.dispose
        end
        @sprites.clear
      else
        for i in 1..40
          sprite = @sprites[i]
          if sprite!=nil
            sprite.visible = (i<=@max)
          end
        end
      end
    end

    def update
      # @max is (power+1)*4, where power is between 1 and 9
      case @type
      when PBFieldWeather::None
        @viewport.tone.set(0,0,0,0)
      when PBFieldWeather::Rain
        @viewport.tone.set(-@max*3/4,-@max*3/4,-@max*3/4,10)
      when PBFieldWeather::AcidRain
        @viewport.tone.set(-@max*3/4,-@max*3/4,-@max*3/4,10)
      when PBFieldWeather::HeavyRain, PBFieldWeather::Storm
        @viewport.tone.set(-@max*6/4,-@max*6/4,-@max*6/4,20)
      when PBFieldWeather::Snow
        @viewport.tone.set(@max*2/4,@max*2/4,@max*2/4,0)
      when PBFieldWeather::Blizzard
        @viewport.tone.set(@max*3/4,@max*3/4,@max*3/4,0)
      when PBFieldWeather::Sandstorm
        @viewport.tone.set(@max*2/4,0,-@max*2/4,0)
      when PBFieldWeather::Plague
        @viewport.tone.set(-@max*2/4,@max/4,-@max*2/4,30)
      when PBFieldWeather::Eclipse
        @viewport.tone.set(-@max*3,-@max*3,-@max*3,40)
      when PBFieldWeather::AncestralAurora
        @viewport.tone.set(@max*6/4,@max*2/4,@max*6/4,30)
      when PBFieldWeather::MagicWind
        @viewport.tone.set(@max*2/4,0,-@max*2/4,0)
      when PBFieldWeather::FeralBreeze
        @viewport.tone.set(@max*4/4,0,-@max*2/4,0)
      when PBFieldWeather::Crowd
        @viewport.tone.set(@max+45,@max+45,@max+22,0)
      when PBFieldWeather::Tornado
        @viewport.tone.set(-@max*2/4,@max/4,-@max*2/4,20)
      when PBFieldWeather::ScaryFog
        @viewport.tone.set(@max/2,0,@max/2,40)
      when PBFieldWeather::PollenSeason
        @viewport.tone.set(@max/2,@max/2,0,0)
      when PBFieldWeather::Tremors
        @viewport.tone.set(@max/2,@max/2,@max/2,10)
      when PBFieldWeather::StarryNight
        @viewport.tone.set(0,0,@max,40)
      when PBFieldWeather::MeteorShower
        @viewport.tone.set(@max/2,@max/4,@max/8,40)
      when PBFieldWeather::MagneticStorm
        @viewport.tone.set(-@max/2,-@max/2,-@max/2,-10)
      when PBFieldWeather::Sun
        unless @sun==@max || @sun==-@max
          @sun = @max
        end
        @sun = -@sun if @sunvalue>@max || @sunvalue<0
        @sunvalue = @sunvalue+@sun/32
        @viewport.tone.set(@sunvalue+63,@sunvalue+63,@sunvalue/2+31,0)
      end
      # Storm flashes
      if @type==PBFieldWeather::Storm || PBFieldWeather::MagneticStorm
        rnd = rand(300)
        if rnd<4
          @viewport.flash(Color.new(255,255,255,230),rnd*20)
        end
      end
      # Crowd flashes
      if @type==PBFieldWeather::Crowd
        rnd = rand(300)
        if rnd<20
          @viewport.flash(Color.new(255,255,255,230),rnd*10)
        end
      end
      # StarryNight flashes
      if @type==PBFieldWeather::StarryNight
        rnd = rand(300)
        if rnd<2
          @viewport.flash(Color.new(255,255,255,170),rnd*5)
        elsif rnd < 4
          @viewport.flash(Color.new(204,236,255,170),rnd*5)
        elsif rnd < 6
          @viewport.flash(Color.new(32*8,51,113,170),rnd*5)
        elsif rnd < 8
          @viewport.flash(Color.new(255,255,153,170),rnd*5)
        end
      end
      @viewport.update
      return if @type==PBFieldWeather::None || @type==PBFieldWeather::Sun || @type==PBFieldWeather::Eclipse || @type==PBFieldWeather::ScaryFog || @type==PBFieldWeather::Tremors || @type==PBFieldWeather::StarryNight
      ensureSprites
      for i in 1..@max
        sprite = @sprites[i]
        break if sprite==nil
        sprite.x += @weatherTypes[@type][1]
        sprite.x += [2,0,0,-2][rand(4)] if @type==PBFieldWeather::Snow || @type==PBFieldWeather::Blizzard || @type==PBFieldWeather::AncestralAurora
        sprite.y += @weatherTypes[@type][2]
        sprite.opacity += @weatherTypes[@type][3]
        x = sprite.x-@ox
        y = sprite.y-@oy
        nomwidth  = Graphics.width
        nomheight = Graphics.height
        if sprite.opacity<64 || x<-50 || x>nomwidth+128 || y<-300 || y>nomheight+20
          sprite.x = rand(nomwidth+150)-50+@ox
          sprite.y = rand(nomheight+150)-200+@oy
          sprite.opacity = 255
          if @type==PBFieldWeather::Blizzard || @type==PBFieldWeather::Sandstorm || @type==PBFieldWeather::Plague || @type==PBFieldWeather::Tornado
            sprite.mirror = (rand(2)==0)
          else
            sprite.mirror = false
          end
        end
        pbDayNightTint(sprite)
      end
    end
  end
end