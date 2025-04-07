GameData::TerrainTag.register({
  :id                     => :Special,
  :id_number              => 32,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :Grass
})

GameData::EncounterType.register({
  :id             => :Special,
  :type           => :land,
  :trigger_chance => 21
})

GameData::EncounterType.register({
  :id             => :SpecialNight,
  :type           => :land,
  :trigger_chance => 21
})

class PokemonEncounters
  def encounter_type
    time = pbGetTimeNow
    ret = nil
    
    if $PokemonGlobal.surfing
      ret = find_valid_encounter_type_for_time(:Water, time)
    else   # Land/Cave (can have both in the same map)
      terrain_tag = $game_map.terrain_tag($game_player.x, $game_player.y)
      if has_land_encounters? && terrain_tag.land_wild_encounters
        if terrain_tag.id_number == 32 # Terrain tag 32 for Special
          ret = find_valid_encounter_type_for_time(:Special, time)
        else
          ret = :BugContest if pbInBugContest? && has_encounter_type?(:BugContest)
          ret = find_valid_encounter_type_for_time(:Land, time) if !ret
        end
      end
      if !ret && has_cave_encounters?
        ret = find_valid_encounter_type_for_time(:Cave, time)
      end
    end
    return ret
  end
end
