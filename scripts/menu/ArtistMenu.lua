local Event      = require "necro.event.Event"
local Menu       = require "necro.menu.Menu"
local RNG        = require "necro.game.system.RNG"
local Settings   = require "necro.config.Settings"
local Soundtrack = require "necro.game.data.Soundtrack"
local TextFormat = require "necro.config.i18n.TextFormat"
local Utilities  = require "system.utils.Utilities"

local LJSettings = require "LobbyJukebox.menu.Settings"

local artistDefaults = {
  _TrackOverrides = {}
}

local ArtistNames = {
  DANNY_B = "Danny B",
  A_RIVAL = "A_Rival",
  FAMILYJULES7X = "FamilyJules",
  VIRT = "Jake Kaufman",
  GIRLFRIEND_RECORDS = "Girlfriend Records",
  OC_REMIX = "OC ReMix",
  CHIPZEL = "Chipzel",
  DANGANRONPA = "Danganronpa",
  GROOVE_COASTER = "Groove Coaster",
  HATSUNE_MIKU = "Hatsune Miku"
}

--[[
  With vanilla necrodancer, this table should look like:
  {
    A_RIVAL = true,
    CHIPZEL = false,
    DANGANRONPA = false,
    DANNY_B = true,
    FAMILYJULES7X = true,
    GIRLFRIEND_RECORDS = true,
    GROOVE_COASTER = false,
    HATSUNE_MIKU = false,
    OC_REMIX = true,
    VIRT = true,
    _TrackOverrides = {}
  }

  But if mods add soundtracks, there will be more keys here. Most of those will be "true".
]]
local aData = Soundtrack.Artist.data
for k, v in pairs(Soundtrack.Artist) do
  local allowByDefault = (
    k ~= "CHIPZEL" -- thanks copyright :)
    and not aData[v].excludeFromRandom
  )

  if (not aData[v].internal) then
    artistDefaults[k] = allowByDefault
  end
end

ArtistTable = Settings.user.table {
  name = "Artist choices",
  desc = "Artists whose soundtracks can be played.",
  id = "artists",
  default = artistDefaults,
  visibility = Settings.Visibility.HIDDEN
}

ArtistMenu = Settings.user.action {
  name = "Change jukebox soundtracks",
  desc = "Change which soundtracks the jukebox can play from.",
  id = "artistMenu",
  order = 3,
  action = function() Menu.open("LobbyJukebox_artistMenu") end
}

Event.contentLoad.add("mergeArtists", { order = "snapshots", sequence = 1 }, function(ev)
  local atCopy = Utilities.fastCopy(ArtistTable)
  atCopy = Utilities.mergeDefaults(artistDefaults, atCopy)
  ArtistTable = atCopy
end)

local mod = {}

function mod.pickArtist()
  local artists = {}
  for k, v in pairs(ArtistTable) do
    if v then table.insert(artists, k) end
  end

  RNG.shuffle(artists, RNG.Channel.SOUNDTRACK)

  for i, v in ipairs(artists) do
    if Soundtrack.Artist[v] and Soundtrack.isArtistAvailable(Soundtrack.Artist[v]) then
      return Soundtrack.Artist[v], v
    end
  end

  return Soundtrack.Artist.DANNY_B, "DANNY_B" -- fallback
end

function mod.getName(key)
  return ArtistNames[key]
end

function mod.getAvailableArtists()
  local artists = {}

  for i, v in ipairs(Soundtrack.Artist.names) do
    if ((not Soundtrack.Artist.data[i].internal) and Soundtrack.isArtistAvailable(i)) then
      artists[#artists + 1] = v
    end
  end

  return artists
end

Event.menu.add("artistMenu", "LobbyJukebox_artistMenu", function(ev)
  local entries = {
  }

  for i, v in ipairs(mod.getAvailableArtists()) do
    table.insert(entries, {
      id = "artist." .. v,
      label = function()
        return TextFormat.checkbox(ArtistTable[v]) .. " " .. mod.getName(v)
      end,
      action = function()
        ArtistTable[v] = not ArtistTable[v]
      end
    })
  end

  ev.menu = {
    entries = entries,
    audioFilter = function(t)
      if LJSettings.isSettingsAudioFilterDisabled() then
        t.music = {
          gain = 1,
          gainLF = 1,
          gainHF = 1
        }
      end
    end,
    label = "Jukebox Soundtracks"
  }
end)

return mod