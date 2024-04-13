local DropdownMenu = require "necro.menu.generic.DropdownMenu"
local Menu         = require "necro.menu.Menu"
local Soundtrack   = require "necro.game.data.Soundtrack"
local TextFormat   = require "necro.config.i18n.TextFormat"
local Utilities    = require "system.utils.Utilities"

local MusicControl   = require "LobbyJukebox.mod.MusicControl"
local MusicTimer     = require "LobbyJukebox.mod.MusicTimer"
local ArtistMenu     = require "LobbyJukebox.menu.ArtistMenu"
local ShopkeeperMenu = require "LobbyJukebox.menu.ShopkeeperMenu"

local mod = {}

function mod.hasMultipleVariants(track)
  if track.type == "lobby" or track.type == "training" then
    return true
  elseif track.type == "tutorial" then
    return false
  elseif track.type == "zone" then
    if ({
        ZONE_1 = true,
        ZONE_2 = true,
        ZONE_3 = true,
        ZONE_4 = true,
        ZONE_5 = true
      })[track.zoneKey] then
      return true
    else
      return false
    end
  elseif track.type == "boss" then
    if ({
        KING_CONGA = true,
        DEATH_METAL = true,
        DEEP_BLUES = true,
        CORAL_RIFF = true,
        FORTISSIMOLE = true,
        MageZone_SYMPHONY_OF_SORCERY = true,
        MageZone_SYMHPONY_OF_SORCERY = true
      })[track.bossKey] then
      return true
    else
      return false
    end
  end
end

local function artistAmongFunc(set)
  return function(itm)
    if set[itm] then
      return itm
    else
      return nil
    end
  end
end

local function artistNotAmongFunc(set)
  return function(itm)
    if set[itm] then
      return nil
    else
      return itm
    end
  end
end

function mod.getArtistsFor(track)
  local artists = ArtistMenu.getAvailableArtists()

  if track.type == "lobby" then
    return Utilities.map(artists, artistNotAmongFunc { HATSUNE_MIKU = true })
  elseif track.type == "training" then
    return Utilities.map(artists, artistAmongFunc { DANNY_B = true, OC_REMIX = true })
  elseif track.type == "tutorial" then
    return { "DANNY_B" }
  elseif track.type == "zone" then
    if ({ ZONE_1 = true, ZONE_2 = true, ZONE_3 = true, ZONE_4 = true })[track.zoneKey] then
      return artists -- just all of them
    elseif track.zoneKey == "ZONE_5" then
      return Utilities.map(artists, artistNotAmongFunc { GROOVE_COASTER = true, DANGANRONPA = true })
    else
      return { "DANNY_B" }
    end
  elseif track.type == "boss" then
    if ({ KING_CONGA = true, DEATH_METAL = true, DEEP_BLUES = true, CORAL_RIFF = true })[track.bossKey] then
      return Utilities.map(artists, artistNotAmongFunc { HATSUNE_MIKU = true })
    elseif track.bossKey == "FORTISSIMOLE" then
      return Utilities.map(artists, artistNotAmongFunc { GROOVE_COASTER = true, DANGANRONPA = true, HATSUNE_MIKU = true })
    elseif ({ DEAD_RINGER = true, NECRODANCER = true, NECRODANCER_2 = true, GOLDEN_LUTE = true, FRANKENSTEINWAY = true, CONDUCTOR = true })[track.bossKey] then
      return { "DANNY_B" }
    else
      return { "DANNY_B" }
    end
  else
    return { "DANNY_B" }
  end
end

function mod.getVocalistsFor(track)
  local vocalists = ShopkeeperMenu.getAvailableVocalists()

  if track.type == "zone" then
    if (Soundtrack.Artist.data[Soundtrack.Artist[track.artistKey or ""] or 0] or {}).shopkeeper ~= false then
      if track.mod == "" then
        return vocalists
      end
    end
  end

  return {}
end

function mod.getVariantsFor(track)
  if track.zoneKey == "ZONE_3" and not ({ HATSUNE_MIKU = true })[track.artistKey] then
    return { { id = "h", name = "Hot" }, { id = "c", name = "Cold" } }
  elseif track.bossKey == "DEATH_METAL" and track.artistKey == "FAMILYJULES7X" then
    return { { id = "", name = "Default" }, { id = "a", name = "Polka" } }
  elseif track.bossKey == "FORTISSIMOLE" and track.artistKey == "GIRLFRIEND_RECORDS" then
    return { { id = "", name = "Johnatron" }, { id = "a", name = "Sferro" }, { id = "b", name = "Tommy '86" } }
  end

  return {}
end

local lt = Soundtrack.LayerType

function mod.getLayersFor(track)
  if track.bossKey == "CORAL_RIFF" and track.artistKey == "DANNY_B" then
    return {
      { id = lt.TENTACLE_DRUMS,   name = "Drums" },
      { id = lt.TENTACLE_HORNS,   name = "Horns" },
      { id = lt.TENTACLE_STRINGS, name = "Strings" },
      { id = lt.TENTACLE_KEYTAR,  name = "Keytar" }
    }
  elseif track.bossKey == "FORTISSIMOLE" then
    return {
      { id = lt.FORTISSIMOLE, name = "Vocals" }
    }
  elseif track.bossKey == "MageZone_SYMPHONY_OF_SORCERY"
    or track.bossKey == "MageZone_SYMHPONY_OF_SORCERY" then
    return {
      { id = lt.MageZone_DRUMS,       name = "Drums" },
      { id = lt.MageZone_KEYBOARD,    name = "Keyboard" },
      { id = lt.MageZone_FLUTE,       name = "Flute" },
      { id = lt.MageZone_CONTRABASS,  name = "Contrabass" },
      { id = lt.MageZone_FRENCH_HORN, name = "French horn" },
      { id = lt.MageZone_CLARINET,    name = "Clarinet" },
      { id = lt.MageZone_XYLOPHONE,   name = "Xylophone" },
      { id = lt.MageZone_TRUMPET,     name = "Trumpet" },
      { id = lt.MageZone_HARP,        name = "Harp" },
      { id = lt.MageZone_LUTE,        name = "Lute" }
    }
  end

  return {}
end

function mod.openArtistDropdown(track)
  track.deterministic = true

  local artists = mod.getArtistsFor(track)

  if #artists > 1 then
    local entries = {}

    for i, v in ipairs(artists) do
      table.insert(entries, {
        label = ArtistMenu.getName(v),
        action = function()
          track.artistKey = v
          mod.openVocalistDropdown(track)
        end
      })
    end

    DropdownMenu.open { entries = entries }
  elseif #artists == 1 then
    track.artistKey = artists[1]
    mod.openVocalistDropdown(track)
  end
end

function mod.openVocalistDropdown(track)
  local vocalists = mod.getVocalistsFor(track)

  if #vocalists == 0 or #vocalists == 1 then
    if #vocalists == 1 then
      track.vocalsKey = Soundtrack.Vocals
    end
    mod.openVariantDropdown(track)
  else
    local entries = {}
    for i, v in ipairs(vocalists) do
      table.insert(entries, {
        label = Soundtrack.Vocals.data[Soundtrack.Vocals[v]].name or v,
        action = function()
          track.vocalsKey = v
          mod.openVariantDropdown(track)
        end
      })
    end

    DropdownMenu.open { entries = entries }
  end
end

function mod.openVariantDropdown(track)
  local variants = mod.getVariantsFor(track)

  if #variants == 0 or #variants == 1 then
    if #variants == 1 then
      track.variant = variants.id
    end
    mod.openLayersDropdown(track)
  else
    local entries = {}
    for i, v in ipairs(variants) do
      table.insert(entries, {
        label = v.name,
        action = function()
          track.variant = v.id
          mod.openLayersDropdown(track)
        end
      })
    end

    DropdownMenu.open { entries = entries }
  end
end

function mod.openLayersDropdown(track)
  local layers = mod.getLayersFor(track)

  if #layers == 0 then
    mod.finallyPlay(track)
  else
    local entries = {}
    track.playLayers = {}
    for i, v in ipairs(layers) do
      table.insert(entries, {
        label = function()
          local layerEnabled = track.playLayers[v.id]
          return TextFormat.checkbox(layerEnabled) .. " " .. v.name
        end,
        action = function()
          track.playLayers[v.id] = not track.playLayers[v.id]
        end,
        autoClose = false
      })
      track.playLayers[v.id] = true
    end
    table.insert(entries, {
      label = "Play",
      action = function()
        mod.finallyPlay(track)
      end
    })

    DropdownMenu.open { entries = entries }
  end
end

function mod.finallyPlay(track)
  MusicTimer.play(MusicControl.getSpecificTrack(track))
  Menu.updateAll()
  Menu.closeNamed("LobbyJukebox_playlist")
end

return mod