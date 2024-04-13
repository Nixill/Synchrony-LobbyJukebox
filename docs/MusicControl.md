# Classes
## MusicControl.Params
Is a table with the following information, depending on when it's obtained.

From `getNextTrackSequential()` or `getNextTrackShuffled()`:
- `bossKey`: One of the keys of `Boss.Type`, only if `type` == `"boss"`
- `floor`: A number 1 through 3, only if `type` == `"zone"`
- `mod`: Which mod the track (zone or boss) is from. `""` for base game tracks.
- `type`: One of the values of `Soundtrack.TrackType`, but only the following: `"lobby"`, `"tutorial"`, `"training"`, `"zone"`, or `"boss"`
- `zoneKey`: One of the keys of `LevelSequence.Zone`, only if `type` == `"zone"`

From `getNextTrack()`:
- All of the above keys
- `variant`: Either `"c"` or `"h"` if `zoneKey` is `"ZONE_3"`; `nil` otherwise.
- `artistKey`: One of the keys of `Soundtrack.Artist`.
- `vocalsKey`: One of the keys of `Soundtrack.Vocals`, only if `type` is `"zone"`. `nil` otherwise.

# Functions

## `clearQueue()`: nil
Clears the shuffled music queue, forcing it to rebuild when next needed.

## `getNextTrack()`: MusicControl.Params
Returns the next track to play, whether shuffled or sorted, based on the shuffle setting.

## `getNextTrackSequential()`: MusicControl.Params
Gets the next track in sequence (from the currently playing or last-played one).

## `getNextTrackShuffled()`: MusicControl.Params
Returns the next track from the shuffled queue, adding to it afterwards.

## `getSequence()`: list\[MusicControl.Params\]
Gets the sorted music sequence, building it from scratch if not cached.

## `isShuffled()`: boolean
Returns whether or not shuffle is enabled in the user's settings.

## `setShuffled(val)`: nil
Changes whether or not shuffle is enabled.

Params:
- boolean **`val`**: The value to set. If not specified, defaults to the opposite of its current state.

# Settings
## `shuffle`
A boolean setting, defaulting to `true`. Controls whether tracks are played on shuffle or not.
