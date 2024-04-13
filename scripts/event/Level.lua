local CurrentLevel = require "necro.game.level.CurrentLevel"
local Event        = require "necro.event.Event"

local MusicTimer = require "LobbyJukebox.mod.MusicTimer"

Event.levelLoad.add("queueDifferentTrack", { order = "music", sequence = -1 }, function(ev)
  if not CurrentLevel.isLobby() then
    MusicTimer.cancelBoth()
  else
    ev.music.LobbyJukebox_ignore = true
    MusicTimer.play()
  end
end)