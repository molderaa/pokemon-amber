module FollowingPkmn
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon event and corresponding
  # Follower Data
  #-----------------------------------------------------------------------------
  def self.get
    return nil if !FollowingPkmn.can_check?
    $game_temp.followers.each_follower do |event, follower|
      next if !follower.following_pkmn?
      return [event, follower]
    end
    return nil
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon event
  #-----------------------------------------------------------------------------
  def self.get_event
    return nil if !FollowingPkmn.can_check?
    ret = FollowingPkmn.get
    return ret.is_a?(Array) ? ret[0] : nil
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Following Pokemon FollowerData
  #-----------------------------------------------------------------------------
  def self.get_data
    return nil if !FollowingPkmn.can_check?
    ret = FollowingPkmn.get
    return ret.is_a?(Array) ? ret[1] : nil
  end
  #-----------------------------------------------------------------------------
  # Script Command for getting the Pokemon Object of the Following Pokemon
  #-----------------------------------------------------------------------------
  def self.get_pokemon
    return nil if !FollowingPkmn.can_check?
    return $player.first_able_pokemon
  end
  #-----------------------------------------------------------------------------
  # Script Command for checking whether the current follower is airborne
  #-----------------------------------------------------------------------------
  def self.airborne_follower?
    return false if !FollowingPkmn.can_check?
    pkmn = FollowingPkmn.get_pokemon
    return false if !pkmn
    return true if pkmn.hasType?(:FLYING)
    return true if pkmn.hasAbility?(:LEVITATE)
    return true if FollowingPkmn::LEVITATING_FOLLOWERS.any? { |s| s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}" }
    return false
  end
  #-----------------------------------------------------------------------------
  # Script Command for checking whether the current follower is waterborne
  #-----------------------------------------------------------------------------
  def self.waterborne_follower?
    return false if !FollowingPkmn.can_check?
    pkmn = FollowingPkmn.get_pokemon
    return false if !pkmn
    return true if pkmn.hasType?(:WATER)
    # Don't follow if the Pokemon is manually selected
    return false if FollowingPkmn::SURFING_FOLLOWERS_EXCEPTIONS.any? do |s|
      s == pkmn.species || s.to_s == "#{pkmn.species}_#{pkmn.form}"
    end
    # Follow if the Pokemon flies or levitates
    return true if FollowingPkmn.airborne_follower?
    return false
  end
  #-----------------------------------------------------------------------------
  # Forcefully refresh Following Pokemon sprite with animation (if specified)
  #-----------------------------------------------------------------------------
  def self.refresh(anim = false)
    return if !FollowingPkmn.can_check?
    event = FollowingPkmn.get_event
    FollowingPkmn.remove_sprite
    event&.calculate_bush_depth
    first_pkmn = FollowingPkmn.get_pokemon
    return if !first_pkmn
    FollowingPkmn.refresh_internal
    ret = FollowingPkmn.active?
    event = FollowingPkmn.get_event
    if anim
      anim_name = ret ? :ANIMATION_COME_OUT : :ANIMATION_COME_IN
      anim_id   = nil
      anim_id   = FollowingPkmn.const_get(anim_name) if FollowingPkmn.const_defined?(anim_name)
      if event && anim_id
        $scene.spriteset.addUserAnimation(anim_id, event.x, event.y, false, 1)
        pbMoveRoute($game_player, [PBMoveRoute::WAIT, 2])
        pbWait(Graphics.frame_rate/300)
      end
    end
    FollowingPkmn.change_sprite(first_pkmn) if ret
    FollowingPkmn.move_route([(ret ? PBMoveRoute::STEP_ANIME_ON : PBMoveRoute::STEP_ANIME_OFF)]) if FollowingPkmn::ALWAYS_ANIMATE
    event&.calculate_bush_depth
    $PokemonGlobal.time_taken = 0 if !ret
    return ret
  end
  #-----------------------------------------------------------------------------
  # Forcefully refresh Following Pokemon sprite with animation (if specified)
  #-----------------------------------------------------------------------------
  def self.remove_sprite
    FollowingPkmn.get_event&.character_name = ""
    FollowingPkmn.get_data&.character_name  = ""
    FollowingPkmn.get_event&.character_hue  = 0
    FollowingPkmn.get_data&.character_hue   = 0
  end
  #-----------------------------------------------------------------------------
  # Set the Following Pokemon sprite to a different Pokemon
  #-----------------------------------------------------------------------------
  def self.change_sprite(pkmn)
    shiny = pkmn.shiny?
    shiny = pkmn.superVariant if (pkmn.respond_to?(:superVariant) && !pkmn.superVariant.nil? && pkmn.superShiny?)
    fname = GameData::Species.ow_sprite_filename(pkmn.species, pkmn.form,
      pkmn.gender, shiny, pkmn.shadow)
    fname.gsub!("Graphics/Characters/", "")
    FollowingPkmn.get_event&.character_name = fname
    FollowingPkmn.get_data&.character_name  = fname
    if FollowingPkmn.get_event&.move_route_forcing
      hue = pkmn.respond_to?(:superHue) && pkmn.superShiny? ? pkmn.superHue : 0
      FollowingPkmn.get_event&.character_hue  = hue
      FollowingPkmn.get_data&.character_hue   = hue
    end
  end
  
  #-----------------------------------------------------------------------------
  # Refresh the follower if the first Pokemon faints
  #-----------------------------------------------------------------------------
  @follower_set = false

  @forced_follower_refresh_added = false  # Class-level instance variable

  def self.check_poisoned_follower
    return unless $PokemonGlobal.follower_toggled  # Ensure a follower is active
    return if $player.party.empty?
    return unless can_check?

    follower = FollowingPkmn.get_pokemon

    if follower && $player.party[0].status == :POISON && follower.hp < 5
      unless @forced_follower_refresh_added
        EventHandlers.add(:on_frame_update, :forced_follower_refresh, proc {
          FollowingPkmn.check_poisoned_follower
        })
        @forced_follower_refresh_added = true
      end
    else
      if @forced_follower_refresh_added
        EventHandlers.remove(:on_frame_update, :forced_follower_refresh)
        @forced_follower_refresh_added = false
      end
    end

    return unless follower && $player.party[0].fainted?

    if $player.party[0].fainted? && !@follower_set
      EventHandlers.remove(:on_frame_update, :forced_follower_refresh)
      @forced_follower_refresh_added = false
      set_next_follower
      @follower_set = true  # Mark that the follower has been set
    end
  end

  def self.set_next_follower
    return unless can_check?
    next_pokemon = $player.party.find { |pkmn| pkmn.able? }
    if next_pokemon
      FollowingPkmn.change_sprite(next_pokemon)  # Uncomment this line if needed
      # FollowingPkmn.refresh_internal
      @follower_set = false
    end
  end

  # Method to reset the follower state when needed (e.g., when the Pokémon is revived)
  def self.reset_follower_state
    @follower_set = false
  end

  # New method to check if a follower is active
  def self.follower_active?
    # Check if there's a follower sprite or if the system recognizes a follower is active
    !FollowingPkmn.get_pokemon.nil?
  end

end
