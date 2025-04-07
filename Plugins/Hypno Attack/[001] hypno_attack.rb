def pbHypnoAttack
  player = $game_player
  hypno = $game_map.events[31]
  seymour = $game_map.events[30]

  pbMoveRoute(hypno, [PBMoveRoute::TURN_TOWARD_PLAYER])

  hypno.animation_id = 3

  pbWait(1.2)

  pbMoveRoute(hypno, [
    PBMoveRoute::TOWARD_PLAYER,
    PBMoveRoute::TURN_TOWARD_PLAYER
  ])

  pbSEPlay("HYPNO", volume = 100, pitch = 100)

  pbWait(2)

  setBattleRule("editWildPokemon", {
    :form => 1,
    :nature => :SERIOUS,
    :hp_level => 2,
    :moves => [:CONFUSION, :HYPNOSIS, :DISABLE, :PSYCHOCUT]
  })
  setBattleRule("cannotRun")
  setBattleRule("outcome", 42)
  WildBattle.start(:HYPNO, 20)

  $game_self_switches[[$game_map.map_id, 31, 'A']] = true
  $game_self_switches[[$game_map.map_id, 33, 'A']] = true

  if $game_variables[42] == 2
    $game_self_switches[[$game_map.map_id, 30, 'A']] = true
  elsif $game_variables[42] == 1 || $game_variables[42] == 4
    pbMoveRoute(seymour, [
      PBMoveRoute::TOWARD_PLAYER,
      PBMoveRoute::TOWARD_PLAYER
    ])
    pbWait(1)
    pbMessage("\\xn[Seymour]Thank you for saving me!")
    pbMessage("\\xn[Seymour]That Hypno cornered me while I was studying that moss covered rock over there.")
    pbMessage("\\xn[Seymour]Oh, Professor Willow sent you?")
    pbMessage("\\xn[Seymour]I'll meet you back at my house in Drymus Town. Feel free to stop by when you're ready.")

    pbMoveRoute(player, [
      PBMoveRoute::BACKWARD,
      PBMoveRoute::BACKWARD
    ])

    pbMoveRoute(seymour, [
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::UP,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::UP,
      PBMoveRoute::UP,
      PBMoveRoute::UP,
      PBMoveRoute::UP,
      PBMoveRoute::UP,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT,
      PBMoveRoute::RIGHT
    ])

    pbWait(5)

    $game_self_switches[[$game_map.map_id, 30, 'A']] = true
    $game_switches[97] = true
  end

  $game_map.need_refresh = true
end