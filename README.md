# spz-leaderboard

> Leaderboard tablet: race results, standings, classes, records and activity.

![version](https://img.shields.io/badge/version-1.6.0-ff6200) ![SPiceZ-Core](https://img.shields.io/badge/SPiceZ--Core-beta-18181b)

## Overview

A tablet UI opened with `F6`: the race you just finished first, then the archive, rank standings, per-class records and recent activity.

## Features

- Last race results, opened automatically after a race
- Results archive
- Standings and records per class

## Requirements

| Resource | Type |
|---|---|
| `ox_lib` | third-party |
| `spz-core` | SPiceZ module |
| `spz-races` | SPiceZ module |

## Installation

Included in the [txAdmin recipe](https://github.com/SPiceZ21/spz-txrecipe). Manual install:

1. Download `spz-leaderboard` from GitHub (latest release, or the repository) into your `resources` folder.
2. Add to `server.cfg`, after its requirements:

```cfg
ensure spz-leaderboard
```

## Commands

| Command | Who | Description |
|---|---|---|
| `/leaderboard` | player | Open the leaderboard |
| `/raceresults` | player | Open the latest race results |
| `/rankuptest` | dev | Preview the rank-up animation |

## Key binds

Rebindable in **Settings → Key Bindings → FiveM**.

| Action | Default |
|---|---|
| Race results / leaderboard | `F6` |

## Exports

| Export | Side |
|---|---|
| `OpenLastRaceResults` | client |

```lua
exports["spz-leaderboard"]:OpenLastRaceResults(...)
```

---

Part of **SPiceZ-Core** — [documentation](https://github.com/SPiceZ21/Docs) · [all modules](https://github.com/SPiceZ21/Docs/blob/main/modules/README.md)
