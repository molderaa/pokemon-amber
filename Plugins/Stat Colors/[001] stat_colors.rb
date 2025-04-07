class PokemonSummary_Scene
  alias_method :myDrawPageThree, :drawPageThree
  def drawPageThree
    overlay = @sprites["overlay"].bitmap
    base   = Color.new(248, 248, 248)
    shadow = Color.new(104, 104, 104)
    # Determine which stats are boosted and lowered by the Pokémon's nature
    statshadows = {}
    GameData::Stat.each_main { |s| statshadows[s.id] = shadow }
    if !@pokemon.shadowPokemon? || @pokemon.heartStage <= 3
      @pokemon.nature_for_stats.stat_changes.each do |change|
        statshadows[change[0]] = Color.new(0, 204, 0) if change[1] > 0
        statshadows[change[0]] = Color.new(255, 51, 51) if change[1] < 0
      end
    end
    # Write various bits of text
    textpos = [
      [_INTL("HP"), 292, 82, :center, base, statshadows[:HP]],
      [sprintf("%d/%d", @pokemon.hp, @pokemon.totalhp), 462, 82, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Attack"), 248, 126, :left, base, statshadows[:ATTACK]],
      [@pokemon.attack.to_s, 456, 126, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Defense"), 248, 158, :left, base, statshadows[:DEFENSE]],
      [@pokemon.defense.to_s, 456, 158, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Sp. Atk"), 248, 190, :left, base, statshadows[:SPECIAL_ATTACK]],
      [@pokemon.spatk.to_s, 456, 190, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Sp. Def"), 248, 222, :left, base, statshadows[:SPECIAL_DEFENSE]],
      [@pokemon.spdef.to_s, 456, 222, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Speed"), 248, 254, :left, base, statshadows[:SPEED]],
      [@pokemon.speed.to_s, 456, 254, :right, Color.new(64, 64, 64), Color.new(176, 176, 176)],
      [_INTL("Ability"), 224, 290, :left, base, shadow]
    ]
    # Draw ability name and description
    ability = @pokemon.ability
    if ability
      textpos.push([ability.name, 362, 290, :left, Color.new(64, 64, 64), Color.new(176, 176, 176)])
      drawTextEx(overlay, 224, 322, 282, 2, ability.description, Color.new(64, 64, 64), Color.new(176, 176, 176))
    end
    # Draw all text
    pbDrawTextPositions(overlay, textpos)
    # Draw HP bar
    if @pokemon.hp > 0
      w = @pokemon.hp * 96 / @pokemon.totalhp.to_f
      w = 1 if w < 1
      w = ((w / 2).round) * 2
      hpzone = 0
      hpzone = 1 if @pokemon.hp <= (@pokemon.totalhp / 2).floor
      hpzone = 2 if @pokemon.hp <= (@pokemon.totalhp / 4).floor
      imagepos = [
        ["Graphics/UI/Summary/overlay_hp", 360, 110, 0, hpzone * 6, w, 6]
      ]
      pbDrawImagePositions(overlay, imagepos)
    end
  end
end
