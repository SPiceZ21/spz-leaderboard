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
    Cache.Bust("records:" .. results.track)
end)
