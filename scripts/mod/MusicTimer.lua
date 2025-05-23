local Beatmap         = require "necro.audio.Beatmap"
local CurrentLevel    = require "necro.game.level.CurrentLevel"
local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Music           = require "necro.audio.Music"
local MusicLayers     = require "necro.audio.MusicLayers"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"
local Soundtrack      = require "necro.game.data.Soundtrack"
local Tick            = require "necro.cycles.Tick"
local Utilities       = require "system.utils.Utilities"

local MusicControl = require "LobbyJukebox.mod.MusicControl"

MusicPlaying = false
MusicFading = false
MusicPlayedFrom = 0
MusicPausedAt = 0

Loop = Settings.user.bool {
  name = "Loop track",
  desc = "Whether or not LobbyMusic should play one track on a loop",
  id = "loop",
  order = 2,
  default = false
}

FadeOutTime = Settings.user.number {
  name = "Fade-out time",
  desc = "How long to fade looping tracks",
  id = "fadeTime",
  visibility = Settings.Visibility.ADVANCED,
  order = 5,
  default = 5,
  minimum = 0,
  maximum = 20,
  step = 0.5
}

SeekTime = Settings.user.number {
  name = "Seek time",
  desc = "How long to seek",
  id = "seekTime",
  visibility = Settings.Visibility.ADVANCED,
  order = 6,
  default = 5,
  minimum = 2,
  maximum = 60,
  step = 1
}

local mod = {}
local funcs = {}

Play, CancelPlay = Tick.registerDelay(function(args)
  local from = args.from or 0

  SettingsStorage.set("audio.music.volume", 0, Settings.Layer.SCRIPT_OVERRIDE)

  if args.next == true or (args.next == nil and Loop == false) then -- Play next from queue
    -- print("Playing next track")
    local nt = MusicControl.getNextTrack()
    -- print("Now playing" .. Utilities.inspect(nt))
    Music.setMusic(nt, 0)
  elseif type(args.next) == "table" then -- Play a specific track
    -- print("Playing specific track")
    -- print(args.next)
    Music.setMusic(args.next, 0)
  elseif MusicFading then
    -- print("Restarting current track")
    Music.fadeIn(0.01)
  end

  -- Set the time properly
  local p = mod.getNextLoopPoint()
  Music.setMusicTime(p + from, false)
  MusicPlayedFrom = p
  MusicPlaying = true
  MusicFading = false

  -- And queue fadeout
  funcs.FadeOut({}, Music.getMusicLength() - 0.02)

  SettingsStorage.set("audio.music.volume", nil, Settings.Layer.SCRIPT_OVERRIDE)
end, "playNext")

FadeOut, CancelFadeOut = Tick.registerDelay(function()
  local fadeTime

  -- Should it fade?
  if Music.isMusicLooping() and not Loop then
    fadeTime = FadeOutTime

    MusicFading = true

    -- Fade it out
    Music.fadeOut(fadeTime)
  else
    fadeTime = 0
  end

  -- And then start the next track
  Play({}, fadeTime)
end, "fadeOut")

funcs.FadeOut = FadeOut
funcs.CancelFadeOut = CancelFadeOut

function mod.cancelBoth()
  CancelPlay()
  CancelFadeOut()
end

-- Play the next track.
function mod.play(next)
  mod.cancelBoth()
  if next == nil then next = true end
  Play({ next = next }, 0)
end

-- Restart the current track.
function mod.restart()
  mod.cancelBoth()
  Play({ next = false }, 0)
end

-- Pause the current track.
function mod.pause()
  if MusicPlaying then
    mod.cancelBoth()
    Music.pauseMusic()
    MusicPlaying = false
    MusicPausedAt = Music.getMusicTime()
  end
end

-- Resume the current track.
function mod.resume()
  if not MusicPlaying then
    Music.resumeMusic()
    MusicPlaying = true
    MusicPausedAt = 0

    local now = mod.getTrackTime()

    -- Should FadeOut be queued or should Play be queued?
    if MusicFading then
      local remFadeTime = Music.getMusicLength() + FadeOutTime - now
      Play({ next = true }, remFadeTime - 0.02)
    else
      local remMusicTime = Music.getMusicLength() - now
      FadeOut({}, remMusicTime - 0.02)
    end
  end
end

-- Get the next loop point
function mod.getNextLoopPoint(from)
  local n = from or Music.getMusicTime()
  local t = Music.getMusicLength()
  return n + t - (n % t)
end

-- Get the time elapsed in the current track
function mod.getTrackTime()
  return Music.getMusicTime() - MusicPlayedFrom
end

-- Get the total length of the current track, including fade if applicable
function mod.getTrackLength()
  return Music.getMusicLength() + ((MusicFading or (Music.isMusicLooping() and not Loop)) and FadeOutTime or 0)
end

-- Get whether or not music is paused.
function mod.isPaused()
  return not MusicPlaying
end

-- Toggle whether or not music is paused.
function mod.togglePause()
  if MusicPlaying then
    mod.pause()
  else
    mod.resume()
  end
end

-- Return whether or not music is looped.
function mod.isLooped()
  return Loop
end

-- Change whether or not music is looped.
function mod.setLooped(val)
  if val == nil then
    val = not Loop
  end

  Loop = val
end

-- Seek forward.
function mod.seekForward(by)
  mod.cancelBoth()

  local s = by or SeekTime -- The amount to seek
  local n = mod.getNextLoopPoint() - Music.getMusicTime() -- Time to next loop point
  local f = ((MusicFading or not Loop) and Music.isMusicLooping()) and FadeOutTime or
    0 -- The total of the time to spend fading out
  local t = MusicFading and (mod.getTrackTime() - mod.getTrackLength()) or
    f -- The time remaining to fade out, if in progress

  local now = Music.getMusicTime()

  -- print({ s = s, n = n, f = f, t = t, now = now, MusicFading = MusicFading })

  if
    (s < n and not MusicFading) -- The seek time does not push past a loop point
    or (MusicFading and s < t) -- The music is fading, but seeking won't push past the ending
  then
    -- print("Moving forward...")
    Music.setMusicTime(now + s, false)
  elseif
    (Loop and not MusicFading) -- The seek time pushes past a loop point, but we're looping anyway
  then
    -- print("Moving forward (loop)...")
    local i = mod.getNextLoopPoint()
    while i < now + s do
      i = mod.getNextLoopPoint(i)
    end
    MusicPlayedFrom = i
    Music.setMusicTime(now + s, false)
  elseif
    (s > n + f and not MusicFading) -- The music isn't fading yet, but the seek would push past the end of the fade
    or (MusicFading and s > t) -- The music is fading yet, and the seek would push past the end of the fade
  then
    -- print("Next track...")
    mod.play() -- Just play the next track
    return -- since mod.play() will handle timings for us
  else -- The complicated path: Seek goes from "not fading" to "fading" time.
    -- print("Moving forward (no-fade into fade)...")
    Music.setMusicTime(now + n, false)
    Music.fadeOut(FadeOutTime)
    MusicFading = true
    Music.setMusicTime(now + s - n, false)
  end

  now = mod.getTrackTime()

  -- Should FadeOut be queued or should Play be queued?
  if MusicFading then
    local remFadeTime = Music.getMusicLength() + FadeOutTime - now
    -- print("Music is fading. Next track in " .. remFadeTime .. " seconds.")
    Play({ next = true }, remFadeTime - 0.02)
  else
    local remMusicTime = Music.getMusicLength() - now
    -- print("Music is not fading. Fade in " .. remMusicTime .. " seconds.")
    FadeOut({}, remMusicTime - 0.02)
  end
end

function mod.seekBackward(by)
  mod.cancelBoth()

  local s = by or SeekTime -- The amount to seek
  local n = mod.getNextLoopPoint() - Music.getMusicTime() -- Time to next loop point
  local f = ((MusicFading or not Loop) and Music.isMusicLooping()) and FadeOutTime or
    0 -- The total of the time to spend fading out
  local t = MusicFading and (mod.getTrackTime() - mod.getTrackLength()) or
    f -- The time remaining to fade out, if in progress
  local p = mod.getTrackTime() -- Progress already made in song
  local w = Music.getMusicLength() -- Total track length (not including artificial fade)
  local a = MusicFading and (p - w) or 0 -- Time already spent fading

  local now = Music.getMusicTime()
  local next = mod.getNextLoopPoint(MusicPlayedFrom)

  -- print({
  --   s = s,
  --   n = n,
  --   f = f,
  --   t = t,
  --   p = p,
  --   w = w,
  --   a = a,
  --   now = now,
  --   next = next,
  --   MusicFading = MusicFading
  -- })

  if (s < p or Loop) and not MusicFading then
    -- print("Going backward...")
    local target = now + w - (s % w)
    Music.setMusicTime(target, false)
    while (next < target) do
      MusicPlayedFrom = next
      next = mod.getNextLoopPoint(MusicPlayedFrom)
    end
  elseif (s > p and not Loop) then
    -- print("Restarting the track...")
    mod.restart()
    return -- since mod.restart() handles recomputing times
  elseif MusicFading then
    if s > a then
      -- print("Going backward (exiting fade)...")
      local target = now + w - (s % w)
      Music.setMusicTime(target, false)
      while (next < target) do
        MusicPlayedFrom = next
        next = mod.getNextLoopPoint(MusicPlayedFrom)
      end
      Music.fadeIn(0.01)
      MusicFading = false
    else
      -- print("Going backward (within fade)...")
      local target1 = now + n
      local target2 = now + n + a - s
      while target2 < target1 do target2 = target2 + w end
      Music.fadeIn(0.01)
      Music.setMusicTime(target1, false)
      Music.fadeOut(FadeOutTime)
      Music.setMusicTime(target2, false)
    end
  end

  now = mod.getTrackTime()

  -- Should FadeOut be queued or should Play be queued?
  if MusicFading then
    local remFadeTime = Music.getMusicLength() + FadeOutTime - now
    -- print("Music is fading. Next track in " .. remFadeTime .. " seconds.")
    Play({ next = true }, remFadeTime - 0.02)
  else
    local remMusicTime = Music.getMusicLength() - now
    -- print("Music is not fading. Fade in " .. remMusicTime .. " seconds.")
    FadeOut({}, remMusicTime - 0.02)
  end
end

return mod