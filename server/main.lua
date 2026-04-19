AddEventHandler("SPZ:raceEnd", function(results)
    -- Write session row
    WriteRaceSession(results)

    -- Write all player results in a single bulk INSERT
    local allPlayers = {}
    for _, f in ipairs(results.finishers) do table.insert(allPlayers, f) end
    for _, d in ipairs(results.dnf)       do table.insert(allPlayers, d) end
    BulkWriteResults(results.raceId, allPlayers)

    -- Track records (per-finisher, conditional — must stay separate)
    for _, finisher in ipairs(results.finishers) do
        UpdateTrackRecord(results.track, results.type, results.carClass, finisher)
    end

    -- Bust the query cache so next leaderboard fetch is fresh
    Cache.Bust("standings")
    Cache.Bust("records:" .. (results.track or ""))
end)

-- ── Callbacks ────────────────────────────────────────────────────────────

SPZ.Callbacks.Register("spz-leaderboard:getGlobalStandings", function(source, cb, data)
    cb(GetGlobalStandings(data.limit))
end)

SPZ.Callbacks.Register("spz-leaderboard:getClassStandings", function(source, cb, data)
    cb(GetClassStandings(data.tier, data.limit))
end)

SPZ.Callbacks.Register("spz-leaderboard:getTrackRecords", function(source, cb, data)
    cb(GetTrackRecords(data.track, data.carClass, data.limit))
end)

SPZ.Callbacks.Register("spz-leaderboard:getPlayerStats", function(source, cb, data)
    local target = data.source or source
    cb(GetPlayerStats(target))
end)

SPZ.Callbacks.Register("spz-leaderboard:getPlayerHistory", function(source, cb, data)
    cb(GetPlayerHistory(source, data.page, data.pageSize))
end)
