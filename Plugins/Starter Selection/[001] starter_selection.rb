def pbStarterSelect

  event = $game_player.pbFacingEvent(true)
  event_id = event.id

  pbMoveRoute(event, [
    PBMoveRoute::GRAPHIC, "starterselect", 0, 2, 1,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "starterselect", 0, 2, 2,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "starterselect", 0, 2, 3,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 1,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 2,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 3
  ])

  pbWait(0.7)

  DiegoWTsStarterSelection.new($game_variables[27],$game_variables[28],$game_variables[29])

  # $game_self_switches[[ $game_map.map_id, event_id, "A" ]] = true

  case $game_variables[7]
  when 1
    pbMoveRoute(event, [
      PBMoveRoute::GRAPHIC, "starterselect", 0, 6, 1,
      PBMoveRoute::WAIT, 10,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 2,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 1,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 0
    ])
  when 2
    pbMoveRoute(event, [
      PBMoveRoute::GRAPHIC, "starterselect", 0, 6, 0,
      PBMoveRoute::WAIT, 10,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 6, 3,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 1,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 0
    ])
  when 3
    pbMoveRoute(event, [
      PBMoveRoute::GRAPHIC, "starterselect", 0, 6, 2,
      PBMoveRoute::WAIT, 10,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 8, 0,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 1,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "starterselect", 0, 4, 0
    ])
  end

  pbWait(0.7)

  # $game_self_switches[[ $game_map.map_id, event_id, "A" ]] = true
  # $game_map.need_refresh = true
  
  $game_variables[27] = nil
  $game_variables[28] = nil
  $game_variables[29] = nil

  $game_switches[3] = false

end
