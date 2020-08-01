#===============================================================================
# Pokédex Regional Dexes list menu screen
# * For choosing which region list to view. Only appears when there is more
#   than one viable region list to choose from, and if DEXDEPENDSONLOCATION is
#   false.
#===============================================================================
class Window_DexesList < Window_CommandPokemon
  def initialize(commands,commands2,width)
    @commands2 = commands2
    super(commands,width)
    @selarrow = AnimatedBitmap.new("Graphics/Pictures/selarrow_white")
    self.baseColor   = Color.new(248,248,248)
    self.shadowColor = Color.new(0,0,0)
    self.windowskin  = nil
  end

  def drawItem(index,count,rect)
    super(index,count,rect)
    if index>=0 && index<@commands2.length
      pbDrawShadowText(self.contents,rect.x+254,rect.y,64,rect.height,
         sprintf("%d",@commands2[index][0]),self.baseColor,self.shadowColor,1)
      pbDrawShadowText(self.contents,rect.x+350,rect.y,64,rect.height,
         sprintf("%d",@commands2[index][1]),self.baseColor,self.shadowColor,1)
      allseen = (@commands2[index][0]>=@commands2[index][2])
      allown  = (@commands2[index][1]>=@commands2[index][2])
      pbDrawImagePositions(self.contents,[
        ["Graphics/Pictures/Pokedex/icon_menuseenown",rect.x+236,rect.y+4,(allseen) ? 24 : 0,0,24,24],
        ["Graphics/Pictures/Pokedex/icon_menuseenown",rect.x+332,rect.y+4,(allown) ? 24 : 0,24,24,24]
      ])
    end
  end
end



class PokemonPokedexMenu_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(commands,commands2)
    @commands = commands
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_menu"))
    @sprites["headings"]=Window_AdvancedTextPokemon.newWithSize(
       _INTL("<c3=F8F8F8,C02028>SEEN<r>OBTAINED</c3>"),286,136,208,64,@viewport)
    @sprites["headings"].windowskin  = nil
    @sprites["commands"] = Window_DexesList.new(commands,commands2,Graphics.width-84)
    @sprites["commands"].x      = 40
    @sprites["commands"].y      = 192
    @sprites["commands"].height = 192
    @sprites["commands"].viewport = @viewport
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::B)
        break
      elsif Input.trigger?(Input::C)
        ret = @sprites["commands"].index
        break
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end



class PokemonPokedexMenuScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    commands  = []
    commands2 = []
    dexnames = pbDexNames
    for i in 0...$PokemonGlobal.pokedexViable.length
      index = $PokemonGlobal.pokedexViable[i]
      if dexnames[index]==nil
        commands[i] = _INTL("Pokédex")
      else
        if dexnames[index].is_a?(Array)
          commands[i] = dexnames[index][0]
        else
          commands[i] = dexnames[index]
        end
      end
      index = -1 if index>=$PokemonGlobal.pokedexUnlocked.length-1
      commands2[i] = [$Trainer.pokedexSeen(index),
                      $Trainer.pokedexOwned(index),
                      pbGetRegionalDexLength(index)]
    end
    commands.push(_INTL("Exit"))
    @scene.pbStartScene(commands,commands2)
    loop do
      cmd = @scene.pbScene
      if cmd<0
        pbPlayCancelSE
        break
      elsif cmd>=commands2.length   # Exit
        pbPlayDecisionSE
        break
      else
        pbPlayDecisionSE
        $PokemonGlobal.pokedexDex = $PokemonGlobal.pokedexViable[cmd]
        $PokemonGlobal.pokedexDex = -1 if $PokemonGlobal.pokedexDex==$PokemonGlobal.pokedexUnlocked.length-1
        pbFadeOutIn(99999){
          scene = PokemonPokedex_Scene.new
          screen = PokemonPokedexScreen.new(scene)
          screen.pbStartScreen
        }
      end
    end
    @scene.pbEndScene
  end
end