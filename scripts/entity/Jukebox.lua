local Collision      = require "necro.game.tile.Collision"
local Components     = require "necro.game.data.Components"
local CustomEntities = require "necro.game.data.CustomEntities"
local Event          = require "necro.event.Event"
local Menu           = require "necro.menu.Menu"
local MinimapTheme   = require "necro.game.data.tile.MinimapTheme"
local Object         = require "necro.game.object.Object"
local Ping           = require "necro.client.Ping"

Components.register {
  -- Interaction with an entity with this component will open the
  -- "LobbyJukebox_nowPlaying" menu.
  LobbyJukebox_interactableOpenJukebox = {}
}

CustomEntities.register {
  name = "LobbyJukebox_Jukebox",
  collision = {
    mask = Collision.Type.OBJECT
  },
  friendlyName = {
    name = "The Jukebox"
  },
  gameObject = {},
  interactable = {},
  LobbyJukebox_interactableOpenJukebox = {},
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
    texture = "/mods/LobbyJukebox/gfx/Jukebox.png",
    width = 26,
    height = 36
  },
  spriteSheet = {},
  visibility = {}
}

Event.levelLoad.add("spawnJukebox", { order = "lobbyLevel", sequence = 1 }, function(ev)
  Object.spawn("LobbyJukebox_Jukebox", -5, -1)
end)

Event.objectInteract.add("openJukeboxMenu", {
  order = "configInteractable",
  sequence = 1,
  filter = "LobbyJukebox_interactableOpenJukebox"
}, function(ev)
  Menu.open("LobbyJukebox_nowPlaying")
end)