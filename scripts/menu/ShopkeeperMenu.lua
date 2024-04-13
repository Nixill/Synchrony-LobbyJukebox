local Event      = require "necro.event.Event"
local Menu       = require "necro.menu.Menu"
local RNG        = require "necro.game.system.RNG"
local Settings   = require "necro.config.Settings"
local Soundtrack = require "necro.game.data.Soundtrack"
local TextFormat = require "necro.config.i18n.TextFormat"
local Utilities  = require "system.utils.Utilities"

local LJSettings = require "LobbyJukebox.menu.Settings"

local shopkeeperDefaults = {
  _TrackOverrides = {}
}

--[[
  With vanilla necrodancer, this table should look like:
  {
    MONSTROUS_SHOPKEEPER = false,
    NICOLAS_DAOUST = true,
    NONE = true,
    SHOPKEEPER = true,
    _TrackOverrides = {}
  }

  But if mods add soundtracks, there will be more keys here. Most of those will be "true".
]]
local vData = Soundtrack.Vocals.data
for k, v in pairs(Soundtrack.Vocals) do
  local allowByDefault = (
    k ~= "MONSTROUS_SHOPKEEPER"
  )

  if (not vData[v].internal) then
    shopkeeperDefaults[k] = allowByDefault
  end
end

ShopkeeperTable = Settings.user.table {
  name = "Vocalist choices",
  desc = "Shopkeepers whose vocals can be played.",
  id = "shopkeepers",
  default = shopkeeperDefaults,
  visibility = Settings.Visibility.HIDDEN
}

ShopkeeperMenu = Settings.user.action {
  name = "Change jukebox vocalists",
  desc = "Change which vocalists may sing along to the jukebox.",
  id = "shopkeeperMenu",
  order = 3,
  action = function() Menu.open("LobbyJukebox_shopkeeperMenu") end
}

Event.contentLoad.add("mergeShopkeepers", { order = "snapshots", sequence = 1 }, function(ev)
  local stCopy = Utilities.fastCopy(ShopkeeperTable)
  stCopy = Utilities.mergeDefaults(shopkeeperDefaults, stCopy)
  ShopkeeperTable = stCopy
end)

local mod = {}

function mod.pickShopkeeper()
  local shopkeepers = {}
  for k, v in pairs(ShopkeeperTable) do
    if v then table.insert(shopkeepers, k) end
  end

  RNG.shuffle(shopkeepers, RNG.Channel.SOUNDTRACK)

  for i, v in ipairs(shopkeepers) do
    if Soundtrack.Vocals[v] and Soundtrack.isVocalistAvailable(Soundtrack.Vocals[v]) then
      return Soundtrack.Vocals[v], v
    end
  end

  return Soundtrack.Vocals.NONE, "NONE" -- fallback
end

function mod.getAvailableVocalists()
  local vocalists = {}

  for i, v in ipairs(Soundtrack.Vocals.keyList) do
    if (Soundtrack.isVocalistAvailable(Soundtrack.Vocals[v])) then
      vocalists[#vocalists + 1] = v
    end
  end

  return vocalists
end

Event.menu.add("shopkeeperMenu", "LobbyJukebox_shopkeeperMenu", function(ev)
  local entries = {}

  for i, v in ipairs(mod.getAvailableVocalists()) do
    table.insert(entries, {
      id = "artist." .. v,
      label = function()
        return TextFormat.checkbox(ShopkeeperTable[v]) ..
          " " .. (Soundtrack.Vocals.data[Soundtrack.Vocals[v]].name or v)
      end,
      action = function()
        ShopkeeperTable[v] = not ShopkeeperTable[v]
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
    label = "Jukebox Vocalists"
  }
end)

return mod