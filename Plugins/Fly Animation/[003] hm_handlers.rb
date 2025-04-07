# HiddenMoveHandlers::UseMove.add(:FLY,proc { |move, pokemon|
#    if $game_temp.fly_destination.nil?
#   pbMessage(_INTL("You can't use that here."))
#     next false
#   end
#   if !pbHiddenMoveAnimation(pokemon)
#     name = pokemon&.name || $player.name 
#     move = :FLY
#     pbMessage(_INTL("{1} used {2}!", name, GameData::Move.get(move).name))
#   end
#   $stats.fly_count += 1
  
#   pbFlyAnimation
#   pbFadeOutIn {
#     $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
#     $game_temp.player_new_x         = $game_temp.fly_destination[1]
#     $game_temp.player_new_y         = $game_temp.fly_destination[2]
#     $game_temp.player_new_direction = 2
#     $game_temp.fly_destination = nil
#     $scene.transfer_player
#     # $game_map.autoplay
#     # $game_map.refresh
#   }
#   # pbMoveRoute($game_player, [
#   #   PBMoveRoute::WAIT, 9,
#   #   PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 0,
#   #   PBMoveRoute::WAIT, 1,
#   #   PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 1,
#   #   PBMoveRoute::WAIT, 1,
#   #   PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 2,
#   #   PBMoveRoute::WAIT, 1,
#   #   PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 3,
#   #   PBMoveRoute::WAIT, 1,
#   #   PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 4, 0,
#   #   PBMoveRoute::WAIT, 1,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 2, 0,
#   #   PBMoveRoute::WAIT, 0.3,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 4, 0,
#   #   PBMoveRoute::WAIT, 0.3,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 6, 0,
#   #   PBMoveRoute::WAIT, 0.3,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 8, 0,
#   #   PBMoveRoute::WAIT, 0.3,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 2, 0,
#   #   PBMoveRoute::WAIT, 0.4,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 4, 0,
#   #   PBMoveRoute::WAIT, 0.5,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 6, 0,
#   #   PBMoveRoute::WAIT, 0.6,
#   #   PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 8, 0,
#   #   PBMoveRoute::WAIT, 1,
#   #   PBMoveRoute::GRAPHIC, "trainer_POKEMONTRAINER_Red", 0, 2, 0
#   # ])

#   pbFlyAnimation(false)
#   pbEraseEscapePoint
  
#   puts "move route started"
#   pbMoveRoute($game_player, [
#     PBMoveRoute::WAIT, 9,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 2, 0,
#     PBMoveRoute::WAIT, 0.5,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 4, 0,
#     PBMoveRoute::WAIT, 0.5,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 6, 0,
#     PBMoveRoute::WAIT, 0.5,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 8, 0,
#     PBMoveRoute::WAIT, 0.6,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 2, 0,
#     PBMoveRoute::WAIT, 0.7,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 4, 0,
#     PBMoveRoute::WAIT, 0.8,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 6, 0,
#     PBMoveRoute::WAIT, 0.9,
#     PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 8, 0,
#     PBMoveRoute::WAIT, 1,
#     PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 4, 0,
#     PBMoveRoute::WAIT, 5,
#     PBMoveRoute::GRAPHIC, "trainer_POKEMONTRAINER_Red", 0, 2, 0
#   ])

#   next true
# })


HiddenMoveHandlers::UseMove.add(:FLY, proc { |move, pokemon|
  if $game_temp.fly_destination.nil?
    pbMessage(_INTL("You can't use that here."))
    next false
  end
  if !pbHiddenMoveAnimation(pokemon)
    name = pokemon&.name || $player.name 
    move = :FLY
    pbMessage(_INTL("{1} used {2}!", name, GameData::Move.get(move).name))
  end

  $stats.fly_count += 1

  pbUpdateSceneMap
  FollowingPkmn.toggle

  pbFlyAnimation
  pbFadeOutIn {
    $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
    $game_temp.player_new_x         = $game_temp.fly_destination[1]
    $game_temp.player_new_y         = $game_temp.fly_destination[2]
    $game_temp.player_new_direction = 2
    $game_temp.fly_destination = nil
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
  }

  pbFlyAnimation(false)
  pbEraseEscapePoint

  $game_system.menu_disabled = true

  # Animation logic
  puts "move route started"
  pbMoveRoute($game_player, [
    PBMoveRoute::WAIT, 9,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 2, 0,
    PBMoveRoute::WAIT, 0.5,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 4, 0,
    PBMoveRoute::WAIT, 0.5,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 6, 0,
    PBMoveRoute::WAIT, 0.5,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturn", 0, 8, 0,
    PBMoveRoute::WAIT, 0.6,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 2, 0,
    PBMoveRoute::WAIT, 0.7,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 4, 0,
    PBMoveRoute::WAIT, 0.8,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 6, 0,
    PBMoveRoute::WAIT, 0.9,
    PBMoveRoute::GRAPHIC, "boy_UseFlyReturnEND", 0, 8, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 4, 0,
    PBMoveRoute::WAIT, 5,
    PBMoveRoute::GRAPHIC, "trainer_POKEMONTRAINER_Red", 0, 2, 0
  ])

  pbWait(1.5)

  pbUpdateSceneMap
  FollowingPkmn.toggle

  # Re-enable menu access
  $game_system.menu_disabled = false

  next true
})
