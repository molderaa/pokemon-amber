class Battle
  alias_method :myPbGainEVsOne, :pbGainEVsOne
  def pbGainEVsOne(idxParty, defeatedBattler)
    pkmn = pbParty(0)[idxParty]   # The Pokémon gaining EVs from defeatedBattler
    evYield = defeatedBattler.pokemon.evYield

    # evTotal = 0
    # GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] unless s.id == :SPECIAL_ATTACK }

    # Modify EV yield based on pkmn's held item
    if !Battle::ItemEffects.triggerEVGainModifier(pkmn.item, pkmn, evYield)
      Battle::ItemEffects.triggerEVGainModifier(@initialItems[0][idxParty], pkmn, evYield)
    end
    # Double EV gain because of Pokérus
    if pkmn.pokerusStage >= 1   # Infected or cured
      evYield.each_key { |stat| evYield[stat] *= 2 }
    end
    # Check if Pokemon has more than 128 EVs
    # totalEVs = pkmn.ev.values.reduce(:+)
    totalEVs = pkmn.ev[:HP] + pkmn.ev[:ATTACK] + pkmn.ev[:DEFENSE] + pkmn.ev[:SPECIAL_DEFENSE] + pkmn.ev[:SPEED]
    return if totalEVs >= 128
    # Gain EV based on nature
    nature = pkmn.nature.id

    ###NATURE BASED EV GAIN - MORE LIKE BASED EV GAIN
    case nature
    ##REDUCES SPEED
    when :BRAVE
      pkmn.ev[:ATTACK] += 1 if pkmn.ev[:ATTACK] < 64
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64
    when :RELAXED
      pkmn.ev[:DEFENSE] += 1 if pkmn.ev[:DEFENSE] < 64
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64
    when :QUIET
      # pkmn.ev[:SPECIAL_ATTACK] += 1 if pkmn.ev[:SPECIAL_ATTACK] < 64
      pkmn.ev[:ATTACK] += 1 if pkmn.ev[:ATTACK] < 64
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64
    when :SASSY
      pkmn.ev[:SPECIAL_DEFENSE] += 1 if pkmn.ev[:SPECIAL_DEFENSE] < 64
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64
    ##DOES NOT REDUCE SPEED
    when :LONELY, :ADAMANT, :NAUGHTY
      pkmn.ev[:ATTACK] += 1 if pkmn.ev[:ATTACK] < 64
      pkmn.ev[:SPEED] += 1 if pkmn.ev[:SPEED] < 64
    when :BOLD, :IMPISH, :LAX
      pkmn.ev[:DEFENSE] += 1 if pkmn.ev[:DEFENSE] < 64
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64
    when :MODEST, :MILD, :RASH
      # pkmn.ev[:SPECIAL_ATTACK] += 1 if pkmn.ev[:SPECIAL_ATTACK] < 64
      pkmn.ev[:ATTACK] += 1 if pkmn.ev[:ATTACK] < 64
      pkmn.ev[:SPEED] += 1 if pkmn.ev[:SPEED] < 64
    when :CALM, :GENTLE, :CAREFUL
      pkmn.ev[:SPECIAL_DEFENSE] += 1 if pkmn.ev[:SPECIAL_DEFENSE] < 64
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64
    when :TIMID, :HASTY, :JOLLY, :NAIVE
      pkmn.ev[:SPEED] += 1 if pkmn.ev[:SPEED] < 64
    else
      pkmn.ev[:HP] += 1 if pkmn.ev[:HP] < 64   # Default to HP
    end
  end
end
