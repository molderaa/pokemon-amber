#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Refresh Following Pokemon when mounting Bike
#-------------------------------------------------------------------------------
alias __followingpkmn__pbMountBike pbMountBike unless defined?(__followingpkmn__pbMountBike)
def pbMountBike(*args)
  bike_anim_1 = FollowingPkmn.active?
  ret = __followingpkmn__pbMountBike(*args)
  FollowingPkmn.refresh_internal
  bike_anim_2 = FollowingPkmn.active?
  FollowingPkmn.refresh(bike_anim_1 != bike_anim_2)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon when dismounting Bike
#-------------------------------------------------------------------------------
alias __followingpkmn__pbDismountBike pbDismountBike unless defined?(__followingpkmn__pbDismountBike)
def pbDismountBike(*args)
  bike_anim_1 = FollowingPkmn.active?
  ret = __followingpkmn__pbDismountBike(*args)
  FollowingPkmn.refresh_internal
  bike_anim_2 = FollowingPkmn.active?
  FollowingPkmn.refresh(bike_anim_1 != bike_anim_2)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after accessing the PC
#-------------------------------------------------------------------------------
alias __followingpkmn__pbTrainerPC pbTrainerPC unless defined?(__followingpkmn__pbTrainerPC)
def pbTrainerPC(*args)
  ret = __followingpkmn__pbTrainerPC(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after accessing Poke Centre PC
#-------------------------------------------------------------------------------
alias __followingpkmn__pbPokeCenterPC pbPokeCenterPC unless defined?(__followingpkmn__pbPokeCenterPC)
def pbPokeCenterPC(*args)
  ret = __followingpkmn__pbPokeCenterPC(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after accessing Party Screen
#-------------------------------------------------------------------------------
class PokemonParty_Scene
  alias __followingpkmn__pbEndScene pbEndScene unless method_defined?(:__followingpkmn__pbEndScene)
  def pbEndScene(*args)
    ret = __followingpkmn__pbEndScene(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after any kind of Evolution
#-------------------------------------------------------------------------------
class PokemonEvolutionScene
  alias __followingpkmn__pbEndScreen pbEndScreen unless method_defined?(:__followingpkmn__pbEndScreen)
  def pbEndScreen(*args)
    ret = __followingpkmn__pbEndScreen(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after any kind of Trade is made
#-------------------------------------------------------------------------------
class PokemonTrade_Scene
  alias __followingpkmn__pbEndScreen pbEndScreen unless method_defined?(:__followingpkmn__pbEndScreen)
  def pbEndScreen(*args)
    ret = __followingpkmn__pbEndScreen(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after any Egg is hatched
#-------------------------------------------------------------------------------
alias __followingpkmn__pbHatch pbHatch unless defined?(__followingpkmn__pbHatch)
def pbHatch(*args)
  ret = __followingpkmn__pbHatch(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after usage of Bag. For form changes and stuff
#-------------------------------------------------------------------------------
class PokemonBagScreen
  alias __followingpkmn__pbStartScreen pbStartScreen unless method_defined?(:__followingpkmn__pbStartScreen)
  def pbStartScreen(*args)
    ret = __followingpkmn__pbStartScreen(*args)
    FollowingPkmn.refresh(false)
    return ret
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon upon loading the Debug menu
#-------------------------------------------------------------------------------
alias __followingpkmn__pbDebugMenu pbDebugMenu unless defined?(__followingpkmn__pbDebugMenu)
def pbDebugMenu(*args)
  ret = __followingpkmn__pbDebugMenu(*args)
  FollowingPkmn.refresh(false)
  return ret
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon upon closing the pause menu
#-------------------------------------------------------------------------------
class Scene_Map
  alias __followingpkmn__call_menu call_menu unless method_defined?(:__followingpkmn__call_menu)
  def call_menu(*args)
    __followingpkmn__call_menu(*args)
    FollowingPkmn.refresh(false)
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after depositing Pokemon in Daycare
#-------------------------------------------------------------------------------
class DayCare
  class << self
    alias __followingpkmn__deposit deposit unless method_defined?(:followingpkmn__deposit)
  end

  def self.deposit(*args)
    __followingpkmn__deposit(*args)
    FollowingPkmn.refresh(false)
  end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon upon loading up the game
#-------------------------------------------------------------------------------
module Game
  class << self
    alias __followingpkmn__load_map load_map unless method_defined?(:__followingpkmn__load_map)
    alias __followingpkmn__load load unless method_defined?(:__followingpkmn__load)
  end

  def self.load_map(*args)
    __followingpkmn__load_map(*args)
    FollowingPkmn.refresh(false)
  end
end

#-------------------------------------------------------------------------------
# Queue a Following Pokemon refresh after the end of a battle
#-------------------------------------------------------------------------------
module BattleCreationHelperMethods
  class << self
    alias __followingpkmn__after_battle after_battle unless method_defined?(:__followingpkmn__after_battle)
  end

  def after_battle(*args)
    __followingpkmn__after_battle(*args)
    FollowingPkmn.refresh(false)
    $PokemonGlobal.call_refresh = true
  end
end

class Battle
  #=============================================================================
  # Switching Pokémon
  #=============================================================================
  # General switching method that checks if any Pokémon need to be sent out and,
  # if so, does. Called at the end of each round.
  def pbEORSwitch(favorDraws = false)
    return if @decision > 0 && !favorDraws
    return if @decision == 5 && favorDraws
    pbJudge
    return if @decision > 0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if b.wild?   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          # NOTE: The player is only offered the chance to switch their own
          #       Pokémon when an opponent replaces a fainted Pokémon in single
          #       battles. In double battles, etc. there is no such offer.
          if @internalBattle && @switchStyle && trainerBattle? && pbSideSize(0) == 1 &&
              opposes?(idxBattler) && !@battlers[0].fainted? && !switched.include?(0) &&
              pbCanChooseNonActive?(0) && @battlers[0].effects[PBEffects::Outrage] == 0
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if enemyParty[idxPartyNew].ability == :ILLUSION && !pbCheckGlobalAbility(:NEUTRALIZINGGAS)
              new_index = pbLastInTeam(idxBattler)
              idxPartyForName = new_index if new_index >= 0 && new_index != idxPartyNew
            end
            if pbDisplayConfirm(_INTL("{1} is about to send out {2}. Will you switch your Pokémon?",
                                      opponent.full_name, enemyParty[idxPartyForName].name))
              idxPlayerPartyNew = pbSwitchInBetween(0, false, true)
              if idxPlayerPartyNew >= 0
                pbMessageOnRecall(@battlers[0])
                pbRecallAndReplace(0, idxPlayerPartyNew)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(idxBattler, idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle?   # Player switches in in a trainer battle
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler, idxPlayerPartyNew)
          switched.push(idxBattler)
        else   # Player's Pokémon has fainted in a wild battle
          switch = false
          if pbDisplayConfirm(_INTL("Use next Pokémon?"))
            switch = true
          else
            # refresh_follower_after_battle
            if $PokemonGlobal.follower_toggled
              FollowingPkmn.set_next_follower
            end
            switch = (pbRun(idxBattler, true) <= 0)
          end
          if switch
            idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
            pbRecallAndReplace(idxBattler, idxPlayerPartyNew)
            switched.push(idxBattler)
          end
        end
      end
      break if switched.length == 0
      pbOnBattlerEnteringBattle(switched)
    end
  end
end

class Scene_Map
  #-----------------------------------------------------------------------------
  # Check for Toggle input and update Following Pokemon's time_taken for to
  # track the happiness increase and hold item
  #-----------------------------------------------------------------------------
  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    if defined?(FollowingPkmn::TOGGLE_FOLLOWER_KEY) && FollowingPkmn::TOGGLE_FOLLOWER_KEY &&
       ((Input.const_defined?(FollowingPkmn::TOGGLE_FOLLOWER_KEY) &&
        Input.trigger?(Input.const_get(FollowingPkmn::TOGGLE_FOLLOWER_KEY))) ||
        Input.triggerex?(FollowingPkmn::TOGGLE_FOLLOWER_KEY))
      FollowingPkmn.toggle
      return
    end
    return if !FollowingPkmn.active?
    FollowingPkmn.increase_time
    if defined?(FollowingPkmn::CYCLE_PARTY_KEY) && FollowingPkmn::CYCLE_PARTY_KEY &&
       ((Input.const_defined?(FollowingPkmn::CYCLE_PARTY_KEY) &&
        Input.trigger?(Input.const_get(FollowingPkmn::CYCLE_PARTY_KEY))) ||
        Input.triggerex?(FollowingPkmn::CYCLE_PARTY_KEY))
      FollowingPkmn.toggle_off
      loop do
        pkmn = $player.party.shift
 			  $player.party.push(pkmn)
        $PokemonGlobal.follower_toggled = true
        if FollowingPkmn.active?
          $PokemonGlobal.follower_toggled = false
          break
        end
        $PokemonGlobal.follower_toggled = false
      end
      FollowingPkmn.toggle_on
      return
    end
  end
  #-----------------------------------------------------------------------------
  # Forcefully set the Following Pokemon direction when the player transfers to
  # a new area
  #-----------------------------------------------------------------------------
  alias __followingpkmn__transfer_player transfer_player unless method_defined?(:__followingpkmn__transfer_player)
  def transfer_player(*args)
    __followingpkmn__transfer_player(*args)
    leader = $game_player
    FollowingPkmn.refresh(false)
    $game_temp.followers.each_follower do |event, follower|
      pbTurnTowardEvent(event, leader)
      follower.direction = event.direction
      leader = event
    end
  end
  #-----------------------------------------------------------------------------
  # Update Following Pokemon's time_taken for to tracking the happiness increase
  # and hold item
  #-----------------------------------------------------------------------------
  alias __followingpkmn__miniupdate miniupdate unless method_defined?(:__followingpkmn__miniupdate)
  def miniupdate(*args)
    __followingpkmn__miniupdate(*args)
    return if !FollowingPkmn.active?
    FollowingPkmn.increase_time
  end

  # #-----------------------------------------------------------------------------
  # alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  # def update(*args)
  #   __followingpkmn__update(*args)
  #   FollowingPkmn.check_poisoned_follower # Check if the following Pokémon is poisoned
  # end
end

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after using the Pokecenter
#-------------------------------------------------------------------------------
# Queue a Pokecenter refresh if the Following Pokemon is active and the player
# heals at a PokeCenter
alias __followingpkmn__pbSetPokemonCenter pbSetPokemonCenter unless defined?(__followingpkmn__pbSetPokemonCenter)
def pbSetPokemonCenter(*args)
  ret = __followingpkmn__pbSetPokemonCenter(*args)
  $game_temp.pokecenter_following_pkmn = 1  if FollowingPkmn::SHOW_POKECENTER_ANIMATION && FollowingPkmn.active?
  return ret
end

class Interpreter
  #-----------------------------------------------------------------------------
  # Toggle Following Pokemon off if a Pokecenter refresh is queued and the
  # Pokemon are healed
  #-----------------------------------------------------------------------------
  alias __followingpkmn__command_314 command_314 unless method_defined?(:__followingpkmn__command_314)
  def command_314(*args)
    ret = __followingpkmn__command_314(*args)
    if FollowingPkmn::SHOW_POKECENTER_ANIMATION && $game_temp.pokecenter_following_pkmn > 0 &&
      FollowingPkmn.active?
      FollowingPkmn.toggle_off
      $game_temp.pokecenter_following_pkmn = 2
    end
    return ret
  end
  #-----------------------------------------------------------------------------
  # Refresh Following Pokemon after using the Pokecenter healing event is
  # completely done
  #-----------------------------------------------------------------------------
  alias __followingpkmn__update update unless method_defined?(:__followingpkmn__update)
  def update(*args)
    __followingpkmn__update(*args)
    if FollowingPkmn::SHOW_POKECENTER_ANIMATION && $game_temp.pokecenter_following_pkmn > 0 && !running?
      FollowingPkmn.toggle_on
      $game_temp.pokecenter_following_pkmn = 0
    end
  end
  #-----------------------------------------------------------------------------
end

# Reset the queued pokecenter refresh if nothing changed
EventHandlers.add(:on_enter_map, :pokecenter_follower_reset, proc { |_old_map_id|
  $game_temp.pokecenter_following_pkmn = 0
})

#-------------------------------------------------------------------------------
# Refresh Following Pokemon after taking a step, when a refresh is queued
#-------------------------------------------------------------------------------
EventHandlers.add(:on_player_step_taken, :forced_follower_refresh, proc {
  next if !$PokemonGlobal.call_refresh[0]
  # Wait for steps
  if $PokemonGlobal.call_refresh[2] && $PokemonGlobal.call_refresh[2] > 0
    $PokemonGlobal.call_refresh[2] -= 1
    $PokemonGlobal.call_refresh.delete_at(2) if $PokemonGlobal.call_refresh[2] == 0
    next
  end
  # Refresh queued
  FollowingPkmn.refresh($PokemonGlobal.call_refresh[1])
  $PokemonGlobal.call_refresh = false
})


EventHandlers.add(:on_player_step_taken, :forced_follower_refresh, proc {
  if !$player.party.empty?
    FollowingPkmn.check_poisoned_follower
  end
})
