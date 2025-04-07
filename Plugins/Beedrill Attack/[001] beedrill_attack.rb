def pbBeedrillAttack
  player_position_x = $game_player.x
  player_position_y = $game_player.y
  player_direction = $game_player.direction

  beedrill = $game_map.events[8]
  beedrill_position_x = beedrill.x
  beedrill_position_y = beedrill.y
  beedrill_direction = beedrill.direction

  loop do
    if beedrill_position_x < player_position_x
      pbMoveRoute(beedrill, [PBMoveRoute::CHANGE_SPEED, 6, PBMoveRoute::RIGHT])
    end

    if beedrill_position_x > player_position_x
      pbMoveRoute(beedrill, [PBMoveRoute::CHANGE_SPEED, 6, PBMoveRoute::LEFT])
    end

    if beedrill_position_x == player_position_x
      break
    end
    
    beedrill_position_x = beedrill.x
    beedrill_position_y = beedrill.y
    
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  loop do
    if beedrill_position_y < (player_position_y - 1)
      pbMoveRoute(beedrill, [PBMoveRoute::CHANGE_SPEED, 6, PBMoveRoute::DOWN])
    end

    if beedrill_position_y == (player_position_y - 1)
      # pbMoveRoute(beedrill, [
      #   PBMoveRoute::CHANGE_SPEED, 5,
      #   PBMoveRoute::TURN_LEFT,
      #   PBMoveRoute::LEFT,
      #   PBMoveRoute::TURN_DOWN,
      #   PBMoveRoute::DOWN,
      #   PBMoveRoute::DOWN,
      #   PBMoveRoute::TURN_RIGHT,
      #   PBMoveRoute::RIGHT,
      #   PBMoveRoute::RIGHT,
      #   PBMoveRoute::TURN_UP,
      #   PBMoveRoute::UP,
      #   PBMoveRoute::UP,
      #   PBMoveRoute::TURN_LEFT,
      #   PBMoveRoute::LEFT,
      #   PBMoveRoute::TURN_TOWARD_PLAYER
      # ])
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break
    end

    beedrill_position_x = beedrill.x
    beedrill_position_y = beedrill.y
    
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end

  pbWait(0.5)

  # pkmn = Pokemon.new(:BEEDRILL, 13)
  # pkmn.form = 2
  setBattleRule("editWildPokemon", {
    :form => 2,
    :nature => :ADAMANT,
    :hp_level => 2,
    :moves => [:TWINEEDLE, :STRINGSHOT, :BUGBITE, :FURYCUTTER]
  })
  setBattleRule("cannotRun")
  setBattleRule("outcome", 42)
  WildBattle.start(:BEEDRILL, 13)

  $game_self_switches[[$game_map.map_id, 8, 'A']] = true
  $game_map.need_refresh = true
end
