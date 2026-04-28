# spz-leaderboard
> Race results, track records, global standings · `v1.1.3`

## Scripts

| Side   | File                        | Purpose                                     |
| ------ | --------------------------- | ------------------------------------------- |
| Shared | `shared/init.lua`           | Shared initialization and type definitions  |
| Shared | `config.lua`                | Resource configuration                      |
| Server | `@oxmysql/lib/MySQL.lua`    | oxmysql database library import             |
| Server | `server/utils.lua`          | Server-side utility helpers                 |
| Server | `server/cache.lua`          | In-memory data cache                        |
| Server | `server/writer.lua`         | Persist race sessions and results to DB     |
| Server | `server/records.lua`        | Track record read/write logic               |
| Server | `server/standings.lua`      | Global standings query and aggregation      |
| Server | `server/stats.lua`          | Per-player statistics computation           |
| Server | `server/snapshot.lua`       | Point-in-time standings snapshot            |
| Server | `server/main.lua`           | Entry point, event and export registration  |
| Client | `client/main.lua`           | NUI bridge, leaderboard display triggers    |

## NUI

**Stack:** Vite · Preact · TypeScript · spz-ui

```
ui/
├── src/
│   ├── app.tsx
│   ├── components/       # spz-ui components
│   └── styles/
└── dist/                 # built output (served by FiveM)
    └── index.html
```

Build: `cd ui && npm run build`

## Exports

| Export                | Description                                         |
| --------------------- | --------------------------------------------------- |
| `WriteRaceSession`    | Persist a completed race session to the database    |
| `WriteResult`         | Write an individual player race result              |
| `UpdateTrackRecord`   | Update the fastest lap record for a track           |
| `GetPersonalBest`     | Retrieve a player's personal best for a track       |
| `GetTrackRecords`     | Get all records for a specific track                |
| `GetAllTrackRecords`  | Get records across all tracks                       |
| `GetGlobalStandings`  | Fetch the current global standings table            |
| `GetClassStandings`   | Fetch standings filtered by vehicle class           |
| `GetPlayerStats`      | Get aggregate stats for a player                    |
| `GetPlayerHistory`    | Get recent race history for a player                |
| `GetLastSnapshot`     | Retrieve the most recent standings snapshot         |

## Dependencies
- spz-lib
- spz-core
- spz-identity
- spz-races
- spz-progression
- oxmysql

## CI
Built and released via `.github/workflows/release.yml` on push to `main`.
