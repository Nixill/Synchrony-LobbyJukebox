This is where various settings in the mod can be found, compiled into one place so that I can prevent conflicts and stuff.

# Restricted settings
- **ArtistTable** (`artists`) - scripts/menu/ArtistMenu.lua: Controls which artists may play their music.
- **ShopkeeperTable** (`shopkeepers`) - scripts/menu/ShopkeeperMenu.lua: Controls which shopkeepers may sing to the music.
- **LastPlay** (`lastPlay`) - scripts/mod/MusicControl.lua: Which song was last played?

# Invisible settings
- **BlockedSongs** (`blockedSongs`) - scripts/mod/MusicControl.lua: Stores which songs are disabled in the player.

# Visible settings
⚠ indicates advanced settings:

- **Shuffle** (`shuffle`) - scripts/mod/MusicControl.lua: Controls whether or not a randomized queue is used when advancing to the next track.
- **Loop** (`loop`) - scripts/mod/MusicTimer.lua: Controls whether or not a single track loops.
- **ArtistMenu** (`artistMenu`) - scripts/menu/ArtistMenu.lua: Opens the artists menu.
- **ShopkeeperMenu** (`shopkeeperMenu`) - scripts/menu/ArtistMenu.lua: Opens the shopkeepers menu.
- ⚠ **FadeOutTime** (`fadeTime`) - scripts/mod/MusicTimer.lua: Controls how much artificial fade is added to the end of looping songs.
- ⚠ **SeekTime** (`seekTime`) - scripts/mod/MusicTimer.lua: Controls how long the seek buttons actually seek.
