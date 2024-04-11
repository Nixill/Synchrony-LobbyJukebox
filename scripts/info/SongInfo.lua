local Boss            = require "necro.game.level.Boss"
local Entities        = require "system.game.Entities"
local LevelSequence   = require "necro.game.level.LevelSequence"
local Music           = require "necro.audio.Music"
local Soundtrack      = require "necro.game.data.Soundtrack"
local StringUtilities = require "system.utils.StringUtilities"

local Info = require "LobbyJukebox.info.SongTitleTable"

local mod = {}

function mod.getSongInfo()
  local params = Music.getParameters()
  local titleInfoText = ""
  local titleText
  local artistText
  local vocalsText

  -- Construct the track key and also make basic title/artist text available
  local track = params.type
  if track == "zone" then
    local zone = params.zoneKey or LevelSequence.Zone.names[params.zone]
    local floor = params.floor

    track = "zone " .. zone .. " " .. floor

    local zoneName = LevelSequence.Zone.prettyNames[LevelSequence.Zone[zone] or ""] or zone
    titleInfoText = zoneName .. " Floor " .. floor
  elseif track == "boss" then
    local boss = params.bossKey or Boss.Type.names[params.boss]

    track = "boss " .. boss

    local bossData = (Boss.Type.data[Boss.Type[boss] or ""] or {})
    local bossName

    if bossData.splashTitle then
      bossName = bossData.splashTitle
    elseif bossData.entity then
      local ent = Entities.getEntityPrototype(bossData.entity)
      if ent.friendlyName then
        bossName = ent.friendlyName.name
      end
    end

    bossName = bossName or boss
    titleInfoText = bossName
  else
    titleInfoText = StringUtilities.titleCase(track)
  end

  if params.variant then track = track .. " " .. params.variant end

  -- Get the artist key
  local artist = params.artistKey or Soundtrack.Artist.name[params.artist or -1] or "_unknown"

  -- Get the shopkeeper key
  local shopkeeper = params.vocalsKey or (params.vocals and Soundtrack.Vocals[params.vocals or -1])

  -- Now actually get the song title
  if Info.titles[artist] and Info.titles[artist][track] then
    titleText = Info.titles[artist][track] .. " (" .. titleInfoText .. ")"
  elseif Info.titles._default[track] then
    titleText = Info.titles._default[track] .. " (" .. titleInfoText .. ")"
  end

  -- And the artist credit
  if Info.artists[artist] and Info.artists[artist][track] then
    artistText = (Info.artists[artist]._prefix or "") ..
      Info.artists[artist][track] .. (Info.artists[artist]._suffix or "")
  elseif Info.artists._trackOverrides[track] then
    artistText = Info.artists._trackOverrides[track]
  elseif params.mod and params.mod ~= "" then
    -- Mod tracks should default to unknown artist (which won't display)
  elseif Info.artists[artist] then
    artistText = (Info.artists[artist]._prefix or "") ..
      Info.artists[artist]._default .. (Info.artists[artist]._suffix or "")
  else
    artistText = artist
  end

  -- And the vocalist credit
  if Info.vocals._tracks[track] then
    vocalsText = Info.vocals._tracks[track][shopkeeper] or Info.vocals._tracks[track]._default
  elseif params.mod and params.mod ~= "" then
    -- Do nothing here
  else
    vocalsText = (Soundtrack.Vocals.data[Soundtrack.Vocals[shopkeeper] or -1] or {}).name or shopkeeper
  end

  -- Compute start time
  local playedAt = params.playedAt or 0
  local length = Music.getMusicLength()
  local startTime
  if playedAt == 0 then
    startTime = 0
  else
    startTime = playedAt + length - (playedAt % length)
  end

  if Music.isMusicLooping() then
    length = length + 5
  end

  return {
    title = titleText,
    titleInfo = titleInfoText,
    artist = artistText,
    vocals = vocalsText,
    songType = params.type,
    startedAt = startTime,
    length = length
  }
end

return mod