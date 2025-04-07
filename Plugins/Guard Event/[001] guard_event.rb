def pbTreeFallEvent
  guard = $game_map.events[3]
  player = $game_player

  if $game_switches[4] == false && $game_player.y == 4
    if guard.x < player.x
      loop do
        pbMoveRoute(guard, [
          PBMoveRoute::RIGHT
        ])

        Graphics.update
        Input.update
        pbUpdateSceneMap

        if guard.x == player.x
          break
        end
      end
        
      pbMoveRoute(guard, [
        PBMoveRoute::TURN_TOWARD_PLAYER
      ])

      pbWait(0.2)

      pbMessage("Hold up. I can't let you pass. We're clearing some fallen trees right now. Come back later.")

      pbMoveRoute(player, [
        PBMoveRoute::TURN_DOWN,
        PBMoveRoute::DOWN
      ])

      loop do
        pbMoveRoute(guard, [
          PBMoveRoute::LEFT
        ])

        Graphics.update
        Input.update
        pbUpdateSceneMap

        if guard.x == 0
          break
        end
      end

      pbMoveRoute(guard, [
        PBMoveRoute::TURN_RIGHT
      ])
    else
      pbMoveRoute(guard, [
        PBMoveRoute::TURN_TOWARD_PLAYER
      ])

      pbMessage("Hold up. I can't let you pass. We're clearing some fallen trees right now. Come back later.")

      pbMoveRoute(guard, [
        PBMoveRoute::TURN_RIGHT
      ])

      pbMoveRoute(player, [
        PBMoveRoute::TURN_DOWN,
        PBMoveRoute::DOWN
      ])
    end
  end
end

def pbDisableTreeFallEvent
  $game_self_switches[[11, 3, 'A']] = true
  $game_self_switches[[11, 4, 'A']] = true
end
