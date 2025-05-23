How information is chosen for the Song Titles Table:

First, the "track key" is computed. This starts with the type of the music, which is either `lobby`, `training`, `tutorial`, `zone`, or `boss`. In the case of the first three, that's it.

For `zone`, it's followed by a space, then the enum key of the zone (for example, `ZONE_1` or `MageZone_MAGE_ZONE`), then another space, then the floor number within that zone. For example, `zone ZONE_5 2`. If there are variants, another space precedes the variant letter (for example, `zone ZONE_3 3 h`).

For a boss, the word `boss` is followed by a space, then the enum key of the boss (for example, `boss DEATH_METAL` or `boss MageZone_SYMHPONY_OF_SORCERY`). A variant can also follow in the same way as before, such as in `boss FORTISSIMOLE b`.

The below processes will also refer to an "artist key", which is simply the enum key of the artist being played (such as `OC_REMIX` or `DANNY_B`).

## Title
The song's title is in the `titles` key in this table. It's checked as follows:

- If `titles[artistKey]` exists, and `titles[artistKey][trackKey]` exists, then that's the title for the track. (Example: `titles.FAMILYJULES7X["zone ZONE_1 1"] = "Infernal Descent"` overrides `titles._default["zone ZONE_1 1"] = "Disco Descent"`)
- Otherwise, if `titles._default[trackKey]` exists, then that's the title for the track. (Example: `titles._default["boss FRANKENSTEINWAY"] = "Steinway to Heaven"`)
- Otherwise, the track has no title.

Then basic track information is added (such as "Death Metal" or "Zone 1 Floor 1").

## Artist
The song's artist is slightly more complicated, because it can change on both a per-track *and* per-artist basis, and there can be prefixes and suffixes. It's in the `artists` key in the table, and checked as follows:

- If `artists[artistKey]` exists, and `artists[artistKey][trackKey]` exists, then that (with prefix and suffix) is the artist credit. (Example: `artists.HATSUNE_MIKU["zone ZONE_4 1"] = "AlexTrip Sands"`)
- Otherwise, if `artists._trackOverrides[track]` exists, then that's the artist credit. (Example: `artists._trackOverrides["zone MageZone_MAGE_ZONE 2"] = "Creepslime"`)
- Otherwise, if the music comes from a mod, there is no artist credit.
- Otherwise, if `artists[artistKey]` exists, then its `_default` (with prefix and suffix) is the artist credit. (Example: `artists.DANNY_B._default = "Danny Baranowsky"`).

"With prefix and suffix" means that if `artists[artistKey]._prefix` exists, that gets prepended to the artist name (for example, Girlfriend Records puts "Girlfriend Records - " before the individual artists' names), and if `artists[artistKey]._suffix` exists, that gets appended to the artist name (for example, Hatsune Miku adds " & Hatsune Miku" after the individual artists' names). So for example, Miku's zone 4 floor 1 is credited as "AlexTrip Sands & Hatsune Miku".

## Vocals
This is only used for Fortissimole, but it would also work for mod music. `shopkeeperKey` is the enum key of the shopkeeper in use.

- If `vocals._tracks[trackKey]` exists:
  - If `vocals._tracks[trackKey][shopkeeperKey]` exists, use that as the vocalist credit.
  - Otherwise, if `vocals._tracks[trackKey]._default` exists, use that as the vocalist credit. (This is used to credit Mega Ran as Fortissimole.)
- Otherwise, if the current track comes from a mod, do not list a vocalist credit.
- Otherwise, try to get the vocalist's name from the Vocals enum. Use the enum key if that doesn't work.

# Pull Request Guidelines
If you are pull requesting song or artist titles, please abide by the following rules:
1. Cite your sources. Make sure the citation is something you can link to; "it's in the mod's zip file" is not an acceptable source.
2. Only submit one mod's songs per pull request.
3. Do not alter any existing data, unless it is a correction to data you've previously submitted or data about your own mod's music.
4. Do not delete any existing data, unless it is about your own mod's music.
5. Do not submit data for the following mods whose creators have requested to be excluded from LobbyJukebox:
   1. *(Nobody has, but I'm putting this here anyway in case someone does.)*
