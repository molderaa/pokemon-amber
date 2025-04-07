module StarterSelection
  # define starters for each region
  STARTERS = {
    1 => [:BULBASAUR, :CHARMANDER, :SQUIRTLE],
    2 => [:CHIKORITA, :CYNDAQUIL, :TOTODILE],
    3 => [:TREECKO, :TORCHIC, :MUDKIP],
    4 => [:TURTWIG, :CHIMCHAR, :PIPLUP],
    5 => [:SNIVY, :TEPIG, :OSHAWOTT],
    6 => [:CHESPIN, :FENNEKIN, :FROAKIE],
    7 => [:ROWLET, :LITTEN, :POPPLIO],
    8 => [:GROOKEY, :SCORBUNNY, :SOBBLE],
    9 => [:SPRIGATITO, :FUECOCO, :QUAXLY]
  }

  def self.choose_region
    # show a choice window with 9 options for regions
    choices = ["Kanto", "Johto", "Hoenn", "Sinnoh", "Unova", "Kalos", "Alola", "Galar", "Paldea"]

    # show the choice window and get the selection
    region_index = pbMessage("Choose your starter region:", choices)

    # if a valid choice was made, set up the starters for the chosen region
    if region_index >= 0
      setup_starters_for_region(region_index + 1)
    end
  end

  def self.setup_starters_for_region(region)
    starters = STARTERS[region]

    $game_variables[27] = starters[0] # first starter
    $game_variables[28] = starters[1] # second starter
    $game_variables[29] = starters[2] # third starter
  end
end


def pbIntro()
  # pbGenderPick
  pbChangePlayer(1)
  pbTrainerName
  if !pbTrainerName()
    pbTrainerName("Red")
  end
  pbShowPicture(1, "bg", "upper left", 0, 0, 200, 200)
  StarterSelection.choose_region
  $game_screen.pictures[1].erase
end
