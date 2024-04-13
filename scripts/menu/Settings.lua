local Event           = require "necro.event.Event"
local Menu            = require "necro.menu.Menu"
local StringUtilities = require "system.utils.StringUtilities"

NoFilter = false

Event.menu.override("settings", { sequence = 1 }, function(func, ev)
  func(ev)

  if StringUtilities.startsWith(ev.arg.prefix, "mod.LobbyJukebox") then
    NoFilter = ev.arg.LobbyJukebox_noFilter

    if NoFilter then
      ev.menu.audioFilter = function(t)
        t.music = {
          gain = 1,
          gainHF = 1,
          gainLF = 1
        }
      end
    end
  end
end)

local mod = {}

function mod.isSettingsAudioFilterDisabled()
  return NoFilter
end

return mod