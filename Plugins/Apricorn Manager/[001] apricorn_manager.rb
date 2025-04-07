class Game_System
  attr_accessor :apricorn_trees

  alias second_original_initialize initialize
  def initialize
    second_original_initialize
    @apricorn_trees = []
  end
end


module ApricornManager
  # def self.apricorn_trees
  #   $game_system.apricorn_trees ||= []
  #   return $game_system.apricorn_trees
  # end

  # def self.add_apricorn(map_id, event_id)
  #   existing = apricorn_trees.find { |tree| tree[:map_id] == map_id && tree[:event_id] == event_id }
  #   return if existing

  #   apricorn_trees.push({ map_id: map_id, event_id: event_id, regrow_time: 0 })
  # end

  # def self.set_regrow_time(map_id, event_id, time)
  #   tree = apricorn_trees.find { |tree| tree[:map_id] == map_id && tree[:event_id] == event_id }
  #   return unless tree
  #   tree[:regrow_time] = time
  # end

  # def self.all_apricorns
  #   return apricorn_trees
  # end

  def self.reset_apricorn(tree)
    $game_self_switches[[tree[:map_id], tree[:event_id], 'A']] = false
  end
end


def pbApricornTree(apricorn)
  pbItemBall(apricorn)
  # Ensure apricorn_trees is initialized
  $game_system.apricorn_trees ||= []
  
  # Register this apricorn tree in the game system directly
  apricorn_tree = { map_id: $game_map.map_id, event_id: @event_id, regrow_time: 0 }
  $game_system.apricorn_trees.push(apricorn_tree)

  # Set the regrow time when the apricorn is picked
  current_time = pbGetTimeNow.to_i
  regrow_time = current_time + 30 * 60 + rand(10) * 60
  apricorn_tree[:regrow_time] = regrow_time

  # Disable the tree by turning on Self Switch A
  $game_self_switches[[$game_map.map_id, @event_id, 'A']] = true
  # $game_map.refresh
  event = $game_map.events[@event_id]
  event.refresh if event
end


def pbApricornTreeUpdate
  # Get the current time in seconds
  current_time = pbGetTimeNow.to_i
  last_check_time = $game_variables[100] || 0  # Use Variable #100 to track the last check time
  # puts "test"

  # Check if 5 minutes (300 seconds) have passed since the last update
  $game_system.apricorn_trees ||= []
  # if $game_system.apricorn_trees
  if current_time >= last_check_time + 300
    # puts "checking"

    # Loop through all registered apricorn trees stored in game system
    $game_system.apricorn_trees.each do |tree|
      if tree[:regrow_time] > 0 && current_time >= tree[:regrow_time]
        # Reset the apricorn tree
        ApricornManager.reset_apricorn(tree)

        # Remove the tree from the game system's apricorn_trees array
        $game_system.apricorn_trees.delete_if { |t| t[:map_id] == tree[:map_id] && t[:event_id] == tree[:event_id] }

        # Find the event on the map using the map_id and event_id
        event = $game_map.events[tree[:event_id]]

        # Refresh the event if it exists
        event.refresh if event

        # Reset the regrow time to 0 so it won't trigger again
        tree[:regrow_time] = 0
      end
    end

    # $game_map.need_refresh = true

    # Update the last check time to the current time
    $game_variables[100] = current_time
  end
  # else
  #   $game_system.apricorn_trees ||= []
  # end
end

class Scene_Map
  alias __original_update__ update unless method_defined?(:__original_update__)

  def update
    __original_update__  # Call the original update method
    @apricorn_update_timer ||= 0
    @apricorn_update_timer += 1

    # Check every 40 frames (1 second in default Essentials timing)
    if @apricorn_update_timer >= 40
      pbApricornTreeUpdate
      @apricorn_update_timer = 0
    end
  end
end
