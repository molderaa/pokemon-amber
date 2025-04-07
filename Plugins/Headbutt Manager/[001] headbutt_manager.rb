class Game_System
  attr_accessor :headbutt_tree_data

  alias fourth_original_initialize initialize
  def initialize
    fourth_original_initialize
    @headbutt_tree_data ||= {}
  end
end

class HeadbuttTrees
  attr_accessor :timer
  attr_accessor :map_id
  attr_accessor :event_id

  def initialize(map_id, event_id, event)
    @timer = nil
    @map_id = map_id
    @event_id = event_id
    @event = event
  end

  def headbutt_tree
    if pbHeadbutt
      # puts $game_system.headbutt_tree_data ###
      random_time = 270 #30 * 60 + rand(30) * 60
      @timer = pbGetTimeNow + random_time
      save_headbutt_tree_data
      return true
    else
      return false
    end
  end

  def save_headbutt_tree_data
    $game_system.headbutt_tree_data ||= {}
    $game_system.headbutt_tree_data[@map_id] ||= {}
    $game_system.headbutt_tree_data[@map_id][@event_id] = {
      timer: @timer.to_i,
    }
  end

  def self.load_headbutt_tree_data(map_id, event_id)
    $game_system.headbutt_tree_data ||= {}
    if $game_system.headbutt_tree_data.dig(map_id, event_id)
      data = $game_system.headbutt_tree_data[map_id][event_id]
      return data[:timer]
    end
    return nil
  end

  def headbutt_ready?
    # puts $game_system.headbutt_tree_data ###
    return false if @timer.nil?
    return pbGetTimeNow.to_i >= @timer.to_i
  end

  def clear_headbutt_tree_data
    if $game_system.headbutt_tree_data[@map_id]
      $game_system.headbutt_tree_data[@map_id].delete(@event_id)
      # Clean up the map's hash if it's empty
      $game_system.headbutt_tree_data.delete(@map_id) if $game_system.headbutt_tree_data[@map_id].empty?
    end
  end
end

# def pbHeadbuttTree
#   map_id = $game_map.map_id
#   event = $game_player.pbFacingEvent(true)
#   event_id = event.id

#   timer = HeadbuttTrees.load_headbutt_tree_data(map_id, event_id)
#   tree = HeadbuttTrees.new(map_id, event_id, event)
#   tree.timer = timer

#   if timer.nil? || tree.headbutt_ready?
#     tree.timer = nil
#     tree.clear_headbutt_tree_data
#     # puts $game_system.headbutt_tree_data ###
#     tree.headbutt_tree
#   else
#     pbMessage("I should wait a little before headbutting it again.")
#   end
# end

def pbHeadbuttTree
  map_id = $game_map.map_id
  event = $game_player.pbFacingEvent(true)
  return unless event
  event_id = event.id

  timer = HeadbuttTrees.load_headbutt_tree_data(map_id, event_id) # load tree from hash if it exists
  tree = HeadbuttTrees.new(map_id, event_id, event) # create a new tree
  tree.timer = timer

  if timer.nil? # If there's no timer, the tree hasn't been headbutted before
    tree.headbutt_tree # Perform the headbutt action
  elsif tree.headbutt_ready? # If the timer exists and the tree is ready
    tree.timer = nil
    tree.clear_headbutt_tree_data
    tree.headbutt_tree
  else # The tree is still on cooldown
    pbMessage("I should wait a little before headbutting it again.")
  end
end
