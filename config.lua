-- config.lua
Config = {}

-- ── Standings ────────────────────────────────────────────────────────────
Config.DefaultStandingsLimit = 25     -- default rows returned per standings query
Config.MaxStandingsLimit     = 100    -- hard cap on any single standings query

-- ── Track records ─────────────────────────────────────────────────────────
Config.DefaultRecordsLimit   = 15     -- top N times shown per track leaderboard
Config.MaxRecordsLimit       = 50

-- ── Player history ─────────────────────────────────────────────────────────
Config.HistoryPageSize       = 20     -- races per page in player history

-- ── Query cache ───────────────────────────────────────────────────────────
-- Results are cached in RAM to avoid hammering the DB on every NUI open.
-- Cache is busted automatically on SPZ:raceEnd.
Config.StandingsCacheTTL     = 30     -- seconds before standings cache expires
Config.RecordsCacheTTL       = 60     -- seconds before track records cache expires
Config.StatsCacheTTL         = 15     -- seconds before player stats cache expires

-- ── Season snapshots ──────────────────────────────────────────────────────
Config.KeepSnapshotCount     = 10     -- how many past seasons to keep in DB

-- ── Debug ─────────────────────────────────────────────────────────────────
Config.Debug                 = false
