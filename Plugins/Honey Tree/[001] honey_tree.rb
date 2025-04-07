GameData::EncounterType.register({
  :id             => :HoneyTree,
  :type           => :none,
})

class Game_System
  attr_accessor :honey_tree_data

  alias original_initialize initialize
  def initialize
    original_initialize
    @honey_tree_data ||= {}
  end
end

class HoneyTree
  attr_accessor :timer
  attr_accessor :has_honey
  attr_accessor :map_id
  attr_accessor :event_id

  def initialize(map_id, event_id, event)
    @timer = nil
    @has_honey = false
    @map_id = map_id
    @event_id = event_id
    @event = event
  end

  def apply_honey
    if @has_honey
      pbMessage("Honey has already been applied to the tree.")
      return false
    else
      choice = pbMessage("Would you like to put honey on the tree?", ["Yes", "No"], -1)
      if choice == 0
        if !$bag.has?(:HONEY)
          pbMessage("You don't have any honey.")
          return false
        end
        $bag.remove(:HONEY)
        pbMessage("You applied Honey to the tree.")
      
        random_time = 30 * 60 + rand(30) * 60
        @timer = pbGetTimeNow + random_time
        @has_honey = true

        save_honey_tree_data  # Save the state in the current game's data
        return true
      end
    end
  end

  def honey_ready?
    return false if @timer.nil? || !@has_honey
    return pbGetTimeNow.to_i >= @timer.to_i
  end

  # Save honey tree data to Game_System instead of a separate file
  def save_honey_tree_data
    $game_system.honey_tree_data ||= {}  # Ensure main data structure is initialized
    $game_system.honey_tree_data[@map_id] ||= {}  # Ensure map data is initialized
    $game_system.honey_tree_data[@map_id][@event_id] = {
      timer: @timer.to_i,
      has_honey: @has_honey
    }
  end

  def self.load_honey_tree_data(map_id, event_id)
    # Ensure honey_tree_data is initialized and the map exists before accessing
    $game_system.honey_tree_data ||= {}  # Initialize if nil
    if $game_system.honey_tree_data.dig(map_id, event_id)
      data = $game_system.honey_tree_data[map_id][event_id]
      return data[:timer], data[:has_honey]
    end
    return nil, false  # Return default values if data doesn't exist
  end

  def clear_honey_tree_data
    if $game_system.honey_tree_data[@map_id]
      $game_system.honey_tree_data[@map_id].delete(@event_id)
      # Clean up the map's hash if it's empty
      $game_system.honey_tree_data.delete(@map_id) if $game_system.honey_tree_data[@map_id].empty?
    end
  end
end

def pbHoneyTree
  map_id = $game_map.map_id
  event = $game_player.pbFacingEvent(true)
  if event.nil?
    pbMessage("There's nothing to interact with.")
    return
  end

  event_id = event.id
  timer, has_honey = HoneyTree.load_honey_tree_data(map_id, event_id)
  
  # If the tree exists in the saved data, load it; otherwise, create a new one
  tree = HoneyTree.new(map_id, event_id, event)
  tree.timer = timer
  tree.has_honey = has_honey

  if tree.honey_ready?
    pbMessage("A Pokémon was attracted to the honey!")
    # WildBattle.start(:COMBEE, 10)  # Example battle; modify as needed
    pbEncounter(:HoneyTree)
    tree.has_honey = false
    tree.timer = nil
    # tree.save_honey_tree_data
    tree.clear_honey_tree_data
  else
    tree.apply_honey
  end
end
