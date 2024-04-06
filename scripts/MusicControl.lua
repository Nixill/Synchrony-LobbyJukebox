local Boss          = require "necro.game.level.Boss"
local GameMod       = require "necro.game.data.resource.GameMod"
local LevelSequence = require "necro.game.level.LevelSequence"
local RNG           = require "necro.game.system.RNG"
local Soundtrack    = require "necro.game.data.Soundtrack"
local Utilities     = require "system.utils.Utilities"

local ArtistMenu = require "LobbyJukebox.menu.ArtistMenu"

Queue = {}
Pile = {}

local mod = {}

local function getModName(item)
  return item:match("(%w+)_.+")
end

local function addPileIfNotInQueue(item)
  for i, v in ipairs(Queue) do
    if Utilities.deepEquals(item, v) then return end
  end

  table.insert(Pile, item)
end

function mod.clearQueue()
  Queue = {}
end

-- Creates a "pile" of songs from which to draw the queue.
function mod.pileUp()
  Pile = {}

  addPileIfNotInQueue({ type = "lobby" })
  addPileIfNotInQueue({ type = "training" })
  addPileIfNotInQueue({ type = "tutorial" })

  for k, v in pairs(LevelSequence.Zone) do
    local modName = nil
    if v > LevelSequence.Zone.builtInMax then
      modName = getModName(k)
    end
    addPileIfNotInQueue({ type = "zone", zone = k, floor = 1, mod = modName })
    addPileIfNotInQueue({ type = "zone", zone = k, floor = 2, mod = modName })
    addPileIfNotInQueue({ type = "zone", zone = k, floor = 3, mod = modName })
  end

  for k, v in pairs(Boss.Type) do
    if v ~= Boss.Type.NONE then
      local modName = nil
      if v > Boss.Type.builtInMax then
        modName = getModName(k)
      end
      addPileIfNotInQueue({ type = "boss", boss = k, mod = modName })
    end
  end
end

-- Draws songs from the pile into the queue until the queue outsizes the pile
function mod.enqueue()
  while #Queue < #Pile do
    local song = table.remove(Pile, RNG.int(#Pile, RNG.Channel.SOUNDTRACK) + 1)
    table.insert(Queue, song)
    print("Added to queue: " .. Utilities.inspect(song))
  end
end

function mod.getNextTrack()
  mod.pileUp()
  mod.enqueue()

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
      nextTrack.zone = LevelSequence.Zone[nextTrack.zone]
      if not nextTrack.zone then nextTrack = nil end
    elseif nextTrack.type == "boss" then
      nextTrack.boss = Boss.Type[nextTrack.boss]
      if not nextTrack.boss then nextTrack = nil end
    end

    ::retry::
  end

  -- Zone 3: Pick hot or cold
  if nextTrack.type == "zone" and nextTrack.zone == LevelSequence.Zone.ZONE_3 then
    nextTrack.variant = RNG.choice({ "h", "c" }, RNG.Channel.SOUNDTRACK)
  end

  -- Pick an artist
  nextTrack.artist = ArtistMenu.pickArtist()

  -- Pick a shopkeeper (but only for zone musics)
  if nextTrack.type == "zone" then
    nextTrack.vocals = Soundtrack.Vocals.SHOPKEEPER
  end

  print("Now playing: " .. Utilities.inspect(nextTrack))
  return nextTrack
end

return mod