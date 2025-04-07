$player_notes = {}

class NotebookShowScene
  def pbStartScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @background_path = "Graphics/Pictures/notebookbg"
    @sprites["background"].setBitmap(@background_path)
    @sprites["background"].x = (Graphics.width - @sprites["background"].bitmap.width)/2
    @sprites["background"].y = (Graphics.height - @sprites["background"].bitmap.height)/2
    
    # Title sprite
    @sprites["title"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["title"].bitmap)
    title = @sprites["title"].bitmap
    title.clear

    # Set base color for text (black)
    base_color = Color.new(0, 0, 0)
    shadow_color = nil  # Ensure no shadow

    # Draw title without shadow
    pbDrawTextPositions(title, [[_INTL("Index"), 170, 10, 0, base_color, shadow_color]])

    # Cancel text window
    @sprites["cancelwindow"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["cancelwindow"].bitmap)
    cancelWindow = @sprites["cancelwindow"].bitmap
    cancelWindow.clear

    # Set cancel text (without shadow)
    cancelText = _INTL("Cancel: close")
    pbDrawTextPositions(cancelWindow, [[cancelText, 350, 10, 0, base_color, shadow_color]])

    # Command window (just for structure)
    commands = []
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].visible = false
    @sprites["cmdwindow"].viewport = @viewport

    # Fade-in effect
    pbFadeInAndShow(@sprites) { update }
  end

  def pbMain
    ret = -1
    note_title_list = $player_notes.keys
    cmdwindow = @sprites["cmdwindow"]
    cmdwindow.commands = note_title_list
    cmdwindow.index    = $game_temp.menu_last_choice
    cmdwindow.width    = 320
    cmdwindow.height   = 254
    cmdwindow.x        = 162
    cmdwindow.y        = 30
    cmdwindow.visible  = true
    cmdwindow.back_opacity  = 0
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        ret = cmdwindow.index
        $game_temp.menu_last_choice = ret
        break
      end
    end
    return ret
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class NotebookShowScreen
  def initialize(scene)
    @scene=scene
  end

  def pbStartScreen
    @scene.pbStartScene
    loop do
      if !$player_notes || $player_notes.length == 0
        pbMessage(_INTL("There's no notes here."))
        break
      else
        selected_index = @scene.pbMain
        if selected_index >= 0 && selected_index < $player_notes.length

          note_title_list = $player_notes.keys
          selected_title = note_title_list[selected_index]
          selected_body = $player_notes[selected_title]

          selected_note_commands = pbMessage(
            _INTL("What do you want to do with note {1}?", selected_title),
            [_INTL("Read"),
             _INTL("Delete"),
             _INTL("Cancel")], -1
          )

          case selected_note_commands
          when 0   # Read
            pbFadeOutIn {
              # pbMessage("\\wm#{selected_body}")
              pbShowFullScreenNote(selected_title, selected_body)
              # puts "Selected note: #{$player_notes.keys[selected_note].dup} => #{$player_notes.values[selected_note].dup}"
            }
          when 1   # Delete
            if pbConfirmMessage(_INTL("The note will be lost. Is that OK?"))
              pbMessage(_INTL("The note was deleted."))
              $player_notes.delete(selected_title)
              save_notes  # Save the updated notes
            end
          end
        else
          break
        end
      end
    end
    @scene.pbEndScene
  end
end

#####
#####
#####

class NotebookFullScreenScene
  def initialize(note_title, note_body)
    @note_title = note_title
    @note_body = note_body
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    # Set up the background for the full-screen view
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/notepage")  # Use your custom background image here

    # Create a bitmap for the note content
    @sprites["note_content"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["note_content"].bitmap)
    
    drawNoteContent
    pbFadeInAndShow(@sprites) { update }
  end

  def drawNoteContent
    note_bitmap = @sprites["note_content"].bitmap
    note_bitmap.clear
    base_color = Color.new(0, 0, 0)
    shadow_color = nil

    # Draw the note title at the top
    pbDrawTextPositions(note_bitmap, [[@note_title, 20, 20, 0, base_color, shadow_color]])
    # pbDrawTextPositions(note_bitmap, [[@note_title, 20, 20, 0, base_color, 0, true]])

    # Draw the note body with word wrapping
    drawNoteBody(note_bitmap)
  end

  def drawNoteBody(bitmap)
    text = @note_body
    x = 20  # Left margin
    y = 60  # Top margin below the title
    width = Graphics.width - 40  # Subtracting margins from the width
    
    # Manually wrap the text
    lines = wrapText(text, width)
    
    # Set text color to black
    base_color = Color.new(0, 0, 0)  # Black text
    shadow_color = nil  # No shadow color
    
    # Draw each line of text (body text)
    lines.each_with_index do |line, index|
      pbDrawTextPositions(bitmap, [[line, x, y + (index * 30), 0, base_color, shadow_color]])  # Draw body text
    end
  end
  
  def wrapText(text, max_width)
    lines = []
    words = text.split(' ')
    current_line = ""
    
    words.each do |word|
      # Try adding the word to the current line
      test_line = current_line.empty? ? word : "#{current_line} #{word}"
      
      # If the line is too long, push the current line and start a new one
      if pbGetTextWidth(test_line) <= max_width
        current_line = test_line
      else
        lines << current_line
        current_line = word
      end
    end
    
    # Add the last line
    lines << current_line unless current_line.empty?
  
    return lines
  end

  def pbGetTextWidth(text)
    # Using Bitmap to calculate the width of the text
    bitmap = Bitmap.new(1, 1)  # Create a temporary bitmap
    pbSetSystemFont(bitmap)     # Set the system font
    width = bitmap.text_size(text).width  # Get the width of the text
    bitmap.dispose  # Dispose of the temporary bitmap
    return width
  end

  def update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def pbMain
    loop do
      Graphics.update
      Input.update
      self.update

      if Input.trigger?(Input::BACK) || Input.trigger?(Input::ACTION)
        break
      end
    end
  end
end

class NotebookFullScreenScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbMain
    @scene.pbEndScene
  end
end

def pbShowFullScreenNote(note_title, note_body)
  pbFadeOutIn {
    scene = NotebookFullScreenScene.new(note_title, note_body)
    screen = NotebookFullScreenScreen.new(scene)
    screen.pbStartScreen
  }
end

#####
#####
#####

def pbNewNotebookScreen
  pbFadeOutIn(99999) {
    scene = NotebookShowScene.new
    screen = NotebookShowScreen.new(scene)
    screen.pbStartScreen
  }
end

def save_notes
  # Use Marshal to save the notes to a file
  File.open("Data/player_notes.dat", "wb") do |f|
    Marshal.dump($player_notes, f)
  end
end

def load_notes
  if File.exist?("Data/player_notes.dat") && !File.zero?("Data/player_notes.dat")
    # Use Marshal to load the notes from the file
    File.open("Data/player_notes.dat", "rb") do |f|
      $player_notes = Marshal.load(f)
    end
  else
    # If no notes file exists or it is empty, initialize the hash
    $player_notes = {}
  end
end

ItemHandlers::UseInField.add(:NOTEBOOK, proc { |item, scene|
  commands = ["Write a new note", "Open notebook"]
  choice = pbMessage("What would you like to do?", commands, -1)

  if choice == 0 # Write a new note
    note_title = pbMessageFreeText("Enter a title:", "", false, 100, Graphics.width)
    if note_title != ""
      note_body = pbMessageFreeText("Enter a body:", "", false, 500, Graphics.width)
      $player_notes[note_title] = note_body
      save_notes
    end
  elsif choice == 1 # View saved notes
    pbNewNotebookScreen
  end
})

load_notes
