def pbNowResetEVs(pkmn, scene)
  pkmn.ev[:HP] = 0
  pkmn.ev[:ATTACK] = 0
  pkmn.ev[:DEFENSE] = 0
  pkmn.ev[:SPECIAL_ATTACK] = 0
  pkmn.ev[:SPECIAL_DEFENSE] = 0
  pkmn.ev[:SPEED] = 0
  pkmn.calc_stats
  scene.pbDisplay(_INTL("The Pokémon's EVs were reset."))
end
