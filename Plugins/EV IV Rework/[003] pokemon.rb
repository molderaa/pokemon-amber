class Pokemon
  EV_LIMIT      = 128
  EV_STAT_LIMIT = 64

  alias_method :mycalcHP, :calcHP
  def calcHP(base, level, iv, ev)
    return 1 if base == 1   # For Shedinja
    iv = ev = 0 if Settings::DISABLE_IVS_AND_EVS
    return (((base * 2) + iv + ev) * level / 100).floor + level + 10
  end

  alias_method :mycalcStat, :calcStat
  # @return [Integer] the specified stat of this Pokémon (not used for total HP)
  def calcStat(base, level, iv, ev, nat)
    iv = ev = 0 if Settings::DISABLE_IVS_AND_EVS
    return (((((base * 2) + iv + ev) * level / 100).floor + 5) * nat / 100).floor
  end

  alias_method :mycalc_stats, :calc_stats
  # Recalculates this Pokémon's stats.
  def calc_stats
    base_stats = self.baseStats
    this_level = self.level
    this_IV    = self.calcIV
    
    # @ev[:ATTACK] = @ev[:SPECIAL_ATTACK]
    @ev[:SPECIAL_ATTACK] = @ev[:ATTACK]
    
    # Format stat multipliers due to nature
    nature_mod = {}
    GameData::Stat.each_main { |s| nature_mod[s.id] = 100 }
    this_nature = self.nature_for_stats
    if this_nature
      this_nature.stat_changes.each { |change| nature_mod[change[0]] += change[1] }
    end
    # Calculate stats
    stats = {}
    GameData::Stat.each_main do |s|
      if s.id == :HP
        stats[s.id] = calcHP(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id])
      else
        stats[s.id] = calcStat(base_stats[s.id], this_level, this_IV[s.id], @ev[s.id], nature_mod[s.id])
      end
    end

    hp_difference = stats[:HP] - @totalhp
    @totalhp = stats[:HP]
    self.hp = [@hp + hp_difference, 1].max if @hp > 0 || hp_difference > 0
    @attack  = stats[:ATTACK]
    @defense = stats[:DEFENSE]
    @spatk   = stats[:SPECIAL_ATTACK]
    @spdef   = stats[:SPECIAL_DEFENSE]
    @speed   = stats[:SPEED]
  end

  alias_method :myinitialize, :initialize
  def initialize(species, level, owner = $player, withMoves = true, recheck_form = true)
    species_data = GameData::Species.get(species)
    @species          = species_data.species
    @form             = species_data.base_form
    @forced_form      = nil
    @time_form_set    = nil
    self.level        = level
    @steps_to_hatch   = 0
    heal_status
    @gender           = nil
    @shiny            = nil
    @ability_index    = nil
    @ability          = nil
    @nature           = nil
    @nature_for_stats = nil
    @item             = nil
    @mail             = nil
    @moves            = []
    reset_moves if withMoves
    @first_moves      = []
    @ribbons          = []
    @cool             = 0
    @beauty           = 0
    @cute             = 0
    @smart            = 0
    @tough            = 0
    @sheen            = 0
    @pokerus          = 0
    @name             = nil
    @happiness        = species_data.happiness
    @poke_ball        = :POKEBALL
    @markings         = []
    @iv               = {}
    @ivMaxed          = {}
    @ev               = {}
    GameData::Stat.each_main do |s|
      @iv[s.id]       = 31
      @ev[s.id]       = 0
    end
    case owner
    when Owner
      @owner = owner
    when Player, NPCTrainer
      @owner = Owner.new_from_trainer(owner)
    else
      @owner = Owner.new(0, "", 2, 2)
    end
    @obtain_method    = 0   # Met
    @obtain_method    = 4 if $game_switches && $game_switches[Settings::FATEFUL_ENCOUNTER_SWITCH]
    @obtain_map       = ($game_map) ? $game_map.map_id : 0
    @obtain_text      = nil
    @obtain_level     = level
    @hatched_map      = 0
    @timeReceived     = Time.now.to_i
    @timeEggHatched   = nil
    @fused            = nil
    @personalID       = rand(2**16) | (rand(2**16) << 16)
    @hp               = 1
    @totalhp          = 1
    calc_stats
    if @form == 0 && recheck_form
      f = MultipleForms.call("getFormOnCreation", self)
      if f
        self.form = f
        reset_moves if withMoves
      end
    end
  end
end
