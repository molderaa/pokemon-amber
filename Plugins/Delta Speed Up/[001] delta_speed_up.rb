#===============================================================================
# Battle Speedup Script for Pokémon Essentials v21.1
# Credits to Mashirosakura for making the original script
# Edited by SkyHarvester
# Whether the options menu shows the speed up settings (true by default)
#===============================================================================
module Settings
  SPEED_OPTIONS = true
end
#===============================================================================
# Speed-up config
#===============================================================================
SPEEDUP_STAGES = [1, 1.5, 2]
$GameSpeed = 0
# $CanToggle = false
#===============================================================================
# Set $CanToggle depending on the saved setting
#===============================================================================
# module Game
#   class << self
#     alias_method :original_load, :load unless method_defined?(:original_load)
#   end

#   def self.load(save_data)
#     original_load(save_data)
#     $CanToggle = false
#   end
# end

# module Game
#   class << self
#     alias_method :original_load, :load unless method_defined?(:original_load)
#   end

#   def self.load(save_data)
#     original_load(save_data)
#     $GameSpeed = $PokemonSystem.game_speed if $PokemonSystem
#   end
# end

module Game
  class << self
    alias_method :original_start_new, :start_new unless method_defined?(:original_start_new)
    alias_method :original_load, :load unless method_defined?(:original_load)
  end

  def self.start_new
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $game_temp.begun_new_game = true
    pbMapInterpreter&.clear
    pbMapInterpreter&.setup(nil, 0, 0)
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $game_temp.last_uptime_refreshed_play_time = System.uptime
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  
    # Initialize or reset game speed on new game start
    $GameSpeed = $PokemonSystem.game_speed || 0
    $PokemonSystem.battle_speed ||= 0
  end  

  def self.load(save_data)
    original_load(save_data)
    $GameSpeed = $PokemonSystem.game_speed || 0
    $PokemonSystem.battle_speed ||= 0
  end
end

#===============================================================================
# Handle incrementing speed stages if $CanToggle allows it
#===============================================================================
# module Input
#   def self.update
#     update_KGC_ScreenCapture
#     pbScreenCapture if trigger?(Input::F8)
#     if $CanToggle && trigger?(Input::AUX1)
#       $GameSpeed += 1
#       $GameSpeed = 0 if $GameSpeed >= SPEEDUP_STAGES.size
#       $PokemonSystem.battle_speed = $GameSpeed if $PokemonSystem
#     end
#   end
# end
#===============================================================================
# Return System.Uptime with a multiplier to create an alternative timeline
#===============================================================================
module System
  class << self
    alias_method :unscaled_uptime, :uptime unless method_defined?(:unscaled_uptime)
  end

  def self.uptime
    return SPEEDUP_STAGES[$GameSpeed] * unscaled_uptime
  end
end

#===============================================================================
# Event handlers for in-battle speed-up restrictions
#===============================================================================
# EventHandlers.add(:on_start_battle, :start_speedup, proc {
#   $CanToggle = true
#   $GameSpeed = $PokemonSystem.battle_speed if $PokemonSystem
# })
# EventHandlers.add(:on_end_battle, :stop_speedup, proc {
#   $GameSpeed = 0
#   $CanToggle = false
# })

EventHandlers.add(:on_start_battle, :start_speedup, proc {
  $CanToggle = true
  $GameSpeed = $PokemonSystem.battle_speed if $PokemonSystem
})
EventHandlers.add(:on_end_battle, :stop_speedup, proc {
  # Persist the current game speed in the system settings
  $PokemonSystem.battle_speed = $GameSpeed if $PokemonSystem
  $CanToggle = false
})

#===============================================================================
# Can only change speed in battle during command phase (prevents weird animation glitches)
#===============================================================================
class Battle
  alias_method :original_pbCommandPhase, :pbCommandPhase unless method_defined?(:original_pbCommandPhase)
  def pbCommandPhase
    $CanToggle = true
    original_pbCommandPhase
    $CanToggle = false
  end
end
#===============================================================================
# Fix for consecutive battle soft-lock glitch
#===============================================================================
alias :original_pbBattleOnStepTaken :pbBattleOnStepTaken
def pbBattleOnStepTaken(repel_active)
  return if $game_temp.in_battle
  original_pbBattleOnStepTaken(repel_active)
end
#===============================================================================
# Fix for scrolling fog speed
#===============================================================================
class Game_Map
  alias_method :original_update, :update unless method_defined?(:original_update)

  def update
    temp_timer = @fog_scroll_last_update_timer
    @fog_scroll_last_update_timer = System.uptime # Don't scroll in the original update method
    original_update
    @fog_scroll_last_update_timer = temp_timer
    update_fog
  end

  def update_fog
    uptime_now = System.unscaled_uptime
    @fog_scroll_last_update_timer = uptime_now unless @fog_scroll_last_update_timer
    speedup_mult = SPEEDUP_STAGES[$GameSpeed]
    scroll_mult = (uptime_now - @fog_scroll_last_update_timer) * 5 * speedup_mult
    @fog_ox -= @fog_sx * scroll_mult
    @fog_oy -= @fog_sy * scroll_mult
    @fog_scroll_last_update_timer = uptime_now
  end
end
#===============================================================================
# Fix for animation index crash
#===============================================================================
class SpriteAnimation
  def update_animation
    new_index = ((System.uptime - @_animation_timer_start) / @_animation_time_per_frame).to_i
    if new_index >= @_animation_duration
      dispose_animation
      return
    end
    quick_update = (@_animation_index == new_index)
    @_animation_index = new_index
    frame_index = @_animation_index
    current_frame = @_animation.frames[frame_index]
    unless current_frame
      dispose_animation
      return
    end
    cell_data   = current_frame.cell_data
    position    = @_animation.position
    animation_set_sprites(@_animation_sprites, cell_data, position, quick_update)
    return if quick_update
    @_animation.timings.each do |timing|
      next if timing.frame != frame_index
      animation_process_timing(timing, @_animation_hit)
    end
  end
end
#===============================================================================
# PokemonSystem Accessors
#===============================================================================
# class PokemonSystem
#   alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
#   attr_accessor :battle_speed

#   def initialize
#     original_initialize
#     @battle_speed = 0 # Depends on the SPEEDUP_STAGES array size
#   end
# end

class PokemonSystem
  alias_method :original_initialize, :initialize unless method_defined?(:original_initialize)
  attr_accessor :battle_speed
  attr_accessor :game_speed

  def initialize
    original_initialize
    @battle_speed = 0 # Battle speed setting
    @game_speed = 0   # General game speed setting
  end
end

#===============================================================================
# Options menu handlers
#===============================================================================
# MenuHandlers.add(:options_menu, :battle_speed, {
#   "name" => _INTL("Battle Speed"),
#   "order" => 25,
#   "type" => EnumOption,
#   "parameters" => [_INTL("Normal"), _INTL("Fast"), _INTL("Faster")],
#   "description" => _INTL("Choose the battle speed when the battle speed-up is active."),
#   "get_proc" => proc { next $PokemonSystem.battle_speed },
#   "set_proc" => proc { |value, scene|
#     $PokemonSystem.battle_speed = value
#   }
# })

MenuHandlers.add(:options_menu, :game_speed, {
  "name" => _INTL("Game Speed"),
  "order" => 24, # Adjust the order as needed
  "type" => EnumOption,
  "parameters" => [_INTL("Normal"), _INTL("Fast"), _INTL("Faster")],
  "description" => _INTL("Set the game speed globally."),
  "get_proc" => proc { next $PokemonSystem.game_speed },
  "set_proc" => proc { |value, scene|
    $PokemonSystem.game_speed = value
    $GameSpeed = value # Update the global speed immediately
  }
})

MenuHandlers.add(:options_menu, :battle_speed, {
  "name" => _INTL("Battle Speed"),
  "order" => 25,
  "type" => EnumOption,
  "parameters" => [_INTL("Normal"), _INTL("Fast"), _INTL("Faster")],
  "description" => _INTL("Choose the battle speed when the battle speed-up is active."),
  "get_proc" => proc { next $PokemonSystem.battle_speed },
  "set_proc" => proc { |value, scene|
    $PokemonSystem.battle_speed = value
  }
})

#===============================================================================
# Initialize game speed on startup
#===============================================================================
EventHandlers.add(:on_start_game, :initialize_game_speed, proc {
  $GameSpeed = $PokemonSystem.game_speed || 0
  $PokemonSystem.battle_speed ||= 0
})
