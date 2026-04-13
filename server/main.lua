AddEventHandler("SPZ:raceEnd", function(results)
    -- Write session row
    WriteRaceSession(results)

    -- Write per-player results
    for _, finisher in ipairs(results.finishers) do
        WriteResult(results.raceId, finisher)
        UpdateTrackRecord(
            results.track,
            results.type,
            results.carClass,
            finisher
        )
    end

    -- DNF players still get a result row (no time, no points)
    for _, dnfPlayer in ipairs(results.dnf) do
        WriteResult(results.raceId, dnfPlayer)
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
