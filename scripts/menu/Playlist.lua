local Color           = require "system.utils.Color"
local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local Music           = require "necro.audio.Music"
local Settings        = require "necro.config.Settings"
local SliderMenu      = require "necro.menu.generic.SliderMenu"
local StringUtilities = require "system.utils.StringUtilities"
local Theme           = require "necro.config.Theme"
local Utilities       = require "system.utils.Utilities"

local SongInfo     = require "LobbyJukebox.info.SongInfo"
local MusicControl = require "LobbyJukebox.mod.MusicControl"
local MusicTimer   = require "LobbyJukebox.mod.MusicTimer"
local Variants     = require "LobbyJukebox.info.Variants"

local mod = {}

local function getIcon(which)
  return "/mods/LobbyJukebox/gfx/controls/" .. which .. ".png"
end

local function generateTreeKey(params, suffix)
  local out
  if params.type == "boss" then
    out = "playlist.boss." .. params.bossKey
  elseif params.type == "zone" then
    out = "playlist.zone." .. params.zoneKey .. ".floor" .. params.floor
  else
    out = "playlist." .. params.type
  end

  if suffix then
    return out .. "." .. suffix
  else
    return out
  end
end

local function lAction() Menu.changeSelection(-1, true) end
local function rAction() Menu.changeSelection(1, true) end
local function uAction() Menu.changeSelection(-3, true) end
local function dAction() Menu.changeSelection(3, true) end

local function playSongAction(params)
  return function()
    MusicTimer.play(MusicControl.getSpecificTrack(params))
    Menu.close()
  end
end

local function songBlockAction(params)
  return function()
    MusicControl.setSongBlocked(params)
  end
end

Event.menu.add("playlist", "LobbyJukebox_playlist", function(ev)
  local entries = {}

  local sequence = MusicControl.getSequence()

  for i, v in ipairs(sequence) do
    local title = SongInfo.getTitleInfo(v)
    table.insert(entries, {
      id = generateTreeKey(v, "label"),
      label = title,
      action = function() end, -- to make it appear full bright
      selectableIf = false,
      alignX = 0,
      x = -240,
      y = 50 * i - 40,
      maxWidth = 300
    })
    table.insert(entries, {
      id = generateTreeKey(v, "checkbox"),
      icon = function()
        return {
          image = getIcon(MusicControl.isSongBlocked(v) and "checkbox_off" or "checkbox_on"),
          selectionTint = Theme.Color.HIGHLIGHT
        }
      end,
      action = songBlockAction(v),
      x = 90,
      y = 50 * i - 40,
      boundingBox = {
        90 - 24,
        50 * i - 40 - 24,
        48,
        48
      },
      leftAction = lAction,
      rightAction = rAction,
      upAction = uAction,
      downAction = dAction
    })
    table.insert(entries, {
      id = generateTreeKey(v, "playNow"),
      icon = {
        image = getIcon("play"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      action = playSongAction(v),
      x = 140,
      y = 50 * i - 40,
      boundingBox = {
        140 - 24,
        50 * i - 40 - 24,
        48,
        48
      },
      leftAction = lAction,
      rightAction = rAction,
      upAction = uAction,
      downAction = dAction
    })
    table.insert(entries, {
      id = generateTreeKey(v, "playCustom"),
      icon = {
        image = getIcon("dot_menu"),
        selectionTint = Theme.Color.HIGHLIGHT
      },
      action = function()
        Variants.openArtistDropdown(Utilities.fastCopy(v))
      end,
      enableIf = Variants.hasMultipleVariants(v),
      x = 190,
      y = 50 * i - 40,
      boundingBox = {
        190 - 24,
        50 * i - 40 - 24,
        48,
        48
      },
      leftAction = lAction,
      rightAction = rAction,
      upAction = uAction,
      downAction = dAction
    })
  end

  ev.menu = {
    entries = entries,
    audioFilter = function(t)
      t.music = {
        gain = 1,
        gainHF = 1,
        gainLF = 1
      }
    end,
    width = 550
  }
end)

return mod