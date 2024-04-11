local Boss          = require "necro.game.level.Boss"
local GameMod       = require "necro.game.data.resource.GameMod"
local LevelSequence = require "necro.game.level.LevelSequence"
local Music         = require "necro.audio.Music"
local RNG           = require "necro.game.system.RNG"
local Soundtrack    = require "necro.game.data.Soundtrack"
local Utilities     = require "system.utils.Utilities"

local ArtistMenu     = require "LobbyJukebox.menu.ArtistMenu"
local ShopkeeperMenu = require "LobbyJukebox.menu.ShopkeeperMenu"

Queue = {}
-- By making this a local variable, it'll persist *until* a mod reload.
-- That's exactly what we want, so that the sequence is always up to date.
local sequence = nil

-- Temp
local Shuffle = true

local mod = {}

local function getModName(item)
  return item:match("(%w+)_.+")
end

local function isInQueue(item)
  for i, v in ipairs(Queue) do
    if Utilities.deepEquals(item, v) then return true end
  end
  return false
end

function mod.clearQueue()
  Queue = {}
end

function mod.getSequence()
  if not sequence then
    sequence = {
      { type = "lobby" },
      { type = "training" },
      { type = "tutorial" }
    }

    local zonesByMod = {}
    local storyBossesByMod = {}
    local nonStoryBossesByMod = {}
    local musicMods = {}

    for v, k in ipairs(LevelSequence.Zone.names) do
      local modName = ""
      if v > LevelSequence.Zone.builtInMax then
        modName = getModName(k)
      end

      local tbl = zonesByMod[modName] or {}
      table.insert(tbl, k)
      zonesByMod[modName] = tbl

      musicMods[modName] = true
    end

    for v, k in ipairs(Boss.Type.names) do
      local modName = ""
      if v > Boss.Type.builtInMax then
        modName = getModName(k)
      end

      if Boss.Type.data[v].story then
        local tbl = storyBossesByMod[modName] or {}
        table.insert(tbl, k)
        storyBossesByMod[modName] = tbl
      else
        local tbl = nonStoryBossesByMod[modName] or {}
        table.insert(tbl, k)
        nonStoryBossesByMod[modName] = tbl
      end

      musicMods[modName] = true
    end

    for i, v in ipairs(Utilities.sort(Utilities.getKeyList(musicMods))) do
      local zones = zonesByMod[v] or {}
      local nsBosses = nonStoryBossesByMod[v] or {}
      local sBosses = storyBossesByMod[v] or {}

      while #zones > 0 or #nsBosses > 0 or #sBosses > 0 do
        local zone = table.remove(zones, 1)
        if zone then
          table.insert(sequence, { type = "zone", zoneKey = zone, floor = 1, mod = v })
          table.insert(sequence, { type = "zone", zoneKey = zone, floor = 2, mod = v })
          table.insert(sequence, { type = "zone", zoneKey = zone, floor = 3, mod = v })
        end

        local boss = table.remove(nsBosses, 1) or table.remove(sBosses, 1)
        if boss then
          table.insert(sequence, { type = "boss", bossKey = boss, mod = v })
        end
      end
    end
  end

  return Utilities.fastCopy(sequence)
end

-- Creates a "pile" of songs from which to draw the queue.
local function pileUp()
  local pile = mod.getSequence()

  return Utilities.map(pile, function(itm)
    if isInQueue(itm) then
      return nil
    else
      return itm
    end
  end)
end

-- Draws songs from the pile into the queue until the queue outsizes the pile
local function enqueueTracks()
  local pile = pileUp()

  while #Queue < #pile do
    local song = table.remove(pile, RNG.int(#pile, RNG.Channel.SOUNDTRACK) + 1)
    table.insert(Queue, song)
    print("Added to queue: " .. Utilities.inspect(song))
  end
end

-- Gets the position of the current song in the queue.
local function getCurrentPosition()
  local seq = mod.getSequence()
  local thisTrack = Music.getParameters()

  if thisTrack == nil then
    return 0
  end

  local pos = 0

  if thisTrack.type == "lobby" then
    return 1
  elseif thisTrack.type == "training" then
    return 2
  elseif thisTrack.type == "tutorial" then
    return 3
  else
    pos = 3
    for i = 4, #seq do
      local testTrack = seq[i]
      if thisTrack.mod == testTrack.mod then
        if thisTrack.type == testTrack.type
          and thisTrack.bossKey == testTrack.bossKey
          and thisTrack.zoneKey == testTrack.zoneKey
          and thisTrack.floor == testTrack.floor then
          return i
        end
      elseif testTrack.mod > thisTrack.mod then
        return pos
      else
        pos = i
      end
    end

    return pos
  end
end

function mod.getNextTrackShuffled()
  enqueueTracks()

  -- Pick the main track
  local nextTrack = nil
  while not nextTrack do
    nextTrack = table.remove(Queue, 1)
    print("Removed from queue: " .. Utilities.inspect(nextTrack))

    if not nextTrack then
      nextTrack = { type = "lobby" } -- fallback
      break
    end

    -- Make the zone or boss use the right keys
    if nextTrack.type == "zone" then
      nextTrack.zone = LevelSequence.Zone[nextTrack.zoneKey]
      if not nextTrack.zone then nextTrack = nil end
    elseif nextTrack.type == "boss" then
      nextTrack.boss = Boss.Type[nextTrack.bossKey]
      if not nextTrack.boss then nextTrack = nil end
    end

    ::retry::
  end

  return nextTrack
end

function mod.getNextTrackSequential()
  local seq = mod.getSequence()

  -- Find the current position
  local pos = getCurrentPosition()
  local nextTrack

  if pos == #seq then
    nextTrack = seq[1]
  else
    nextTrack = seq[pos + 1]
  end

  if nextTrack.type == "zone" then
    nextTrack.zone = LevelSequence.Zone[nextTrack.zoneKey]
  elseif nextTrack.type == "boss" then
    nextTrack.boss = Boss.Type[nextTrack.bossKey]
  end

  return nextTrack
end

function mod.getNextTrack()
  local nextTrack

  if Shuffle then
    nextTrack = mod.getNextTrackShuffled()
  else
    nextTrack = mod.getNextTrackSequential()
  end

  -- Zone 3: Pick hot or cold
  if nextTrack.type == "zone" and nextTrack.zone == LevelSequence.Zone.ZONE_3 then
    nextTrack.variant = RNG.choice({ "h", "c" }, RNG.Channel.SOUNDTRACK)
  end

  -- Pick an artist
  nextTrack.artist, nextTrack.artistKey = ArtistMenu.pickArtist()

  -- Pick a shopkeeper (but only for zone musics)
  if nextTrack.type == "zone" then
    nextTrack.vocals, nextTrack.vocalsKey = ShopkeeperMenu.pickShopkeeper()
  end

  nextTrack.playedAt = math.max(Music.getMusicTime(), 0)

  print("Now playing: " .. Utilities.inspect(nextTrack))
  return nextTrack
end

return mod