# Functions
## `getNextLoopPoint(from)`: number
Gets the next music loop point.

Params:
- number **`from`**: The point from which to get the next loop point. Defaults to the current music time.

## `getTrackTime()`: number
Gets the current track time within the loop.

## `getTrackLength()`: number
Gets the current track's length, including artificial fade if applicable.

## `isLooped()`: boolean
Returns whether or not the music is looped.

## `isPaused()`: boolean
Returns whether or not the music is paused.

## `pause()`: nil
Pauses the current track, if it's not already paused.

## `play()`: nil
Plays the next track.

## `restart()`: nil
Restarts the current track.

## `resume()`: nil
Resumes the current track, if it's paused.

## `seekForward(by)`: nil
Seeks backward in the current track.

Parameters:
- number? **`by`**: The amount by which to seek backward. If not specified, defaults to the seek time setting.

## `seekForward(by)`: nil
Seeks forward in the current track.

Parameters:
- number? **`by`**: The amount by which to seek forward. If not specified, defaults to the seek time setting.

## `setLooped(val)`: nil
Sets whether or not the music is looped.

Parameters:
- boolean? **`val`**: The value to set. If not specified, defaults to the opposite of its current state.

## `togglePause()`: nil
Switches whether or not the music is paused.

# Settings
## `loop`
A boolean setting, defaulting to `false`. Controls whether a single track is played on a loop or not.

## `fadeTime`
A number setting, defaulting to `5`. Controls the number of seconds of artificial fade-out added to loopable songs.

## `seekTime`
A number setting, defaulting to `5`. Controls the number of seconds the left- and right-seek buttons seek by.