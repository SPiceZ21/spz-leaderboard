# spz-leaderboard

> Leaderboard tablet — race results, standings, class tables, records, activity · `v1.1.0`

## Overview

`spz-leaderboard` is the front end only. It opens a tablet-style NUI and renders data
fetched from the leaderboard back end that lives in
[spz-races](../spz-races/README.md) (`server/leaderboard/`): global standings, per-class
tables, per-track records, the **race archive**, and recent session activity.

## Structure

| Side | File | Purpose |
|---|---|---|
| Client | `client/main.lua` | NUI bridge, data callbacks, open/close |
| UI | `ui/index.html` | Layout |
| UI | `ui/script.js` | Tab logic and rendering |
| UI | `ui/style.css` | Styling |

## Race results

The **Races** tab is the archive: every race that has been run, newest first — track,
class, laps, drivers, length and winner. Open one for its full classification: finishers in
position order with gaps to the winner, then retirements with their reason. Each row
expands for that driver's points, XP, iRating and safety change.

Data comes from `spz-races:getRaceArchive` and `spz-races:getRaceResults`.

## Commands and keys

| Key | Command | Effect |
|---|---|---|
| `F6` | `/leaderboard` | Opens the race you just drove if one finished in the last 5 minutes, otherwise the leaderboard |
| — | `/raceresults` | Your last race's classification, no freshness window |

`F6` is a **default** binding, rebindable in Settings. The key is declared once here and
pushed to the race HUD's key strip through `spz-raceUI:SetKeyHints`, so the HUD prints
whatever this resource registered.

### Why a freshness window

The board is a general leaderboard as well as a results screen. Deep-linking forever would
mean pressing the key an hour later still drops you into a race you have stopped caring
about; never deep-linking would mean hunting the archive for the race you just finished.
Five minutes covers the post-race screen and the intermission.

## Exports

| Export | Effect |
|---|---|
| `OpenLastRaceResults` | Open the board on the last race this player finished |

## Dependencies

`ox_lib` · `spz-races`

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
