local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Music           = require "necro.audio.Music"
local Settings        = require "necro.config.Settings"
local SliderMenu      = require "necro.menu.generic.SliderMenu"
local StringUtilities = require "system.utils.StringUtilities"

local SongInfo = require "LobbyJukebox.info.SongInfo"

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
        local t = Music.getMusicTime()
        local progress = t - info.startedAt
        return getTime(progress, info.length) .. "/" .. getTime(info.length)
      end,
      action = function() end,
      selectableIf = false,
      x = -340,
      alignX = 0,
      maxWidth = 680
    },
    { height = 0 },
    {
      id = "nowPlaying.skip",
      label = "Skip",
      action = function() end
    },
    {
      id = "nowPlaying.settings",
      label = "Settings",
      action = function() end
    },
    {
      id = "nowPlaying.back",
      label = "Back",
      action = function() Menu.close() end
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