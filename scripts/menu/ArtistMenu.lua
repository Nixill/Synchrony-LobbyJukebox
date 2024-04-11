local Event      = require "necro.event.Event"
local RNG        = require "necro.game.system.RNG"
local Settings   = require "necro.config.Settings"
local Soundtrack = require "necro.game.data.Soundtrack"
local Utilities  = require "system.utils.Utilities"

local artistDefaults = {
  _TrackOverrides = {}
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

return mod