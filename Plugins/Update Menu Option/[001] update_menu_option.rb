class PokemonLoadScreen
  alias_method :mypbStartLoadScreen, :pbStartLoadScreen
  def pbStartLoadScreen
    # pbCheckForUpdates()
    
    commands = []
    cmd_continue     = -1
    cmd_new_game     = -1
    cmd_options      = -1
    cmd_language     = -1
    cmd_mystery_gift = -1
    cmd_debug        = -1
    cmd_quit         = -1
    cmd_update       = -1
    show_continue = !@save_data.empty?
    if show_continue
      commands[cmd_continue = commands.length] = _INTL("Continue")
      if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
      end
    end
    commands[cmd_new_game = commands.length]  = _INTL("New Game")
    commands[cmd_options = commands.length]   = _INTL("Options")
    commands[cmd_language = commands.length]  = _INTL("Language") if Settings::LANGUAGES.length >= 2
    commands[cmd_debug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmd_update=commands.length]      =_INTL("Check for Updates")
    commands[cmd_quit = commands.length]      = _INTL("Quit Game")
    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(commands, show_continue, @save_data[:player], @save_data[:stats], map_id)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2
    loop do
      command = @scene.pbChoose(commands)
      pbPlayDecisionSE if command != cmd_quit
      case command
      when cmd_continue
        @scene.pbEndScene
        Game.load(@save_data)
        return
      when cmd_new_game
        @scene.pbEndScene
        Game.start_new
        return
      when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
      when cmd_options
        pbFadeOutIn do
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        end
      when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        MessageTypes.load_message_files(Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
          @save_data[:pokemon_system] = $PokemonSystem
          File.open(SaveData::FILE_PATH, "wb") { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
      when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
      when cmd_update
        pbCheckForUpdates
      when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      else
        pbPlayBuzzerSE
      end
    end
  end
end
