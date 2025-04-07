=begin
Makes surf hidden move handler return the move to pbHiddenMoveAnimation
pbHiddenMoveAnimation checks if the move is surf and plays a custom animation that sets the sprite to the surf sprite after the HM animation is done
pbHiddenMoveAnimation also check the direction the player is facing and plays the animation accordingly
=end



HiddenMoveHandlers::UseMove.add(:SURF, proc { |move, pokemon|
  $game_temp.in_menu = false
  pbCancelVehicles
  if !pbHiddenMoveAnimation(pokemon, move)
    pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
  end
  surfbgm = GameData::Metadata.get.surf_BGM
  pbCueBGM(surfbgm, 0.5) if surfbgm
  pbStartSurfing
  next true
})

alias :mypbHiddenMoveAnimation :pbHiddenMoveAnimation
def pbHiddenMoveAnimation(pokemon, move = nil)
  return false if !pokemon

  $game_player.instance_variable_set(:@lock_pattern, true)

  viewport = Viewport.new(0, 0, Graphics.width, 0)
  viewport.z = 99999
  # Set up sprites
  bg = Sprite.new(viewport)
  bg.bitmap = RPG::Cache.ui("Field move/bg")
  sprite = PokemonSprite.new(viewport)
  sprite.setOffset(PictureOrigin::CENTER)
  sprite.setPokemonBitmap(pokemon)
  sprite.x = Graphics.width + (sprite.bitmap.width / 2)
  sprite.y = bg.bitmap.height / 2
  sprite.z = 1
  sprite.visible = false
  strobebitmap = AnimatedBitmap.new("Graphics/UI/Field move/strobes")
  strobes = []
  strobes_start_x = []
  strobes_timers = []
  15.times do |i|
    strobe = BitmapSprite.new(52, 16, viewport)
    strobe.bitmap.blt(0, 0, strobebitmap.bitmap, Rect.new(0, (i % 2) * 16, 52, 16))
    strobe.z = (i.even? ? 2 : 0)
    strobe.visible = false
    strobes.push(strobe)
  end
  strobebitmap.dispose

  if move == :SURF
    animations = "boy_surf"
  else
    animations = "trainer_POKEMONTRAINER_Red"
  end

  playerdirection = $game_player.direction
  # $game_variables[50] = playerdirection
  if playerdirection == 4 || playerdirection == 6 || playerdirection == 8
    pbMoveRoute($game_player, [
      PBMoveRoute::THROUGH_OFF,
      PBMoveRoute::TURN_DOWN,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 0,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 1,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 2,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 3,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 4, 0
    ])
  elsif playerdirection == 2
    pbMoveRoute($game_player, [
      PBMoveRoute::THROUGH_OFF,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 0,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 1,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 2,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 2, 3,
      PBMoveRoute::WAIT, 1,
      PBMoveRoute::GRAPHIC, "boy_HMuse", 0, 4, 0
    ])
  end
  
  pbWait(0.5)

  # Do the animation
  phase = 1
  timer_start = System.uptime
  loop do
    Graphics.update
    Input.update
    sprite.update
    case phase
    when 1   # Expand viewport height from zero to full
      viewport.rect.y = lerp(Graphics.height / 2, (Graphics.height - bg.bitmap.height) / 2,
                            0.25, timer_start, System.uptime)
      viewport.rect.height = Graphics.height - (viewport.rect.y * 2)
      bg.oy = (bg.bitmap.height - viewport.rect.height) / 2
      if viewport.rect.y == (Graphics.height - bg.bitmap.height) / 2
        phase = 2
        sprite.visible = true
        timer_start = System.uptime
      end
    when 2   # Slide Pokémon sprite in from right to centre
      sprite.x = lerp(Graphics.width + (sprite.bitmap.width / 2), Graphics.width / 2,
                      0.4, timer_start, System.uptime)
      if sprite.x == Graphics.width / 2
        phase = 3
        pokemon.play_cry
        timer_start = System.uptime
      end
    when 3   # Wait
      if System.uptime - timer_start >= 0.75
        phase = 4
        timer_start = System.uptime
      end
    when 4   # Slide Pokémon sprite off from centre to left
      sprite.x = lerp(Graphics.width / 2, -(sprite.bitmap.width / 2),
                      0.4, timer_start, System.uptime)
      if sprite.x == -(sprite.bitmap.width / 2)
        phase = 5
        sprite.visible = false
        timer_start = System.uptime
      end
    when 5   # Shrink viewport height from full to zero
      viewport.rect.y = lerp((Graphics.height - bg.bitmap.height) / 2, Graphics.height / 2,
                            0.25, timer_start, System.uptime)
      viewport.rect.height = Graphics.height - (viewport.rect.y * 2)
      bg.oy = (bg.bitmap.height - viewport.rect.height) / 2
      phase = 6 if viewport.rect.y == Graphics.height / 2
    end
    # Constantly stream the strobes across the screen
    strobes.each_with_index do |strobe, i|
      strobe.ox = strobe.viewport.rect.x
      strobe.oy = strobe.viewport.rect.y
      if !strobe.visible   # Initial placement of strobes
        randomY = 16 * (1 + rand((bg.bitmap.height / 16) - 2))
        strobe.y = randomY + ((Graphics.height - bg.bitmap.height) / 2)
        strobe.x = rand(Graphics.width)
        strobe.visible = true
        strobes_start_x[i] = strobe.x
        strobes_timers[i] = System.uptime
      elsif strobe.x < Graphics.width   # Move strobe right
        strobe.x = strobes_start_x[i] + lerp(0, Graphics.width * 2, 0.8, strobes_timers[i], System.uptime)
      else   # Strobe is off the screen, reposition it to the left of the screen
        randomY = 16 * (1 + rand((bg.bitmap.height / 16) - 2))
        strobe.y = randomY + ((Graphics.height - bg.bitmap.height) / 2)
        strobe.x = -strobe.bitmap.width - rand(Graphics.width / 4)
        strobes_start_x[i] = strobe.x
        strobes_timers[i] = System.uptime
      end
    end
    pbUpdateSceneMap
    break if phase == 6
  end
  sprite.dispose
  strobes.each { |strobe| strobe.dispose }
  strobes.clear
  bg.dispose
  viewport.dispose

  case playerdirection
  when 2
    pbMoveRoute($game_player, [
      PBMoveRoute::GRAPHIC, animations, 0, 2, 0
    ])
  when 4
    pbMoveRoute($game_player, [
      PBMoveRoute::GRAPHIC, animations, 0, 4, 0
    ])
  when 6
    pbMoveRoute($game_player, [
      PBMoveRoute::GRAPHIC, animations, 0, 6, 0
    ])
  when 8
    pbMoveRoute($game_player, [
      PBMoveRoute::GRAPHIC, animations, 0, 8, 0
    ])
  end

  $game_player.instance_variable_set(:@lock_pattern, false)

  return true
end

# alias :mypbHiddenMoveAnimation :pbHiddenMoveAnimation
