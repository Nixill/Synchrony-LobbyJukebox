local Beatmap         = require "necro.audio.Beatmap"
local CurrentLevel    = require "necro.game.level.CurrentLevel"
local Event           = require "necro.event.Event"
local Music           = require "necro.audio.Music"
local MusicLayers     = require "necro.audio.MusicLayers"
local SettingsStorage = require "necro.config.SettingsStorage"
local Soundtrack      = require "necro.game.data.Soundtrack"
local Tick            = require "necro.cycles.Tick"

local MusicControl = require "LobbyJukebox.MusicControl"

PlayNext, CancelPlayNext = Tick.registerDelay(function()
  local nt = MusicControl.getNextTrack()

  Music.setMusic(nt, 0)

  -- Set the time properly
  local n = Music.getMusicTime()
  local t = Music.getMusicLength()
  local p = n + t - (n % t)
  Music.setMusicTime(p, false)
end, "playNext")

FadeOut, CancelFadeOut = Tick.registerDelay(function()
  local fadeTime

  -- Should it fade?
  if Music.isMusicLooping() then
    fadeTime = 5
  else
    fadeTime = 0
  end

  -- Fade it out
  Music.fadeOut(fadeTime)

  -- And then start the next track
  PlayNext({}, fadeTime)
end, "fadeOut")

return {
  playNext = PlayNext,
  cancelPlayNext = CancelPlayNext,
  fadeOut = FadeOut,
  cancelFadeOut = CancelFadeOut
}