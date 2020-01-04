class PokeBattle_Battler
#===============================================================================
# Sleep
#===============================================================================
  def pbCanSleep?(attacker,showMessages,move=nil,ignorestatus=false)
    return false if fainted?
    selfsleep=(attacker && attacker.index==self.index)
    if !ignorestatus && status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1} is already asleep!",pbThis)) if showMessages
      return false
    end
    if !selfsleep
      if self.status!=0 ||
         (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
        @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
    end
    if !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      if @battle.field.effects[PBEffects::ElectricTerrain]>0
        @battle.pbDisplay(_INTL("The Electric Terrain prevented {1} from falling asleep!",pbThis(true))) if showMessages
        return false
      elsif @battle.field.effects[PBEffects::MistyTerrain]>0
        @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from falling asleep!",pbThis(true))) if showMessages
        return false
      end
    end
    if (attacker && attacker.hasMoldBreaker) || !hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
          return false
        end
      end 
    end
    if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
      if hasWorkingAbility(:VITALSPIRIT) ||
         hasWorkingAbility(:INSOMNIA) ||
         hasWorkingAbility(:SWEETVEIL) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:SWEETVEIL) ||
         (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1} stayed awake using its partner's {2}!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if !selfsleep
      if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
         (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
        return false
      end
    end
    return true
  end

  def pbCanSleepYawn?
    return false if status!=0
    if !hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        return false if @battle.battlers[i].effects[PBEffects::Uproar]>0
      end
    end
    if !self.isAirborne?
      return false if @battle.field.effects[PBEffects::ElectricTerrain]>0
      return false if @battle.field.effects[PBEffects::MistyTerrain]>0
    end
    if hasWorkingAbility(:VITALSPIRIT) ||
       hasWorkingAbility(:INSOMNIA) ||
       hasWorkingAbility(:SWEETVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      return false
    end
    return false if pbPartner.hasWorkingAbility(:SWEETVEIL)
    return true
  end

  def pbSleep(msg=nil)
    self.status=PBStatuses::SLEEP
    self.statusCount=2+@battle.pbRandom(3)
    self.statusCount=(self.statusCount/2).floor if self.hasWorkingAbility(:EARLYBIRD)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} fell asleep!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} fell asleep (#{self.statusCount} turns)")
  end

  def pbSleepSelf(duration=-1)
    self.status=PBStatuses::SLEEP
    if duration>0
      self.statusCount=duration
    else
      self.statusCount=2+@battle.pbRandom(3)
    end
    self.statusCount=(self.statusCount/2).floor if self.hasWorkingAbility(:EARLYBIRD)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    PBDebug.log("[Status change] #{pbThis} made itself fall asleep (#{self.statusCount} turns)")
  end

#===============================================================================
# Poison
#===============================================================================
  def pbCanPoison?(attacker,showMessages,move=nil)
    return false if fainted?
    if status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} is already poisoned.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:POISON) || pbHasType?(:STEEL)) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being poisoned!",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:IMMUNITY) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents poisoning!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents poisoning!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPoisonSynchronize?(opponent)
    return false if fainted?
    if (pbHasType?(:POISON) || pbHasType?(:STEEL)) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
         opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      return false
    end   
    return false if self.status!=0
    if hasWorkingAbility(:IMMUNITY) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbCanPoisonSpikes?(moldbreaker=false)
    return false if fainted?
    return false if self.status!=0
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    if !moldbreaker
      return false if hasWorkingAbility(:IMMUNITY) ||
                      (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
                      (pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
      return false if hasWorkingAbility(:LEAFGUARD) &&
                      (@battle.pbWeather==PBWeather::SUNNYDAY ||
                      @battle.pbWeather==PBWeather::HARSHSUN)
    end
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end

  def pbPoison(attacker=nil,msg=nil,toxic=false)
    self.status=PBStatuses::POISON
    self.statusCount=(toxic) ? 1 : 0
    self.effects[PBEffects::Toxic]=0
    @battle.pbCommonAnimation("Poison",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      if toxic
        @battle.pbDisplay(_INTL("{1} was badly poisoned!",pbThis))
      else
        @battle.pbDisplay(_INTL("{1} was poisoned!",pbThis))
      end
    end
    if toxic
      PBDebug.log("[Status change] #{pbThis} was badly poisoned]")
    else
      PBDebug.log("[Status change] #{pbThis} was poisoned")
    end
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanPoisonSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbPoison(nil,_INTL("{1}'s {2} poisoned {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)),toxic)
      end
    end
  end

#===============================================================================
# Burn
#===============================================================================
  def pbCanBurn?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being burned!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:WATERVEIL) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents burns!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBurnSelf(attacker=nil)
    self.status=PBStatuses::BURN
    @battle.pbCommonAnimation("Burn",self,nil)
    @battle.pbDisplay(_INTL("{1} was burned!",pbThis))
    PBDebug.log("[Status change] #{pbThis} was burned")
  end

#===============================================================================
# Paralyze
#===============================================================================
  def pbCanParalyze?(attacker,showMessages,move=nil)
    return false if fainted?
    if status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} is already paralyzed!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being paralyzed!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:ELECTRIC) && !hasWorkingItem(:RINGTARGET) && USENEWBATTLEMECHANICS
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:LIMBER) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents paralysis!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents paralysis!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanParalyzeSynchronize?(opponent)
    return false if self.status!=0
    return false if @battle.field.effects[PBEffects::MistyTerrain]>0 && !self.isAirborne?
    return false if pbHasType?(:ELECTRIC) && !hasWorkingItem(:RINGTARGET) && USENEWBATTLEMECHANICS
    if hasWorkingAbility(:LIMBER) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbParalyze(attacker=nil,msg=nil)
    self.status=PBStatuses::PARALYSIS
    self.statusCount=0
    @battle.pbCommonAnimation("Paralysis",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is paralyzed! It may be unable to move!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} was paralyzed")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanParalyzeSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbParalyze(nil,_INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           self.pbThis,PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Freeze
#===============================================================================
  def pbCanFreeze?(attacker,showMessages,move=nil)
    return false if fainted?
    if status==PBStatuses::FROZEN
      @battle.pbDisplay(_INTL("{1} is already frozen solid!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))) ||
       @battle.pbWeather==PBWeather::SUNNYDAY ||
       @battle.pbWeather==PBWeather::HARSHSUN
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbHasType?(:ICE) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being frozen!",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:MAGMAARMOR) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents freezing!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents freezing!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbFreeze(msg=nil)
    self.status=PBStatuses::FROZEN
    self.statusCount=0
    pbCancelMoves
    @battle.pbCommonAnimation("Frozen",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} was frozen solid!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} was frozen")
  end

#===============================================================================
# Wet
#===============================================================================
  def pbCanWet?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::WET
      @battle.pbDisplay(_INTL("{1} is already wet.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being burned!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:WATER) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:DRYSKIN) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} keeps it dry!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} keeps it dry!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanWetSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:WATER) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:DRYSKIN) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbWet(attacker=nil,msg=nil)
    self.status=PBStatuses::WET
    self.statusCount=0
    @battle.pbCommonAnimation("Wet",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is extremly wet!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} is wet")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanWetSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbWet(nil,_INTL("{1}'s {2} made {3} wet!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Rash
#===============================================================================
  def pbCanRash?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::RASH
      @battle.pbDisplay(_INTL("{1} already has a rash.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from getting a rash!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:GRASS) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:SAPSIPPER) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevented the rash!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevented the rash!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanRashSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:GRASS) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:SAPSIPPER) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbRash(attacker=nil,msg=nil)
    self.status=PBStatuses::RASH
    self.statusCount=0
    @battle.pbCommonAnimation("Rash",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} got a rash!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} got a rash")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanRashSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbRash(nil,_INTL("{1}'s {2} gave {3} a rash!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Bruised
#===============================================================================
  def pbCanBruised?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::BRUISED
      @battle.pbDisplay(_INTL("{1} is already bruised.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from been bruised!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:FIGHTING) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:COMPETITIVE) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents bruising!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} preventes bruising!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBruisedSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:FIGHTING) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:COMPETITIVE) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBruised(attacker=nil,msg=nil)
    self.status=PBStatuses::BRUISED
    self.statusCount=0
    @battle.pbCommonAnimation("Bruised",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} got bruised!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} got bruised")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanBruisedSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbBruised(nil,_INTL("{1}'s {2} bruised {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Dirty
#===============================================================================
  def pbCanDirty?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::DIRTY
      @battle.pbDisplay(_INTL("{1} is already dirty.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from getting dirty!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:GROUND) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:ROUGHSKIN) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents bruising!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} preventes bruising!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanDirtySynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:GROUND) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:ROUGHSKIN) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbDirty(attacker=nil,msg=nil)
    self.status=PBStatuses::DIRTY
    self.statusCount=0
    @battle.pbCommonAnimation("Dirty",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} got dirty!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} got dirty")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanDirtySynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbDirty(nil,_INTL("{1}'s {2} dirtied {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Unbalanced
#===============================================================================
  def pbCanUnbalanced?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::UNBALANCED
      @battle.pbDisplay(_INTL("{1} is already out of balanced.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from losing itd balance!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:FLYING) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:INNERFOCUS) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents the lost of balance!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} helped it regain its balance !",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbUnbalanced(attacker=nil,msg=nil)
    self.status=PBStatuses::UNBALANCED
    self.statusCount=0
    @battle.pbCommonAnimation("Unbalanced",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} lost its balance!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} lost its balance")
  end

#===============================================================================
# Mind Shattered
#===============================================================================
  def pbCanMindShattered?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::MINDCONTROL
      @battle.pbDisplay(_INTL("{1} is already stung.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1}'s mind from shattering!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:PSYCHIC) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:UNAWARE) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents mind shattering",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents mind shattering!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanMindShatteredSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:PSYCHIC) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:UNAWARE) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbMindShattered(attacker=nil,msg=nil)
    self.status=PBStatuses::MINDCONTROL
    self.statusCount=0
    @battle.pbCommonAnimation("MindControl",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} mind was shattered!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} mind was shattered")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanMindShatteredSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbMindShattered(nil,_INTL("{1}'s {2} shattered {3}' mind!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Stung
#===============================================================================
  def pbCanStung?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::STUNG
      @battle.pbDisplay(_INTL("{1} is already stung.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from getting stung!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:BUG) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:FOREWARN) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stinging!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents stinging!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanStungSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:BUG) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:FOREWARN) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbStung(attacker=nil,msg=nil)
    self.status=PBStatuses::STUNG
    self.statusCount=0
    @battle.pbCommonAnimation("Stung",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} was stung!",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} mind was shattered")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanStungSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbStung(nil,_INTL("{1}'s {2} stung {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Petrify
#===============================================================================
  def pbCanPetrify?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::PETRIFY
      @battle.pbDisplay(_INTL("{1} is already petrify.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from getting petrify!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:ROCK) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:OVERCOAT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents petrification!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents petrification!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPetrifySynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:ROCK) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:OVERCOAT) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbPetrify(attacker=nil,msg=nil)
    self.status=PBStatuses::PETRIFY
    self.statusCount=0
    @battle.pbCommonAnimation("Petrify",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} was petrify",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} mind was shattered")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanPetrifySynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbPetrify(nil,_INTL("{1}'s {2} stung {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Fear
#===============================================================================
  def pbCanFear?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::FEAR
      @battle.pbDisplay(_INTL("{1} is already afraid.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from getting afraid!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:GHOST) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:OBLIVIOUS) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents fear!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents fear!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanFearSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:GHOST) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:OBLIVIOUS) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbFear(attacker=nil,msg=nil)
    self.status=PBStatuses::FEAR
    self.statusCount=0
    @battle.pbCommonAnimation("Fear",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is afraid",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} is afraid!")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanFearSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbFear(nil,_INTL("{1}'s {2} scared {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Awakening
#===============================================================================
  def pbCanAwakened?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::AWAKENED
      @battle.pbDisplay(_INTL("{1} is already awaken.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1}'s awakening!",pbThis(true))) if showMessages
      return false
    end
    return true
  end

  def pbAwakened(attacker=nil,msg=nil)
    self.status=PBStatuses::AWAKENED
    self.statusCount=0
    @battle.pbCommonAnimation("Awakened",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1}'s secret power is awakening",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} awakened")
  end

#===============================================================================
# Blinded
#===============================================================================
  def pbCanBlinded?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::BLINDED
      @battle.pbDisplay(_INTL("{1} is already blind.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being blinded!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:DARK) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:COMPOUNDEYES) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents blindness!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents blindness!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBlindedSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:DARK) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:COMPOUNDEYES) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBlinded(attacker=nil,msg=nil)
    self.status=PBStatuses::BLINDED
    self.statusCount=0
    @battle.pbCommonAnimation("Blinded",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is temporary blind",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} is blind")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanBlindedSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbBlinded(nil,_INTL("{1}'s {2} blinded {3}!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Shrapnel
#===============================================================================
  def pbCanShrapnel?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::SHRAPNEL
      @battle.pbDisplay(_INTL("{1} is already covered in shrapnel.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from being covered in shrapnel!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:STEEL) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:BULLETPROOF) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents shrapnel sticking!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents shrapnel sticking!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanShrapnelSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:STEEL) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:BULLETPROOF) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbShrapnel(attacker=nil,msg=nil)
    self.status=PBStatuses::SHRAPNEL
    self.statusCount=0
    @battle.pbCommonAnimation("Shrapnel",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is covered in shrapnel",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} got shrapnel")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanShrapnelSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbShrapnel(nil,_INTL("{1}'s {2} covered {3} in shrapnel!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end

#===============================================================================
# Enchanted
#===============================================================================
  def pbCanEnchanted?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::ENCHANTED
      @battle.pbDisplay(_INTL("{1} is already enchanted.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1}'s enchantment!",pbThis(true))) if showMessages
      return false
    end
    return true
  end

  def pbEnchanted(attacker=nil,msg=nil)
    self.status=PBStatuses::ENCHANTED
    self.statusCount=0
    @battle.pbCommonAnimation("Enchanted",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is enchanted",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} enchanted")
  end

#===============================================================================
# Bleeding
#===============================================================================
  def pbCanBleeding?(attacker,showMessages,move=nil)
    return false if fainted?
    if self.status==PBStatuses::BLEEDING
      @battle.pbDisplay(_INTL("{1} is already bleeding.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 ||
       (@effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker)))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if @battle.field.effects[PBEffects::MistyTerrain]>0 &&
       !self.isAirborne?(attacker && attacker.hasMoldBreaker)
      @battle.pbDisplay(_INTL("The Misty Terrain prevented {1} from bleeding!",pbThis(true))) if showMessages
      return false
    end
    if pbHasType?(:FERAL) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:DEFIANT) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
         (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                            @battle.pbWeather==PBWeather::HARSHSUN))
        @battle.pbDisplay(_INTL("{1}'s {2} prevents bleeding!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        @battle.pbDisplay(_INTL("{1}'s partner's {2} prevents bleeding!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBleedingSynchronize?(opponent)
    return false if fainted?
    return false if self.status!=0
    if pbHasType?(:FERAL) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:DEFIANT) ||
       (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)) ||
       (hasWorkingAbility(:LEAFGUARD) && (@battle.pbWeather==PBWeather::SUNNYDAY ||
                                          @battle.pbWeather==PBWeather::HARSHSUN))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbPartner.pbThis,PBAbilities.getName(pbPartner.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBleeding(attacker=nil,msg=nil)
    self.status=PBStatuses::BLEEDING
    self.statusCount=0
    @battle.pbCommonAnimation("Bleeding",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} is bleeding",pbThis))
    end
    PBDebug.log("[Status change] #{pbThis} is bleeding")
    if attacker && self.index!=attacker.index &&
       self.hasWorkingAbility(:SYNCHRONIZE)
      if attacker.pbCanBleedingSynchronize?(self)
        PBDebug.log("[Ability triggered] #{self.pbThis}'s Synchronize")
        attacker.pbBleeding(nil,_INTL("{1}'s {2} made {3} bleed!",self.pbThis,
           PBAbilities.getName(self.ability),attacker.pbThis(true)))
      end
    end
  end
    
#===============================================================================
# Generalised status displays
#===============================================================================
  def pbContinueStatus(showAnim=true)
    case self.status
    when PBStatuses::SLEEP
      @battle.pbCommonAnimation("Sleep",self,nil)
      @battle.pbDisplay(_INTL("{1} is fast asleep.",pbThis))
    when PBStatuses::POISON
      @battle.pbCommonAnimation("Poison",self,nil)
      @battle.pbDisplay(_INTL("{1} was hurt by poison!",pbThis))
    when PBStatuses::BURN
      @battle.pbCommonAnimation("Burn",self,nil)
      @battle.pbDisplay(_INTL("{1} was hurt by its burn!",pbThis))
    when PBStatuses::PARALYSIS
      @battle.pbCommonAnimation("Paralysis",self,nil)
      @battle.pbDisplay(_INTL("{1} is paralyzed! It can't move!",pbThis)) 
    when PBStatuses::FROZEN
      @battle.pbCommonAnimation("Frozen",self,nil)
      @battle.pbDisplay(_INTL("{1} is frozen solid!",pbThis)) 
    when PBStatuses::UNBALANCED
      @battle.pbCommonAnimation("Unbalanced",self,nil)
      @battle.pbDisplay(_INTL("{1} lost its balance! It couldn't move",pbThis))
    when PBStatuses::MINDCONTROL
      @battle.pbCommonAnimation("MindControl",self,nil)
      @battle.pbDisplay(_INTL("{1} mind is shattered! It couldn't move",pbThis))
    when PBStatuses::PETRIFY
      @battle.pbCommonAnimation("Petrify",self,nil)
      @battle.pbDisplay(_INTL("{1} is petrified! It can't use physical attacks",pbThis))
    when PBStatuses::FEAR
      @battle.pbCommonAnimation("Fear",self,nil)
      @battle.pbDisplay(_INTL("{1} is afraid! It can't use special attacks",pbThis))
    when PBStatuses::RASH
      @battle.pbCommonAnimation("Rash",self,nil)
      @battle.pbDisplay(_INTL("{1} was hurt by its rash!",pbThis))
    when PBStatuses::BLEEDING
      @battle.pbCommonAnimation("Bleeding",self,nil)
      @battle.pbDisplay(_INTL("{1} is bleeding!",pbThis))
    when PBStatuses::DIRTY
      @battle.pbCommonAnimation("Dirty",self,nil)
      @battle.pbDisplay(_INTL("{1} is hurt by the dirt!",pbThis))
    when PBStatuses::SHRAPNEL
      @battle.pbCommonAnimation("Shrapnel",self,nil)
      @battle.pbDisplay(_INTL("{1} is hurt by the shrapnel!",pbThis))
    when PBStatuses::AWAKENED
      @battle.pbCommonAnimation("Awakened",self,nil)
      @battle.pbDisplay(_INTL("{1}'s secret power is awakening!",pbThis))
    when PBStatuses::ENCHANTED
      @battle.pbCommonAnimation("Enchanted",self,nil)
      @battle.pbDisplay(_INTL("{1}'s enchantment healed some damage!",pbThis))
    end
  end

  def pbCureStatus(showMessages=true)
    oldstatus=self.status
    self.status=0
    self.statusCount=0
    if showMessages
      case oldstatus
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} poison fadded!",pbThis))
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} burn fadded!",pbThis))
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of paralysis.",pbThis))
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} thawed out!",pbThis))
      when PBStatuses::WET
        @battle.pbDisplay(_INTL("{1} dryed up!",pbThis))
      when PBStatuses::RASH
        @battle.pbDisplay(_INTL("{1} rash fadded!",pbThis))
      when PBStatuses::BRUISES
        @battle.pbDisplay(_INTL("{1} bruises fadded!",pbThis))
      when PBStatuses::DIRTY
        @battle.pbDisplay(_INTL("{1} dirt was cleaned.",pbThis))
      when PBStatuses::UNBALANCED
        @battle.pbDisplay(_INTL("{1} regained its balance!",pbThis))
      when PBStatuses::MINDCONTROL
        @battle.pbDisplay(_INTL("{1} mind was restored to normal!",pbThis))
      when PBStatuses::STUNG
        @battle.pbDisplay(_INTL("{1} sting fadded!",pbThis))
      when PBStatuses::PETRIFY
        @battle.pbDisplay(_INTL("{1} petrification fadded!",pbThis))
      when PBStatuses::FEAR
        @battle.pbDisplay(_INTL("{1} was cured of it fear.",pbThis))
      when PBStatuses::AWAKENED
        @battle.pbDisplay(_INTL("{1} awakening stopped!",pbThis))
      when PBStatuses::BLINDED
        @battle.pbDisplay(_INTL("{1}'s sight was restored!",pbThis))
      when PBStatuses::SHRAPNEL
        @battle.pbDisplay(_INTL("{1} shrapnel fadded!",pbThis))
      when PBStatuses::ENCHANTMENT
        @battle.pbDisplay(_INTL("{1} enchantment fadded!",pbThis))
      when PBStatuses::BLEEDING
        @battle.pbDisplay(_INTL("{1} was cured of its bleeding.",pbThis))
      end
    end
    PBDebug.log("[Status change] #{pbThis}'s status was cured")
  end

#===============================================================================
# Confuse
#===============================================================================
  def pbCanConfuse?(attacker=nil,showMessages=true,move=nil)
    return false if fainted?
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if @effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !attacker || !attacker.hasMoldBreaker
      if hasWorkingAbility(:OWNTEMPO)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
        return false
      end
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0 &&
       (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return false if fainted?
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if hasWorkingAbility(:OWNTEMPO)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    return true
  end

  def pbConfuse
    @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
    @battle.pbCommonAnimation("Confusion",self,nil)
    PBDebug.log("[Lingering effect triggered] #{pbThis} became confused (#{@effects[PBEffects::Confusion]} turns)")
  end

  def pbConfuseSelf
    if pbCanConfuseSelf?(false)
      @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",self,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
      PBDebug.log("[Lingering effect triggered] #{pbThis} became confused (#{@effects[PBEffects::Confusion]} turns)")
    end
  end

  def pbContinueConfusion
    @battle.pbCommonAnimation("Confusion",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is confused!",pbThis))
  end

  def pbCureConfusion(showMessages=true)
    @effects[PBEffects::Confusion]=0
    @battle.pbDisplay(_INTL("{1} snapped out of confusion!",pbThis)) if showMessages
    PBDebug.log("[End of effect] #{pbThis} was cured of confusion")
  end

#===============================================================================
# Attraction
#===============================================================================
  def pbCanAttract?(attacker,showMessages=true)
    return false if fainted?
    return false if !attacker || attacker.fainted?
    if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    agender=attacker.gender
    ogender=self.gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (!attacker || !attacker.hasMoldBreaker) && hasWorkingAbility(:OBLIVIOUS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,
         PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    return true
  end

  def pbAttract(attacker,msg=nil)
    @effects[PBEffects::Attract]=attacker.index
    @battle.pbCommonAnimation("Attract",self,nil)
    if msg && msg!=""
      @battle.pbDisplay(msg)
    else
      @battle.pbDisplay(_INTL("{1} fell in love!",pbThis))
    end
    PBDebug.log("[Lingering effect triggered] #{pbThis} became infatuated (with #{attacker.pbThis(true)})")
    if self.hasWorkingItem(:DESTINYKNOT) &&
       attacker.pbCanAttract?(self,false)
      PBDebug.log("[Item triggered] #{pbThis}'s Destiny Knot")
      attacker.pbAttract(self,_INTL("{1}'s {2} made {3} fall in love!",pbThis,
         PBItems.getName(self.item),attacker.pbThis(true)))
    end
  end

  def pbAnnounceAttract(seducer)
    @battle.pbCommonAnimation("Attract",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!",
       pbThis,seducer.pbThis(true)))
  end

  def pbContinueAttract
    @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis)) 
  end

  def pbCureAttract
    @effects[PBEffects::Attract]=-1
    PBDebug.log("[End of effect] #{pbThis} was cured of infatuation")
  end

#===============================================================================
# Flinching
#===============================================================================
  def pbFlinch(attacker=nil)
    return false if (!attacker || !attacker.hasMoldBreaker) && hasWorkingAbility(:INNERFOCUS)
    @effects[PBEffects::Flinch]=true
    return true
  end

#===============================================================================
# Increase stat stages
#===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat]>=6
  end

  def pbCanIncreaseStatStage?(stat,attacker=nil,showMessages=false,move=nil,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbCanReduceStatStage?(stat,attacker,showMessages,moldbreaker,true)
        end
      end
    end
    return false if fainted?
    if pbTooHigh?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any higher!",
         pbThis,PBStats.getName(stat))) if showMessages
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat,increment,attacker=nil,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbReduceStatBasic(stat,increment,attacker,moldbreaker,true)
        end
        increment*=2 if hasWorkingAbility(:SIMPLE)
      end
    end
    increment=[increment,6-@stages[stat]].min
    PBDebug.log("[Stat change] #{pbThis}'s #{PBStats.getName(stat)} rose by #{increment} stage(s) (was #{@stages[stat]}, now #{@stages[stat]+increment})")
    @stages[stat]+=increment
    return increment
  end

  def pbIncreaseStat(stat,increment,attacker,showMessages,move=nil,upanim=true,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbReduceStat(stat,increment,attacker,showMessages,move,upanim,moldbreaker,true)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanIncreaseStatStage?(stat,attacker,showMessages,move,moldbreaker,ignoreContrary)
      increment=pbIncreaseStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary)
      if increment>0
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if upanim
        end
        @battle.pbCommonAnimation("StatUp",self,nil) if upanim
        arrStatTexts=[_INTL("{1}'s {2} rose!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} rose sharply!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} rose drastically!",pbThis,PBStats.getName(stat))]
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
        return true
      end
    end
    return false
  end

  def pbIncreaseStatWithCause(stat,increment,attacker,cause,showanim=true,showmessage=true,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbReduceStatWithCause(stat,increment,attacker,cause,showanim,showmessage,moldbreaker,true)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanIncreaseStatStage?(stat,attacker,false,nil,moldbreaker,ignoreContrary)
      increment=pbIncreaseStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary)
      if increment>0
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if showmessage
        end
        @battle.pbCommonAnimation("StatUp",self,nil) if showanim
        if attacker.index==self.index
          arrStatTexts=[_INTL("{1}'s {2} raised its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} sharply raised its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} went way up!",pbThis,PBStats.getName(stat))]
        else
          arrStatTexts=[_INTL("{1}'s {2} raised {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
             _INTL("{1}'s {2} sharply raised {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
             _INTL("{1}'s {2} drastically raised {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat))]
        end
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min]) if showmessage
        return true
      end
    end
    return false
  end

#===============================================================================
# Decrease stat stages
#===============================================================================
  def pbTooLow?(stat)
    return @stages[stat]<=-6
  end

  # Tickle (04A) and Noble Roar (13A) can't use this, but replicate it instead.
  # (Reason is they lowers more than 1 stat independently, and therefore could
  # show certain messages twice which is undesirable.)
  def pbCanReduceStatStage?(stat,attacker=nil,showMessages=false,move=nil,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbCanIncreaseStatStage?(stat,attacker,showMessages,move,moldbreaker,true)
        end
      end
    end
    return false if fainted?
    selfreduce=(attacker && attacker.index==self.index)
    if !selfreduce
      if @effects[PBEffects::Substitute]>0 && (!move || !move.ignoresSubstitute?(attacker))
        @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0 &&
        (!attacker || !attacker.hasWorkingAbility(:INFILTRATOR))
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showMessages
        return false
      end
      if !moldbreaker && (!attacker || !attacker.hasMoldBreaker)
        if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE)
          abilityname=PBAbilities.getName(self.ability)
          @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if pbHasType?(:GRASS)
          if hasWorkingAbility(:FLOWERVEIL)
            abilityname=PBAbilities.getName(self.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
            return false
          elsif pbPartner.hasWorkingAbility(:FLOWERVEIL)
            abilityname=PBAbilities.getName(pbPartner.ability)
            @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",pbPartner.pbThis,abilityname,pbThis(true))) if showMessages
            return false
          end
        end
        if stat==PBStats::ATTACK && hasWorkingAbility(:HYPERCUTTER)
          abilityname=PBAbilities.getName(self.ability)
          @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if stat==PBStats::DEFENSE && hasWorkingAbility(:BIGPECKS)
          abilityname=PBAbilities.getName(self.ability)
          @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",pbThis,abilityname)) if showMessages
          return false
        end
        if stat==PBStats::ACCURACY && hasWorkingAbility(:KEENEYE)
          abilityname=PBAbilities.getName(self.ability)
          @battle.pbDisplay(_INTL("{1}'s {2} prevents accuracy loss!",pbThis,abilityname)) if showMessages
          return false
        end
      end
    end
    if pbTooLow?(stat)
      @battle.pbDisplay(_INTL("{1}'s {2} won't go any lower!",
         pbThis,PBStats.getName(stat))) if showMessages
      return false
    end
    return true
  end

  def pbReduceStatBasic(stat,increment,attacker=nil,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker # moldbreaker is true only when Roar forces out a Pokémon into Sticky Web
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbIncreaseStatBasic(stat,increment,attacker,moldbreaker,true)
        end
        increment*=2 if hasWorkingAbility(:SIMPLE)
      end
    end
    increment=[increment,6+@stages[stat]].min
    PBDebug.log("[Stat change] #{pbThis}'s #{PBStats.getName(stat)} fell by #{increment} stage(s) (was #{@stages[stat]}, now #{@stages[stat]-increment})")
    @stages[stat]-=increment
    return increment
  end

  def pbReduceStat(stat,increment,attacker,showMessages,move=nil,downanim=true,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbIncreaseStat(stat,increment,attacker,showMessages,move,downanim,moldbreaker,true)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanReduceStatStage?(stat,attacker,showMessages,move,moldbreaker,ignoreContrary)
      increment=pbReduceStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary)
      if increment>0
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if downanim
        end
        @battle.pbCommonAnimation("StatDown",self,nil) if downanim
        arrStatTexts=[_INTL("{1}'s {2} fell!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} harshly fell!",pbThis,PBStats.getName(stat)),
           _INTL("{1}'s {2} severely fell!",pbThis,PBStats.getName(stat))]
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min])
        # Defiant
        if hasWorkingAbility(:DEFIANT) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::ATTACK,2,self,PBAbilities.getName(self.ability))
        end
        # Competitive
        if hasWorkingAbility(:COMPETITIVE) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::SPATK,2,self,PBAbilities.getName(self.ability))
        end
        return true
      end
    end
    return false
  end

  def pbReduceStatWithCause(stat,increment,attacker,cause,showanim=true,showmessage=true,moldbreaker=false,ignoreContrary=false)
    if !moldbreaker
      if !attacker || attacker.index==self.index || !attacker.hasMoldBreaker
        if hasWorkingAbility(:CONTRARY) && !ignoreContrary
          return pbIncreaseStatWithCause(stat,increment,attacker,cause,showanim,showmessage,moldbreaker,true)
        end
      end
    end
    return false if stat!=PBStats::ATTACK && stat!=PBStats::DEFENSE &&
                    stat!=PBStats::SPATK && stat!=PBStats::SPDEF &&
                    stat!=PBStats::SPEED && stat!=PBStats::EVASION &&
                    stat!=PBStats::ACCURACY
    if pbCanReduceStatStage?(stat,attacker,false,nil,moldbreaker,ignoreContrary)
      increment=pbReduceStatBasic(stat,increment,attacker,moldbreaker,ignoreContrary)
      if increment>0
        if ignoreContrary
          @battle.pbDisplay(_INTL("{1}'s {2} activated!",pbThis,PBAbilities.getName(self.ability))) if showmessage
        end
        @battle.pbCommonAnimation("StatDown",self,nil) if showanim
        if attacker.index==self.index
          arrStatTexts=[_INTL("{1}'s {2} lowered its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} harshly lowered its {3}!",pbThis,cause,PBStats.getName(stat)),
             _INTL("{1}'s {2} severely lowered its {3}!",pbThis,cause,PBStats.getName(stat))]
        else
          arrStatTexts=[_INTL("{1}'s {2} lowered {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
             _INTL("{1}'s {2} harshly lowered {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat)),
             _INTL("{1}'s {2} severely lowered {3}'s {4}!",attacker.pbThis,cause,pbThis(true),PBStats.getName(stat))]
        end
        @battle.pbDisplay(arrStatTexts[[increment-1,2].min]) if showmessage
        # Defiant
        if hasWorkingAbility(:DEFIANT) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::ATTACK,2,self,PBAbilities.getName(self.ability))
        end
        # Competitive
        if hasWorkingAbility(:COMPETITIVE) && (!attacker || attacker.pbIsOpposing?(self.index))
          pbIncreaseStatWithCause(PBStats::SPATK,2,self,PBAbilities.getName(self.ability))
        end
        return true
      end
    end
    return false
  end

  def pbReduceAttackStatIntimidate(opponent)
    return false if fainted?
    if effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s substitute protected it from {2}'s {3}!",
         pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    if !opponent.hasWorkingAbility(:CONTRARY)
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected from {2}'s {3} by Mist!",
           pbThis,opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
        return false
      end
      if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
         hasWorkingAbility(:HYPERCUTTER) ||
         (hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS))
        abilityname=PBAbilities.getName(self.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
      if pbPartner.hasWorkingAbility(:FLOWERVEIL) && pbHasType?(:GRASS)
        abilityname=PBAbilities.getName(pbPartner.ability)
        oppabilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
           pbPartner.pbThis,abilityname,opponent.pbThis(true),oppabilityname))
        return false
      end
    end
    return pbReduceStatWithCause(PBStats::ATTACK,1,opponent,PBAbilities.getName(opponent.ability))
  end
end