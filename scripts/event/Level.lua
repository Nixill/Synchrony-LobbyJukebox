local CurrentLevel = require "necro.game.level.CurrentLevel"
local Event        = require "necro.event.Event"

local MusicControl  = require "LobbyJukebox.MusicControl"
local DelayFunction = require "LobbyJukebox.DelayFunction"

Event.levelLoad.add("queueDifferentTrack", { order = "music", sequence = -1 }, function(ev)
  DelayFunction.cancelPlayNext()
  DelayFunction.cancelFadeOut()

  if not CurrentLevel.isLobby() then return end

  local nt = MusicControl.getNextTrack()
  ev.music = nt
end)