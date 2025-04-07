#===============================================================================
# ■ Fly Animation by KleinStudio
# http://pokemonfangames.com
#===============================================================================
# A.I.R (Update for v21.1)
#===============================================================================
class Game_Character
  def setOpacity(value)
    @opacity = value
  end
end
#-------------------
# Animation
#-------------------
def pbFlyAnimation(landing=true)
  
  if landing
    $game_player.turn_left
    pbSEPlay("flybird")
  end
  width  = Settings::SCREEN_WIDTH
  height = Settings::SCREEN_HEIGHT
  @flybird = Sprite.new
  
  # Initial sprites
  if landing
    # For landing, start with normal bird
    @flybird.bitmap = Show_Gen_4_Bird ? RPG::Cache.picture("flybird_gen4") : RPG::Cache.picture("flybird")
  else
    # For takeoff, start with flybird_end
    @flybird.bitmap = RPG::Cache.picture("flybird_end")
  end
  
  @flybird.ox = @flybird.bitmap.width/2
  @flybird.oy = @flybird.bitmap.height/2
  @flybird.x  = width + @flybird.bitmap.width
  @flybird.y  = height/4
    
  sprite_changed = false
  
  loop do
    pbUpdateSceneMap
    if @flybird.x > (width / 2 + 10)
      @flybird.x -= (width + @flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
      @flybird.y -= (height / 4 - height / 2).div BIRD_ANIMATION_TIME
    elsif @flybird.x <= (width / 2 + 10) && @flybird.x >= 0
      if !sprite_changed && @flybird.x <= (width / 2 + 15) && @flybird.x >= (width / 2 + 5)
        old_bitmap = @flybird.bitmap
        if landing
          # For landing, change to flybird_end at midpoint
          @flybird.bitmap = RPG::Cache.picture("flybird_end")
        else
          # For takeoff, change to normal bird at midpoint
          @flybird.bitmap = Show_Gen_4_Bird ? RPG::Cache.picture("flybird_gen4") : RPG::Cache.picture("flybird")
        end
        @flybird.ox = @flybird.bitmap.width/2
        @flybird.oy = @flybird.bitmap.height/2
        old_bitmap.dispose
        sprite_changed = true
      end
      
      @flybird.x -= (width + @flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
      @flybird.y += (height / 4 - height / 2).div BIRD_ANIMATION_TIME
      $game_player.setOpacity(landing ? 0 : 255)
    else
      break
    end
    Graphics.update
  end
  @flybird.dispose
  @flybird = nil
end