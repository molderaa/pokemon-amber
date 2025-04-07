def gashapon

  common_prizes = [
    [:SHOALSALT, :SHOALSHELL, :POKEBALL],
    [:ORANBERRY, :PECHABERRY, :CHERIBERRY]
  ]

  uncommon_prizes = [
    [:SASSYMINT, :GENTLEMINT, :CAREFULMINT, :CALMMINT, :RELAXEDMINT, :LAXMINT, :IMPISHMINT, :BOLDMINT],
    [:GREATBALL, :QUICKBALL]
  ]

  rare_prizes = [
    [:TIMIDMINT, :NAIVEMINT, :JOLLYMINT, :HASTYMINT, :SERIOUSMINT],
    [:ULTRABALL]
  ]

  very_rare_prizes = [
    [:LONELYMINT, :ADAMANTMINT, :NAUGHTYMINT, :BRAVEMINT, :MODESTMINT, :MILDMINT, :RASHMINT, :QUIETMINT],
    [:FAIRYGEM, :NORMALGEM, :STEELGEM, :DARKGEM, :GHOSTGEM, :DRAGONGEM, :ROCKGEM, :BUGGEM, :PSYCHICGEM, :FLYINGGEM, :GROUNDGEM, :POISONGEM, :FIGHTINGGEM, :ICEGEM, :GRASSGEM, :ELECTRICGEM, :WATERGEM, :FIREGEM],
    [:SLOWPOKETAIL, :AMULETCOIN, :LOADEDDICE]
  ]

  # extremely_rare_prizes = [:GARCHOMPITE, :AMULETCOIN, :LOADEDDICE]

# down 2, left 4, right 6, up 8

  event_name = $game_player.pbFacingEvent(true)
  # if event_name && event_name.name[/Gashapon/i]
  #   puts "true"
  #   puts event_name.name
  # end

  pbMoveRoute(event_name, [PBMoveRoute::TURN_DOWN])

  open_animation = [PBMoveRoute::TURN_LEFT, PBMoveRoute::WAIT, 1, PBMoveRoute::TURN_RIGHT, PBMoveRoute::WAIT, 1, PBMoveRoute::TURN_UP]
  close_animation = [PBMoveRoute::TURN_RIGHT, PBMoveRoute::WAIT, 1, PBMoveRoute::TURN_LEFT, PBMoveRoute::WAIT, 1, PBMoveRoute::TURN_DOWN, PBMoveRoute::GRAPHIC, "gashapon", 0, 2, 1]
  
  if $bag.has?(:COINCASE)
    selected_choice = pbMessage("\\CNWould you like to use this machine for 15 coins?", ["Yes", "No"], -1)
    if selected_choice == 0
      if $player.coins >=15
        $player.coins -= 15
        random_number = rand(1..497)
        # puts random_number
        case
        when random_number >= 1 && random_number <= 400 # 400
          rand_array = rand(0..1)
          prize = common_prizes[rand_array].sample
          pbMoveRoute(event_name, open_animation)
          pbWait(0.5)
          pbMoveRoute(event_name, [PBMoveRoute::GRAPHIC, "gashapon", 0, 8, 2])
          pbReceiveItem(prize)
          pbMoveRoute(event_name, close_animation)
          pbWait(0.5)

        when random_number >= 401 && random_number <= 450 # 50
          rand_array = rand(0..1)
          prize = uncommon_prizes[rand_array].sample
          pbMoveRoute(event_name, open_animation)
          pbWait(0.5)
          pbMoveRoute(event_name, [PBMoveRoute::GRAPHIC, "gashapon", 0, 8, 2])
          pbReceiveItem(prize)
          pbMoveRoute(event_name, close_animation)
          pbWait(0.5)

        when random_number >= 451 && random_number <= 480 # 30
          rand_array = rand(0..1)
          prize = rare_prizes[rand_array].sample
          pbMoveRoute(event_name, open_animation)
          pbWait(0.5)
          pbMoveRoute(event_name, [PBMoveRoute::GRAPHIC, "gashapon", 0, 8, 2])
          pbReceiveItem(prize)
          pbMoveRoute(event_name, close_animation)
          pbWait(0.5)

        when random_number >= 481 && random_number <= 490 # 10
          rand_array = rand(0..1)
          prize = very_rare_prizes[rand_array].sample
          pbMoveRoute(event_name, open_animation)
          pbWait(0.5)
          pbMoveRoute(event_name, [PBMoveRoute::GRAPHIC, "gashapon", 0, 8, 2])
          pbReceiveItem(prize)
          pbMoveRoute(event_name, close_animation)
          pbWait(0.5)

        when random_number >= 491 && random_number <=493 # 3
          # prize = extremely_rare_prizes.sample
          prize = very_rare_prizes[rand_array].sample
          pbMoveRoute(event_name, open_animation)
          pbWait(0.5)
          pbMoveRoute(event_name, [PBMoveRoute::GRAPHIC, "gashapon", 0, 8, 2])
          pbReceiveItem(prize)
          pbMoveRoute(event_name, close_animation)
          pbWait(0.5)
        end
      else
        pbMessage("You don't have enough coins.")
      end
    end
  else
    pbMessage("You need a coin case and coins.")
  end
end

# gashapon
