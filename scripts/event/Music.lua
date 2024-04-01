local CurrentLevel = require "necro.game.level.CurrentLevel"
local Event        = require "necro.event.Event"
local Music        = require "necro.audio.Music"
local MusicLayers  = require "necro.audio.MusicLayers"
local Soundtrack   = require "necro.game.data.Soundtrack"
local Tick         = require "necro.cycles.Tick"

local DelayFunction = require "LobbyJukebox.DelayFunction"
local MusicControl  = require "LobbyJukebox.MusicControl"

Event.musicPlay.add("lobbyMusicAutoplay", { order = "playAudio", sequence = 1 }, function(ev)
  if not CurrentLevel.isLobby() then return end

  local len = Music.getMusicLength()
  DelayFunction.fadeOut({}, len - 0.01)
end)

Event.musicLayersUpdateVolume.override("applyTileProximityVolumeModifiers", { sequence = 1 }, function(func, ev)
  if not CurrentLevel.isLobby() then
    func(ev)
    return
  end
  -- otherwise do nothing :)
end)