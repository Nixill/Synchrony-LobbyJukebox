local Beatmap      = require "necro.audio.Beatmap"
local Boss         = require "necro.game.level.Boss"
local CurrentLevel = require "necro.game.level.CurrentLevel"
local Event        = require "necro.event.Event"
local Menu         = require "necro.menu.Menu"
local Music        = require "necro.audio.Music"
local MusicLayers  = require "necro.audio.MusicLayers"
local Soundtrack   = require "necro.game.data.Soundtrack"

local DelayFunction = require "LobbyJukebox.DelayFunction"

Event.musicPlay.add("lobbyMusicAutoplay", { order = "playAudio", sequence = 1 }, function(ev)
  DelayFunction.cancelFadeOut()

  if not CurrentLevel.isLobby() then return end

  Beatmap.reset()

  if Menu.getName() == "LobbyJukebox_nowPlaying" then
    Menu.update()
  end

  print(Music.getMusicTime())

  local len = Music.getMusicLength()
  DelayFunction.fadeOut({}, len - 0.01)
end)

Event.musicLayersUpdateVolume.override("applyTileProximityVolumeModifiers", { sequence = 1 }, function(func, ev)
  if not CurrentLevel.isLobby() then
    func(ev)
    return
  end

  local music = Music.getParameters()

  if not music then return end

  -- Zone 3
  if music.type == "zone" and music.zone == 3 then
    if music.variant == "h" then
      MusicLayers.setVolume(Soundtrack.LayerType.COLD, 0)
    elseif music.variant == "c" then
      MusicLayers.setVolume(Soundtrack.LayerType.HOT, 0)
    end
  end
end)

Event.musicLayersUpdateVolume.override("MageZone_applyItemProximityVolumeModifiers", { sequence = 1 }, function(func, ev)
  if not CurrentLevel.isLobby() then
    func(ev)
    return
  end

  local music = Music.getParameters()

  if not music then return end

  -- Symphony of Sorcery
  if music.type == "boss" and (music.boss == Boss.Type.MageZone_SYMPHONY_OF_SORCERY
      -- oops, it's typo'd in the source mod
      or music.boss == Boss.Type.MageZone_SYMHPONY_OF_SORCERY) then
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_DRUMS, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_KEYBOARD, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_FLUTE, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_CONTRABASS, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_FRENCH_HORN, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_CLARINET, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_XYLOPHONE, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_TRUMPET, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_HARP, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.MageZone_LUTE, 1)
  end
end)

Event.musicLayersUpdateVolume.override("applyEntityProximityVolumeModifiers", { sequence = 1 }, function(func, ev)
  if not CurrentLevel.isLobby() then
    func(ev)
    return
  end

  local music = Music.getParameters()

  if not music then return end

  -- Shopkeeper
  if music.type == "zone" and music.vocals ~= "" and Soundtrack.Artist.data[music.artist].shopkeeper ~= false then
    MusicLayers.setVolume(Soundtrack.LayerType.SHOPKEEPER, 1)
  end

  -- Coral Riff
  if music.type == "boss" and music.boss == Boss.Type.CORAL_RIFF then
    MusicLayers.setVolume(Soundtrack.LayerType.TENTACLE_DRUMS, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.TENTACLE_HORNS, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.TENTACLE_STRINGS, 1)
    MusicLayers.setVolume(Soundtrack.LayerType.TENTACLE_KEYTAR, 1)
  end

  -- Fortissimole
  if music.type == "boss" and music.boss == Boss.Type.FORTISSIMOLE then
    MusicLayers.setVolume(Soundtrack.LayerType.FORTISSIMOLE, 1)
  end
end)

-- Event.objectUpdateRhythm.add("lobbyResetBeatmap", { order = "musicChange", sequence = 1 }, function(ev)
--   if not CurrentLevel.isLobby() then return end
--   -- ignoreRhythm = true
-- end)