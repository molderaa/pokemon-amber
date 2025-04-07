class Battle
  alias_method :mypbLearnMove, :pbLearnMove
  def pbLearnMove(idxParty, newMove)
    pkmn = pbParty(0)[idxParty]
    return if !pkmn
    pkmnName = pkmn.name
    battler = pbFindBattler(idxParty)
    moveName = GameData::Move.get(newMove).name
    # Pokémon already knows the move
    return if pkmn.hasMove?(newMove)
    # Pokémon has space for the new move; just learn it
    if pkmn.numMoves < Pokemon::MAX_MOVES
      pkmn.learn_move(newMove)
      pbDisplay(_INTL("{1} learned {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
      if battler
        battler.moves.push(Move.from_pokemon_move(self, pkmn.moves.last))
        battler.pbCheckFormOnMovesetChange
      end
      return
    end
    loop do
      pbDisplayPaused(_INTL("{1} wants to learn {2}, but it already knows {3} moves.", pkmnName, moveName, pkmn.numMoves.to_word))
      
      if pbDisplayConfirm(_INTL("Should {1} forget a move to learn {2}?", pkmnName, moveName))
        # Enter the loop for selecting a move to forget
        loop do
          forgetMove = @scene.pbForgetMove(pkmn, newMove)
          if forgetMove >= 0
            # Player chose a move to forget
            oldMoveName = pkmn.moves[forgetMove].name
            pkmn.moves[forgetMove] = Pokemon::Move.new(newMove)   # Replace the move
            battler.moves[forgetMove] = Move.from_pokemon_move(self, pkmn.moves[forgetMove]) if battler
            pbDisplayPaused(_INTL("1, 2, and... ... ... Ta-da!")) { pbSEPlay("Battle ball drop") }
            pbDisplayPaused(_INTL("{1} forgot how to use {2}. And...", pkmnName, oldMoveName))
            pbDisplay(_INTL("{1} learned {2}!", pkmnName, moveName)) { pbSEPlay("Pkmn move learnt") }
            battler&.pbCheckFormOnMovesetChange
            return  # Successfully learned the move, exit the function
          else
            # Player canceled the move selection
            if pbDisplayConfirm(_INTL("Do you really want to give up on learning {1}?", moveName))
              pbDisplay(_INTL("{1} did not learn {2}.", pkmnName, moveName))
              return  # Player confirmed they want to give up, exit the function
            end
          end
        end
      else
        # Player initially chose not to forget a move
        if pbDisplayConfirm(_INTL("Do you really want to give up on learning {1}?", moveName))
          pbDisplay(_INTL("{1} did not learn {2}.", pkmnName, moveName))
          return  # Player confirmed they want to give up, exit the function
        end
        # If they selected "No", restart the loop to ask again
      end
    end
  end
end


# alias :mypbLearnMove1 :pbLearnMove
# def pbLearnMove(pkmn, move, ignore_if_known = false, by_machine = false, &block)
#   return false if !pkmn
#   move = GameData::Move.get(move).id
#   if pkmn.egg? && !$DEBUG
#     pbMessage(_INTL("Eggs can't be taught any moves."), &block)
#     return false
#   elsif pkmn.shadowPokemon?
#     pbMessage(_INTL("Shadow Pokémon can't be taught any moves."), &block)
#     return false
#   end
#   pkmn_name = pkmn.name
#   move_name = GameData::Move.get(move).name
#   if pkmn.hasMove?(move)
#     pbMessage(_INTL("{1} already knows {2}.", pkmn_name, move_name), &block) if !ignore_if_known
#     return false
#   elsif pkmn.numMoves < Pokemon::MAX_MOVES
#     pkmn.learn_move(move)
#     pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
#     return true
#   end

#   loop do
#     pbMessage(_INTL("{1} wants to learn {2}, but it already knows {3} moves.",
#                     pkmn_name, move_name, pkmn.numMoves.to_word) + "\1", &block)
#     if pbConfirmMessage(_INTL("Should {1} forget a move to learn {2}?", pkmn_name, move_name), &block)
#       # Enter the loop for selecting a move to forget
#       loop do
#         forgetMove = @scene.pbForgetMove(pkmn, move)
#         if forgetMove >= 0
#           # Player chose a move to forget
#           old_move_name = pkmn.moves[forgetMove].name
#           pkmn.moves[forgetMove] = Pokemon::Move.new(move)   # Replace the move
#           battler.moves[forgetMove] = Move.from_pokemon_move(self, pkmn.moves[forgetMove]) if battler
#           pbMessage(_INTL("1, 2, and... ... ... Ta-da!") + "\\se[Battle ball drop]\1", &block)
#           pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...", pkmn_name, old_move_name), &block)
#           pbMessage(_INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
#           battler&.pbCheckFormOnMovesetChange
#           return true  # Successfully learned the move, exit the function
#         else
#           # Player canceled the move selection
#           if pbConfirmMessage(_INTL("Do you really want to give up on learning {1}?", move_name), &block)
#             pbMessage(_INTL("{1} did not learn {2}.", pkmn_name, move_name), &block)
#             return false  # Player confirmed they want to give up, exit the function
#           end
#         end
#       end
#     else
#       # Player initially chose not to forget a move
#       if pbConfirmMessage(_INTL("Do you really want to give up on learning {1}?", move_name), &block)
#         pbMessage(_INTL("{1} did not learn {2}.", pkmn_name, move_name), &block)
#         return false  # Player confirmed they want to give up, exit the function
#       end
#     end
#   end
#   return false
# end

def pbLearnMove(pkmn, move, ignore_if_known = false, by_machine = false, &block)
  return false if !pkmn
  move = GameData::Move.get(move).id
  if pkmn.egg? && !$DEBUG
    pbMessage(_INTL("Eggs can't be taught any moves."), &block)
    return false
  elsif pkmn.shadowPokemon?
    pbMessage(_INTL("Shadow Pokémon can't be taught any moves."), &block)
    return false
  end
  pkmn_name = pkmn.name
  move_name = GameData::Move.get(move).name

  # Pokémon already knows the move
  if pkmn.hasMove?(move)
    pbMessage(_INTL("{1} already knows {2}.", pkmn_name, move_name), &block) unless ignore_if_known
    return false
  end

  # Pokémon has space for the new move; just learn it
  if pkmn.numMoves < Pokemon::MAX_MOVES
    pkmn.learn_move(move)
    pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
    return true
  end

  # Pokémon knows max moves; ask to forget one
  loop do
    pbMessage(_INTL("{1} wants to learn {2}, but it already knows {3} moves.", 
                    pkmn_name, move_name, pkmn.numMoves.to_word) + "\1", &block)

    if pbConfirmMessage(_INTL("Should {1} forget a move to learn {2}?", pkmn_name, move_name), &block)
      # Enter loop to choose a move to forget
      loop do
        forget_move_index = pbForgetMove(pkmn, move)
        if forget_move_index >= 0
          # Player chose a move to forget
          old_move_name = pkmn.moves[forget_move_index].name
          oldmovepp = pkmn.moves[forget_move_index].pp
          pkmn.moves[forget_move_index] = Pokemon::Move.new(move)   # Replace the move
          if by_machine && Settings::TAUGHT_MACHINES_KEEP_OLD_PP
            pkmn.moves[forget_move_index].pp = [oldmovepp, pkmn.moves[forget_move_index].total_pp].min
          end
          pbMessage(_INTL("1, 2, and... ... ... Ta-da!") + "\\se[Battle ball drop]\1", &block)
          pbMessage(_INTL("{1} forgot how to use {2}.\\nAnd...", pkmn_name, old_move_name), &block)
          pbMessage("\\se[]" + _INTL("{1} learned {2}!", pkmn_name, move_name) + "\\se[Pkmn move learnt]", &block)
          return true
        else
          # Player canceled the move selection
          if pbConfirmMessage(_INTL("Do you really want to give up on learning {1}?", move_name), &block)
            pbMessage(_INTL("{1} did not learn {2}.", pkmn_name, move_name), &block)
            return false  # Player confirmed to give up
          end
        end
      end
    else
      # Player initially chose not to forget a move
      if pbConfirmMessage(_INTL("Do you really want to give up on learning {1}?", move_name), &block)
        pbMessage(_INTL("{1} did not learn {2}.", pkmn_name, move_name), &block)
        return false  # Player confirmed to give up
      end
      # If they selected "No", restart the loop to ask again
    end
  end
end
