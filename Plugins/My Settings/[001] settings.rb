###################################################################
# POISON AND HM SETTINGS
###################################################################

module Settings
  class << self
    alias_method :mypokedex_names, :pokedex_names
  end

  def self.pokedex_names
    return [_INTL("National Pokédex")]
  end

  POISON_IN_FIELD = 1
  POISON_FAINT_IN_FIELD = 1

  FOREIGN_HIGH_LEVEL_POKEMON_CAN_DISOBEY = false

  BADGE_FOR_CUT       = 3
  BADGE_FOR_FLASH     = 5
  BADGE_FOR_ROCKSMASH = 1
  BADGE_FOR_SURF      = 4
  BADGE_FOR_FLY       = 2
  BADGE_FOR_STRENGTH  = 6
  BADGE_FOR_DIVE      = 7
  BADGE_FOR_WATERFALL = 8
end

###################################################################
# INTRO SCREEN SETTINGS
###################################################################

class IntroEventScene < EventScene
  SPLASH_IMAGES         = []
  SECONDS_PER_SPLASH    = 0
end

###################################################################
# WILD AI SETTINGS
###################################################################

class Battle::AI::AITrainer
  attr_reader :side, :trainer_index
  attr_reader :skill

  def initialize(ai, side, index, trainer)
    @ai            = ai
    @side          = side
    @trainer_index = index
    @trainer       = trainer
    @skill         = 100
    @skill_flags   = []
    set_up_skill
    set_up_skill_flags
    sanitize_skill_flags
  end
end

###################################################################
# ENCOUNTER ANIMATION RESET SETTINGS
###################################################################

class Game_Character
  def reset_to_standing
    @pattern = @original_pattern   # Reset to the standing pattern
    @anime_count = 0               # Reset the animation timer
    @moved_last_frame = false      # Mark as not moving
    @stopped_this_frame = true     # Mark as stopped
  end
end

def pbBattleOnStepTaken(repel_active)
  return if $player.able_pokemon_count == 0
  return if !$PokemonEncounters.encounter_possible_here?
  encounter_type = $PokemonEncounters.encounter_type
  return if !encounter_type
  return if !$PokemonEncounters.encounter_triggered?(encounter_type, repel_active)

  # Reset the player's animation to standing before the encounter
  $game_player.reset_to_standing

  $game_temp.encounter_type = encounter_type
  encounter = $PokemonEncounters.choose_wild_pokemon(encounter_type)
  EventHandlers.trigger(:on_wild_species_chosen, encounter)
  if $PokemonEncounters.allow_encounter?(encounter, repel_active)
    if $PokemonEncounters.have_double_wild_battle?
      encounter2 = $PokemonEncounters.choose_wild_pokemon(encounter_type)
      EventHandlers.trigger(:on_wild_species_chosen, encounter2)
      WildBattle.start(encounter, encounter2, can_override: true)
    else
      WildBattle.start(encounter, can_override: true)
    end
    $game_temp.encounter_type = nil
    $game_temp.encounter_triggered = true
  end
  $game_temp.force_single_battle = false
end

###################################################################
# TRIAD CARD PRICE SETTINGS
###################################################################

class TriadCard
  def price
    maxValue = [@north, @east, @south, @west].max
    ret = maxValue * 5
    return ret
  end
end

###################################################################
# REMOVE BUMPING SETTINGS
###################################################################

class Game_Player < Game_Character
  def stop_movement_animation
    @move_timer = nil  # Ensure no movement animation timer is active
    @pattern = 0       # Set sprite to standing frame
    @step_anime = false # Disable stepping animation
  end  
  
  def move_generic(dir, turn_enabled = true)
    turn_generic(dir, true) if turn_enabled
    if !$game_temp.encounter_triggered
      if can_move_in_direction?(dir)
        # puts "passable"
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        # Jump over ledges
        if pbFacingTerrainTag.ledge
          if jumpForward(2)
            pbSEPlay("Player jump")
            increase_steps
          end
          return
        elsif pbFacingTerrainTag.waterfall_crest && dir == 2
          $PokemonGlobal.descending_waterfall = true
          $game_player.through = true
          $stats.waterfalls_descended += 1
        end
        # Jumping out of surfing back onto land
        return if pbEndSurf(x_offset, y_offset)
        # General movement
        turn_generic(dir, true)
        if !$game_temp.encounter_triggered
          @move_initial_x = @x
          @move_initial_y = @y
          @x += x_offset
          @y += y_offset
          @move_timer = 0.0
          add_move_distance_to_stats(x_offset.abs + y_offset.abs)
          increase_steps
        end
      elsif !check_event_trigger_touch(dir)
        # puts "impassable"
        stop_movement_animation
        # bump_into_object
      end
    end
    $game_temp.encounter_triggered = false
  end
end

###################################################################
# FOREIGN POKEMON OBEDIENCE SETTINGS
###################################################################

class Battle::Battler
  def pbObedienceCheck?(choice)
    return true if usingMultiTurnAttack?
    return true if choice[0] != :UseMove
    return true if !@battle.internalBattle
    return true if !@battle.pbOwnedByPlayer?(@index)
    disobedient = false
    # Pokémon may be disobedient; calculate if it is
    badge_level = 10 * (@battle.pbPlayer.badge_count + 1)
    badge_level = GameData::GrowthRate.max_level if @battle.pbPlayer.badge_count >= 8
    if Settings::ANY_HIGH_LEVEL_POKEMON_CAN_DISOBEY ||
       (Settings::FOREIGN_HIGH_LEVEL_POKEMON_CAN_DISOBEY && @pokemon.foreign?(@battle.pbPlayer))
      if @level > badge_level
        a = ((@level + badge_level) * @battle.pbRandom(256) / 256).floor
        disobedient |= (a >= badge_level)
      end
    end
    disobedient |= !pbHyperModeObedience(choice[2])
    return true if !disobedient
    # Pokémon is disobedient; make it do something else
    return pbDisobey(choice, badge_level)
  end
end

###################################################################
# POKEMON HAPPINESS SETTINGS
###################################################################

# class Pokemon
#   def changeHappiness(method)
#     gain = 0
#     happiness_range = @happiness / 100
#     case method
#     when "walking"
#       gain = [2, 2, 1][happiness_range]
#     when "levelup"
#       gain = [5, 4, 3][happiness_range]
#     when "groom"
#       gain = [10, 10, 4][happiness_range]
#     when "evberry"
#       gain = [10, 5, 2][happiness_range]
#     when "vitamin"
#       gain = [5, 3, 2][happiness_range]
#     when "wing"
#       gain = [3, 2, 1][happiness_range]
#     when "machine", "battleitem"
#       gain = [1, 1, 0][happiness_range]
#     when "faint"
#       gain = -8
#     when "faintbad"   # Fainted against an opponent that is 30+ levels higher
#       gain = [-5, -5, -10][happiness_range]
#     when "powder"
#       gain = [-5, -5, -10][happiness_range]
#     when "energyroot"
#       gain = [-10, -10, -15][happiness_range]
#     when "revivalherb"
#       gain = [-15, -15, -20][happiness_range]
#     else
#       raise _INTL("Unknown happiness-changing method: {1}", method.to_s)
#     end
#     if gain > 0
#       gain += 1 if @obtain_map == $game_map.map_id
#       gain += 1 if @poke_ball == :LUXURYBALL
#       gain = (gain * 1.5).floor if hasItem?(:SOOTHEBELL)
#       if Settings::APPLY_HAPPINESS_SOFT_CAP && method != "evberry"
#         gain = (@happiness >= 179) ? 0 : gain.clamp(0, 179 - @happiness)
#       end
#     end
#     @happiness = (@happiness + gain).clamp(0, 255)
#   end
# end

###################################################################
# PICKUP ABILITY SETTINGS
###################################################################

PICKUP_COMMON_ITEMS = [
  :POTION,        # Levels 1-10
  :ANTIDOTE,      # Levels 1-10, 11-20
  :SUPERPOTION,   # Levels 1-10, 11-20, 21-30
  :REPEL,         # Levels 1-10, 11-20, 21-30, 31-40, 41-50
  :ESCAPEROPE,    # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60
  :FULLHEAL,      # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70
  :HYPERPOTION,   # Levels 1-10, 11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80
  :REVIVE,        # Levels       11-20, 21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :RARECANDY,     # Levels              21-30, 31-40, 41-50, 51-60, 61-70, 71-80, 81-90, 91-100
  :FULLRESTORE,   # Levels                                          61-70, 71-80, 81-90, 91-100
  :MAXREVIVE,     # Levels                                                 71-80, 81-90, 91-100
  :PPUP,          # Levels                                                        81-90, 91-100
  :MAXELIXIR      # Levels                                                               91-100
]

PICKUP_RARE_ITEMS = [
  :HYPERPOTION,   # Levels 1-10
  :NUGGET,        # Levels 1-10, 11-20
  :FULLRESTORE,   # Levels              21-30, 31-40
  :ETHER,         # Levels                     31-40, 41-50
  :IRONBALL,      # Levels                            41-50, 51-60
  :DESTINYKNOT,   # Levels                                   51-60, 61-70
  :ELIXIR,        # Levels                                          61-70, 71-80
  :DESTINYKNOT,   # Levels                                                 71-80, 81-90
  :LEFTOVERS,     # Levels                                                        81-90, 91-100
  :DESTINYKNOT    # Levels                                                               91-100
]

###################################################################
# BERRY PLANT SPARKLE ANIMATION SETTINGS
###################################################################

PLANT_SPARKLE_ANIMATION_ID   = 8

###################################################################
# SAVE SETTINGS
###################################################################

class PokemonSaveScreen
  def initialize(scene)
    @scene = scene
  end

  def pbDisplay(text, brief = false)
    @scene.pbDisplay(text, brief)
  end

  def pbDisplayPaused(text)
    @scene.pbDisplayPaused(text)
  end

  def pbConfirm(text)
    return @scene.pbConfirm(text)
  end

  def pbSaveScreen
    ret = false
    @scene.pbStartScreen
    if pbConfirmMessage(_INTL("Would you like to save the game?"))
      if SaveData.exists? && $game_temp.begun_new_game
        pbMessage(_INTL("WARNING!") + "\1")
        pbMessage(_INTL("There is a different game file that is already saved.") + "\1")
        pbMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost.") + "\1")
        if !pbConfirmMessageSerious(_INTL("Are you sure you want to save now and overwrite the other save file?"))
          pbSEPlay("GUI save choice")
          @scene.pbEndScreen
          return false
        end
      end
      $game_temp.begun_new_game = false
      pbSEPlay("GUI save choice")
      if Game.save
        pbMessage("\\se[]" + _INTL("{1} saved the game.", $player.name) + "\\me[GUI save game]\\wtnp[20]")
        ret = true
      else
        pbMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
        ret = false
      end
    else
      pbSEPlay("GUI save choice")
    end
    @scene.pbEndScreen
    return ret
  end

  def pbSaveScreenCustom
    ret = false
    @scene.pbStartScreen
    $game_temp.begun_new_game = false
    pbSEPlay("GUI save choice")
    if Game.save
      pbMessage("\\se[]" + _INTL("{1} saved the game.", $player.name) + "\\me[GUI save game]\\wtnp[20]")
      ret = true
    else
      pbMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
      ret = false
    end
    @scene.pbEndScreen
    return ret
  end
end

def pbSaveScreenCustom
  scene = PokemonSave_Scene.new
  screen = PokemonSaveScreen.new(scene)
  ret = screen.pbSaveScreenCustom
  return ret
end

###################################################################
# POISON FLASH COLOR
###################################################################

EventHandlers.add(:on_player_step_taken_can_transfer, :poison_party,
  proc { |handled|
    # handled is an array: [nil]. If [true], a transfer has happened because of
    # this event, so don't do anything that might cause another one
    next if handled[0]
    next if !Settings::POISON_IN_FIELD || $PokemonGlobal.stepcount % 4 != 0
    flashed = false
    $player.able_party.each do |pkmn|
      next if pkmn.status != :POISON || pkmn.hasAbility?(:IMMUNITY)
      if !flashed
        pbSEPlay("Poison step")
        pbFlash(Color.new(0, 0, 0, 128), 8)
        flashed = true
      end
      pkmn.hp -= 1 if pkmn.hp > 1 || Settings::POISON_FAINT_IN_FIELD
      if pkmn.hp == 1 && !Settings::POISON_FAINT_IN_FIELD
        pkmn.status = :NONE
        pbMessage(_INTL("{1} survived the poisoning.\\nThe poison faded away!", pkmn.name))
        next
      elsif pkmn.hp == 0
        pkmn.changeHappiness("faint")
        pkmn.status = :NONE
        pbMessage(_INTL("{1} fainted...", pkmn.name))
      end
      if $player.able_pokemon_count == 0
        handled[0] = true
        pbCheckAllFainted
      end
    end
  }
)
