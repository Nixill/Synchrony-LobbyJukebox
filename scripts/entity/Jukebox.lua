local Collision      = require "necro.game.tile.Collision"
local Components     = require "necro.game.data.Components"
local CurrentLevel   = require "necro.game.level.CurrentLevel"
local CustomEntities = require "necro.game.data.CustomEntities"
local Event          = require "necro.event.Event"
local LocalCoop      = require "necro.client.LocalCoop"
local Menu           = require "necro.menu.Menu"
local MinimapTheme   = require "necro.game.data.tile.MinimapTheme"
local Object         = require "necro.game.object.Object"
local Ping           = require "necro.client.Ping"
local Turn           = require "necro.cycles.Turn"

local interactedTurnID = -1
interactedTurnID = script.persist(function() return interactedTurnID end)

Components.register {
  -- Interaction with an entity with this component will open the
  -- "LobbyJukebox2_nowPlaying" menu.
  LobbyJukebox2_interactableOpenJukebox = {}
}

CustomEntities.register {
  name = "LobbyJukebox2_Jukebox",
  collision = {
    mask = Collision.Type.OBJECT
  },
  friendlyName = {
    name = "The Jukebox"
  },
  gameObject = {},
  interactable = {},
  LobbyJukebox2_interactableOpenJukebox = {},
  minimapStaticPixel = {
    depth = MinimapTheme.Depth.SHRINE,
    color = MinimapTheme.Color.SHRINE,
    alwaysVisible = true
  },
  normalAnimation = {
    frames = {
      1, 2, 3, 4, 5, 6
    }
  },
  pingable = {
    type = Ping.Type.CONTAINER
  },
  position = {},
  positionalSprite = {
    offsetX = -1,
    offsetY = -7
  },
  rowOrder = {
    z = 20
  },
  shadow = {
    offsetY = 3
  },
  shadowPosition = {},
  silhouette = {},
  sprite = {
    texture = "/mods/LobbyJukebox2/gfx/Jukebox.png",
    width = 26,
    height = 36
  },
  spriteSheet = {},
  visibility = {}
}

Event.levelLoad.add("spawnJukebox", { order = "lobbyLevel", sequence = 1 }, function(ev)
  if CurrentLevel.isLobby() then
    interactedTurnID = -1
    Object.spawn("LobbyJukebox2_Jukebox", -5, -1)
  end
end)

Event.objectInteract.add("openJukeboxMenu", {
  order = "configInteractable",
  sequence = 1,
  filter = "LobbyJukebox2_interactableOpenJukebox"
}, function(ev)
  if ev.interactor and ev.interactor.controllable and LocalCoop.isLocal(ev.interactor.controllable.playerID) then
    -- Avoid menu opening multiple times with multiple local players
    local turnID = Turn.getCurrentTurnID()
    if turnID > interactedTurnID then
      interactedTurnID = turnID
      Menu.open("LobbyJukebox2_nowPlaying")
      Menu.selectByID("nowPlaying.playPause")
    end
  end
end)