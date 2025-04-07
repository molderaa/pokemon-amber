alias :mypbJustRaiseEffortValues :pbJustRaiseEffortValues
def pbJustRaiseEffortValues(pkmn, stat, evGain)
  stat = GameData::Stat.get(stat).id
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] unless pkmn.ev[:SPECIAL_ATTACK] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

# alias :mypbJustRaiseEffortValues :pbJustRaiseEffortValues

alias :mypbMaxUsesOfEVRaisingItem :pbMaxUsesOfEVRaisingItem
def pbRaiseEffortValues(pkmn, stat, evGain = 10, no_ev_cap = false)
  stat = GameData::Stat.get(stat).id
  return 0 if !no_ev_cap && pkmn.ev[stat] >= 100
  evTotal = 0
  GameData::Stat.each_main { |s| evTotal += pkmn.ev[s.id] unless pkmn.ev[:SPECIAL_ATTACK] }
  evGain = evGain.clamp(0, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat])
  evGain = evGain.clamp(0, 100 - pkmn.ev[stat]) if !no_ev_cap
  evGain = evGain.clamp(0, Pokemon::EV_LIMIT - evTotal)
  if evGain > 0
    pkmn.ev[stat] += evGain
    pkmn.calc_stats
  end
  return evGain
end

# alias :mypbMaxUsesOfEVRaisingItem :pbMaxUsesOfEVRaisingItem

alias :mypbMaxUsesOfEVRaisingItem :pbMaxUsesOfEVRaisingItem
def pbMaxUsesOfEVRaisingItem(stat, amt_per_use, pkmn, no_ev_cap = false)
  max_per_stat = (no_ev_cap) ? Pokemon::EV_STAT_LIMIT : 100
  amt_can_gain = max_per_stat - pkmn.ev[stat]
  ev_total = 0
  GameData::Stat.each_main { |s| ev_total += pkmn.ev[s.id] unless pkmn.ev[:SPECIAL_ATTACK] }
  amt_can_gain = [amt_can_gain, Pokemon::EV_LIMIT - ev_total].min
  return [(amt_can_gain.to_f / amt_per_use).ceil, 1].max
end

# alias :mypbMaxUsesOfEVRaisingItem :pbMaxUsesOfEVRaisingItem
