# spz-leaderboard

> Leaderboard tablet — standings, class tables, records, activity · `v1.0.0`

## Overview

`spz-leaderboard` is the front end only. It opens a tablet-style NUI and renders data
fetched from the leaderboard back end that lives in
[spz-races](../spz-races/README.md) (`server/leaderboard/`): global standings, per-class
tables, per-track records and recent session activity.

## Structure

| Side | File | Purpose |
|---|---|---|
| Client | `client/main.lua` | NUI bridge, data callbacks, open/close |
| UI | `ui/index.html` | Layout |
| UI | `ui/script.js` | Tab logic and rendering |
| UI | `ui/style.css` | Styling |

## Commands

| Command | Effect |
|---|---|
| `/leaderboard` | Open the leaderboard tablet |

## Dependencies

`ox_lib` · `spz-races`

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
