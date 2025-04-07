#
# Oran Berry
#

ItemHandlers::UseOnPokemon.add(:ORANBERRY, proc { |item, qty, pkmn, scene|
  next pbHPItem(pkmn, 50, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:ORANBERRY, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, 50, scene)
})

Battle::ItemEffects::HPHeal.add(:ORANBERRY,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    amt = 50
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    battler.pbRecoverHP(amt)
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored a little HP using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)

class Battle::AI
  HP_HEAL_ITEMS[:ORANBERRY] = 50
end

#
# Sitrus Berry
#

ItemHandlers::UseOnPokemon.add(:SITRUSBERRY, proc { |item, qty, pkmn, scene|
  next pbHPItem(pkmn, pkmn.totalhp / 3, scene)
})

ItemHandlers::BattleUseOnPokemon.add(:SITRUSBERRY, proc { |item, pokemon, battler, choices, scene|
  pbBattleHPItem(pokemon, battler, pokemon.totalhp / 3, scene)
})

Battle::ItemEffects::HPHeal.add(:SITRUSBERRY,
  proc { |item, battler, battle, forced|
    next false if !battler.canHeal?
    next false if !forced && !battler.canConsumePinchBerry?(false)
    amt = battler.totalhp / 3
    ripening = false
    if battler.hasActiveAbility?(:RIPEN)
      battle.pbShowAbilitySplash(battler, forced)
      amt *= 2
      ripening = true
    end
    battle.pbCommonAnimation("EatBerry", battler) if !forced
    battle.pbHideAbilitySplash(battler) if ripening
    battler.pbRecoverHP(amt)
    itemName = GameData::Item.get(item).name
    if forced
      PBDebug.log("[Item triggered] Forced consuming of #{itemName}")
      battle.pbDisplay(_INTL("{1}'s HP was restored.", battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} restored its health using its {2}!", battler.pbThis, itemName))
    end
    next true
  }
)
