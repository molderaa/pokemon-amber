ItemHandlers::UseOnPokemonMaximum.add(:HPUP, proc { |item, pkmn|
  next pbMaxUsesOfEVRaisingItem(:HP, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:HPUP, proc { |item, qty, pkmn, scene|
  next pbUseEVRaisingItem(:HP, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemonMaximum.add(:PROTEIN, proc { |item, pkmn|
  next pbMaxUsesOfEVRaisingItem(:ATTACK, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:PROTEIN, proc { |item, qty, pkmn, scene|
  next pbUseEVRaisingItem(:ATTACK, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemonMaximum.add(:IRON, proc { |item, pkmn|
  next pbMaxUsesOfEVRaisingItem(:DEFENSE, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:IRON, proc { |item, qty, pkmn, scene|
  next pbUseEVRaisingItem(:DEFENSE, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemonMaximum.add(:CALCIUM, proc { |item, pkmn|
  # next pbMaxUsesOfEVRaisingItem(:SPECIAL_ATTACK, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
  next pbMaxUsesOfEVRaisingItem(:ATTACK, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:CALCIUM, proc { |item, qty, pkmn, scene|
  # next pbUseEVRaisingItem(:SPECIAL_ATTACK, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
  next pbUseEVRaisingItem(:ATTACK, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemonMaximum.add(:ZINC, proc { |item, pkmn|
  next pbMaxUsesOfEVRaisingItem(:SPECIAL_DEFENSE, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:ZINC, proc { |item, qty, pkmn, scene|
  next pbUseEVRaisingItem(:SPECIAL_DEFENSE, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:XSTATS, proc { |item, qty, pkmn, scene|
  pbNowResetEVs(pkmn, scene)
  next 1
})

ItemHandlers::UseOnPokemonMaximum.add(:CARBOS, proc { |item, pkmn|
  next pbMaxUsesOfEVRaisingItem(:SPEED, 1, pkmn, Settings::NO_VITAMIN_EV_CAP)
})

ItemHandlers::UseOnPokemon.add(:CARBOS, proc { |item, qty, pkmn, scene|
  next pbUseEVRaisingItem(:SPEED, 1, qty, pkmn, "vitamin", scene, Settings::NO_VITAMIN_EV_CAP)
})
