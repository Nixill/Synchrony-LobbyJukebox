local Event      = require "necro.event.Event"
local RNG        = require "necro.game.system.RNG"
local Settings   = require "necro.config.Settings"
local Soundtrack = require "necro.game.data.Soundtrack"
local Utilities  = require "system.utils.Utilities"

local shopkeeperDefaults = {
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

return mod