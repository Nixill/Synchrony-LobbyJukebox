local Color           = require "system.utils.Color"
local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Music           = require "necro.audio.Music"
local Settings        = require "necro.config.Settings"
local SliderMenu      = require "necro.menu.generic.SliderMenu"
local StringUtilities = require "system.utils.StringUtilities"
local Theme           = require "necro.config.Theme"

local SongInfo     = require "LobbyJukebox.info.SongInfo"
local MusicControl = require "LobbyJukebox.mod.MusicControl"
local MusicTimer   = require "LobbyJukebox.mod.MusicTimer"

local function getIcon(which)
  return "/mods/LobbyJukebox/gfx/controls/" .. which .. ".png"
end

local function getTime(v, m)
  m = m or v

  local hrs = tostring(math.floor(v / 3600))
  local mins = tostring(math.floor(v / 60) % 60)
  local secs = tostring(math.floor(v) % 60)

  if m >= 36000 then
    return StringUtilities.leftPad(hrs, 2, "0")
      .. ":" .. StringUtilities.leftPad(mins, 2, "0")
      .. ":" .. StringUtilities.leftPad(secs, 2, "0")
  elseif m >= 3600 then
    return hrs
      .. ":" .. StringUtilities.leftPad(mins, 2, "0")
      .. ":" .. StringUtilities.leftPad(secs, 2, "0")
  elseif m >= 600 then
    return StringUtilities.leftPad(mins, 2, "0")
      .. ":" .. StringUtilities.leftPad(secs, 2, "0")
  else
    return mins
      .. ":" .. StringUtilities.leftPad(secs, 2, "0")
  end
end

local selectPrev = function() Menu.changeSelection(-1, true) end
local selectNext = function() Menu.changeSelection(1, true) end

Event.menu.add("nowPlaying", "LobbyJukebox_nowPlaying", function(ev)
  Menu.suppressKeyControlForTick()

  local info = SongInfo.getSongInfo()

  local firstLine = ""
  local secondLine = ""
  local thirdLine = ""

  if info.title then
    firstLine = "Title: " .. info.title
  elseif info.songType == "zone" then
    firstLine = info.titleInfo
  elseif info.songType == "boss" then
    firstLine = "Boss: " .. info.titleInfo
  end

  if info.artist then
    secondLine = "Artist: " .. info.artist
  end

  if info.vocals then
    thirdLine = "Vocals: " .. info.vocals
  end

  local entries = {
    {
      id = "nowPlaying.title",
      label = firstLine,
      action = function() end,
      selectableIf = false,
      x = -340,
      alignX = 0,
      maxWidth = 680
    },
    {
      id = "nowPlaying.artist",
      label = secondLine,
      action = function() end,
      selectableIf = false,
      x = -340,
      alignX = 0,
      maxWidth = 680
    },
    {
      id = "nowPlaying.vocals",
      label = thirdLine,
      action = function() end,
      selectableIf = false,
      x = -340,
      alignX = 0,
      maxWidth = 680
    },
    {
      id = "nowPlaying.time",
      label = function()
        return getTime(MusicTimer.getTrackTime(), MusicTimer.getTrackLength()) ..
          "/" .. getTime(MusicTimer.getTrackLength())
      end,
      action = function() end,
      selectableIf = false,
      x = -340,
      alignX = 0,
      maxWidth = 680
    },
    {
      id = "nowPlaying.restart",
      action = MusicTimer.restart,
      icon = {
        image = getIcon("restart"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      x = -175,
      y = 200,
      alignX = 0,
      width = 48,
      height = 48,
      boundingBox = {
        -175 - 24,
        200 - 24,
        48,
        48
      },
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    -- { -- This is disabled because I've frozen the game THREE TIMES by clicking it.
    --   id = "nowPlaying.rewind",
    --   icon = {
    --     image = getIcon("backward"),
    --     selectionTint = Theme.Color.HIGHLIGHT
    --   },
    --   action = MusicTimer.seekBackward,
    --   x = -150,
    --   y = 200,
    --   alignX = 0,
    --   width = 48,
    --   height = 48,
    --   boundingBox = {
    --     -150 - 24,
    --     200 - 24,
    --     48,
    --     48
    --   },
    --   leftAction = selectPrev,
    --   rightAction = selectNext,
    --   upAction = function() end,
    --   downAction = function() end
    -- },
    {
      id = "nowPlaying.playPause",
      icon = function()
        local icn = {
          selectionTint = Theme.Color.HIGHLIGHT
        }
        icn.image = getIcon(MusicTimer.isPaused() and "play" or "pause")
        return icn
      end,
      action = MusicTimer.togglePause,
      x = -125,
      y = 200,
      alignX = 0,
      boundingBox = {
        -125 - 24,
        200 - 24,
        48,
        48
      },
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    {
      id = "nowPlaying.forward",
      icon = {
        image = getIcon("forward"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      action = MusicTimer.seekForward,
      x = -75,
      y = 200,
      alignX = 0,
      boundingBox = {
        -75 - 24,
        200 - 24,
        48,
        48
      },
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    {
      id = "nowPlaying.skip",
      icon = {
        image = getIcon("next"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      action = MusicTimer.play,
      x = -25,
      y = 200,
      alignX = 0,
      boundingBox = {
        -25 - 24,
        200 - 24,
        48,
        48
      },
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    {
      id = "nowPlaying.shuffle",
      icon = function()
        return {
          image = getIcon(MusicControl.isShuffled() and "shuffle" or "shuffle_off"),
          selectionTint = Theme.Color.HIGHLIGHT,
        }
      end,
      action = MusicControl.setShuffled,
      x = 25,
      y = 200,
      alignX = 0,
      boundingBox = {
        25 - 24,
        200 - 24,
        48,
        48
      },
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    {
      id = "nowPlaying.loop",
      icon = function()
        return {
          image = getIcon(MusicTimer.isLooped() and "loop" or "loop_off"),
          selectionTint = Theme.Color.HIGHLIGHT
        }
      end,
      action = MusicTimer.setLooped,
      x = 75,
      y = 200,
      alignX = 0,
      boundingBox = {
        75 - 24,
        200 - 24,
        48,
        48
      },
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    {
      id = "nowPlaying.playlist",
      icon = {
        image = getIcon("playlist"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      x = 125,
      y = 200,
      alignX = 0,
      boundingBox = {
        125 - 24,
        200 - 24,
        48,
        48
      },
      action = function() Menu.open("LobbyJukebox_playlist") end,
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    },
    {
      id = "nowPlaying.settings",
      icon = {
        image = getIcon("settings"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      x = 175,
      y = 200,
      alignX = 0,
      boundingBox = {
        175 - 24,
        200 - 24,
        48,
        48
      },
      action = function()
        Menu.open("settings", {
          layer = Settings.Layer.USER,
          prefix = "mod.LobbyJukebox",
          showSliders = true,
          LobbyJukebox_noFilter = true
        })
      end,
      leftAction = selectPrev,
      rightAction = selectNext,
      upAction = function() end,
      downAction = function() end
    }
  }

  ev.menu = {
    entries = entries,
    audioFilter = function(t)
      t.music = {
        gain = 1,
        gainHF = 1,
        gainLF = 1
      }
    end,
    width = 750
  }
end)