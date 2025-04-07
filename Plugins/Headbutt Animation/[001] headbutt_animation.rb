alias :mypbHeadbuttEffect :pbHeadbuttEffect
def pbHeadbuttEffect(event = nil)
  event = $game_player.pbFacingEvent(true) if !event
  pbSEPlay("Headbutt")
  pbMoveRoute(event, [
    PBMoveRoute::GRAPHIC, "object tree 3", 0, 4, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "object tree 3", 0, 2, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "object tree 3", 0, 6, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "object tree 3", 0, 2, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "object tree 3", 0, 4, 0,
    PBMoveRoute::WAIT, 1,
    PBMoveRoute::GRAPHIC, "object tree 3", 0, 2, 0
  ])
  pbWait(1.0)
  a = (event.x + (event.x / 24).floor + 1) * (event.y + (event.y / 24).floor + 1)
  a = (a * 2 / 5) % 10   # Even 2x as likely as odd, 0 is 1.5x as likely as odd
  b = $player.public_ID % 10   # Practically equal odds of each value
  chance = 1                 # ~50%
  if a == b                    # 10%
    chance = 8
  elsif a > b && (a - b).abs < 5   # ~30.3%
    chance = 5
  elsif a < b && (a - b).abs > 5   # ~9.7%
    chance = 5
  end
  if rand(10) >= chance
    pbMessage(_INTL("Nope. Nothing..."))
  else
    enctype = (chance == 1) ? :HeadbuttLow : :HeadbuttHigh
    if pbEncounter(enctype)
      $stats.headbutt_battles += 1
    else
      pbMessage(_INTL("Nope. Nothing..."))
    end
  end
end

# alias :mypbHeadbuttEffect :pbHeadbuttEffect