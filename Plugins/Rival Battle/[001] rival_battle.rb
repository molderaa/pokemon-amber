def pbFirstRivalBattle
  rival = $game_map.events[19]

  player = $game_player

  player_position_x = $game_player.x
  player_position_y = $game_player.y
  player_direction = $game_player.direction

  loop do
    if rival.x < player_position_x - 1
      pbMoveRoute(rival, [PBMoveRoute::RIGHT])

      Graphics.update
      Input.update
      pbUpdateSceneMap
    else
      break
    end
  end

  loop do
    if rival.y < player_position_y
      pbMoveRoute(rival, [PBMoveRoute::DOWN])
      Graphics.update
      Input.update
      pbUpdateSceneMap
    elsif rival.y > player_position_y
      pbMoveRoute(rival, [PBMoveRoute::UP])
      Graphics.update
      Input.update
      pbUpdateSceneMap
    else
      # puts "loop broken"
      break
    end
  end

  pbMoveRoute(player, [PBMoveRoute::TURN_LEFT])
  pbMoveRoute(rival, [PBMoveRoute::TURN_TOWARD_PLAYER])

  pbWait(1)
  pbMessage("\\xn[Blue]You a trainer?")
  pbMessage("\\xn[Blue]You're from Oros Town?")
  pbMessage("\\xn[Blue]And you beat Slate?")
  pbMessage("\\xn[Blue]You think you're hot shit?")
  pbMessage("\\xn[Blue]Guess I'll have to put you in your place.")

  pbTrainerIntro(:RIVAL1)
  setBattleRule("canLose")
  setBattleRule("noBag")
  if $game_variables[7] == 1
    TrainerBattle.start(:RIVAL1, "Blue", 1)
  elsif $game_variables[7] == 2
    TrainerBattle.start(:RIVAL1, "Blue", 2)
  elsif $game_variables[7] == 3
    TrainerBattle.start(:RIVAL1, "Blue", 0)
  end
  pbTrainerEnd

  if $game_variables[1] == 1
    # puts "you won"
    pbMessage("\\xn[Blue]I can't believe it.")
    pbMessage("\\xn[Blue]Get out of my way.")

    pbMoveRoute(player, [PBMoveRoute::DIRECTION_FIX_ON, PBMoveRoute::RIGHT, PBMoveRoute::DIRECTION_FIX_OFF])

    pbWait(1)

    if player.y == 63
      pbMoveRoute(rival, [
        PBMoveRoute::DOWN,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::UP,
        PBMoveRoute::UP,
        PBMoveRoute::UP,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::UP,
        PBMoveRoute::UP,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT])

    else
      loop do
        if rival.y != 63
          pbMoveRoute(rival, [PBMoveRoute::UP])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.x != 103
          pbMoveRoute(rival, [PBMoveRoute::RIGHT])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.y != 60
          pbMoveRoute(rival, [PBMoveRoute::UP])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.x != 107
          pbMoveRoute(rival, [PBMoveRoute::RIGHT])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.y != 59
          pbMoveRoute(rival, [PBMoveRoute::UP])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.x != 109
          pbMoveRoute(rival, [PBMoveRoute::RIGHT])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end
    end

    # $game_self_switches[[$game_map.map_id, 19, 'A']] = true
    # rival.erase

  elsif $game_variables[1] == 2
    # puts "you lost"
    # $game_self_switches[[32, 18, 'A']] = true
    pbMessage("\\xn[Blue]Pathetic.")
    pbMessage("\\xn[Blue]Do yourself a favor and stay out of my way.")

    pbMoveRoute(player, [PBMoveRoute::DIRECTION_FIX_ON, PBMoveRoute::RIGHT, PBMoveRoute::DIRECTION_FIX_OFF])

    pbWait(1)

    if player.y == 63
      pbMoveRoute(rival, [
        PBMoveRoute::DOWN,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::UP,
        PBMoveRoute::UP,
        PBMoveRoute::UP,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT,
        PBMoveRoute::UP,
        PBMoveRoute::UP,
        PBMoveRoute::RIGHT,
        PBMoveRoute::RIGHT])

    else
      loop do
        if rival.y != 63
          pbMoveRoute(rival, [PBMoveRoute::UP])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.x != 103
          pbMoveRoute(rival, [PBMoveRoute::RIGHT])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.y != 60
          pbMoveRoute(rival, [PBMoveRoute::UP])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.x != 107
          pbMoveRoute(rival, [PBMoveRoute::RIGHT])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.y != 59
          pbMoveRoute(rival, [PBMoveRoute::UP])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end

      loop do
        if rival.x != 109
          pbMoveRoute(rival, [PBMoveRoute::RIGHT])
          Graphics.update
          Input.update
          pbUpdateSceneMap
        else
          break
        end
      end
    end
  end

  $game_self_switches[[$game_map.map_id, 19, 'A']] = true
  $game_self_switches[[$game_map.map_id, 18, 'A']] = true
  $game_map.need_refresh = true
end
