def pbMomEvent
  mom = $game_map.events[6]
  player = $game_player

  # puts mom.x
  # puts player.x

  if $game_switches[3] == false
    # puts "game switch was false"

    pbMoveRoute(mom, [
      PBMoveRoute::OPACITY, 255
    ])

    pbMoveRoute(player, [
      PBMoveRoute::TURN_UP
    ])

    loop do
      case
      when mom.x < player.x
        pbMoveRoute(mom, [
          PBMoveRoute::RIGHT
        ])
      when mom.x > player.x
        pbMoveRoute(mom, [
          PBMoveRoute::LEFT
        ])
      when mom.y != player.y - 1
        pbMoveRoute(mom, [
          PBMoveRoute::DOWN
        ])
      # when mom.x < player.x
      #   pbMoveRoute(mom, [
      #     PBMoveRoute::RIGHT
      #   ])
      # when mom.x > player.x
      #   pbMoveRoute(mom, [
      #     PBMoveRoute::LEFT
      #   ])
      end

      Graphics.update
      Input.update
      pbUpdateSceneMap

      if mom.y == player.y - 1 && mom.x == player.x
        pbMoveRoute(mom, [
          PBMoveRoute::TURN_TOWARD_PLAYER
        ])
        break
      end
    end

    pbWait(0.8)
  end
end


def pbMomEvent1
  mom = $game_map.events[6]
  player = $game_player

  case
  when player.x >= 10 && player.x <= 20
    loop do 
      pbMoveRoute(mom, [
        PBMoveRoute::RIGHT
      ])

      Graphics.update
      Input.update
      pbUpdateSceneMap

      if mom.x == 21
        break
      end
    end

    pbMoveRoute(mom, [
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::OPACITY, 0
    ])

  when player.x >= 21
    loop do 
      pbMoveRoute(mom, [
        PBMoveRoute::LEFT
      ])

      Graphics.update
      Input.update
      pbUpdateSceneMap

      if mom.x == 20
        break
      end
    end

    pbMoveRoute(mom, [
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::DOWN,
      PBMoveRoute::OPACITY, 0
    ])
  end

  $game_switches[98] = true

  pbWait(2)

  $game_self_switches[[$game_map.map_id, 6, 'A']] = true
  $game_map.need_refresh = true
end
