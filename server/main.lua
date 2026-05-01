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

RegisterCommand('leaderboard', function(source)
    local standings = GetGlobalStandings(10)
    local tracks = GetTracks()
    local defaultTrack = tracks[1] and tracks[1].id or "Vespucci Sprints"
    local records = GetTrackRecords(defaultTrack, "S", 10)

    -- Map standings to UI format
    local points = {}
    for _, s in ipairs(standings) do
        table.insert(points, {
            rank = s.position,
            name = s.player_name,
            points = s.alltime_points,
            wins = 0, -- Needs to be added to DB/logic if required
            avatar = nil
        })
    end

    -- Map records to UI format
    local timetrial = {}
    for _, r in ipairs(records) do
        table.insert(timetrial, {
            rank = r.position,
            name = r.player_name,
            vehicle = "Vehicle", -- Should be in records if possible
            time = r.best_time_f,
            track = defaultTrack,
            avatar = nil
        })
    end

    TriggerClientEvent('SPZ:showLeaderboard', source, {
        points = points,
        timetrial = timetrial,
        tracks = tracks,
        defaultTab = 'points'
    })
end, false)

RegisterNetEvent('SPZ:leaderboard:request', function()
    local source = source
    print("[DEBUG] Leaderboard request received on server for source:", source)
    local standings = GetGlobalStandings(10)
    local tracks = GetTracks()
    local defaultTrack = tracks[1] and tracks[1].id or "Vespucci Sprints"
    local records = GetTrackRecords(defaultTrack, "S", 10)

    -- Map standings to UI format
    local points = {}
    for _, s in ipairs(standings) do
        table.insert(points, {
            rank = s.position,
            name = s.player_name,
            points = s.alltime_points,
            wins = 0,
            avatar = nil
        })
    end

    -- Map records to UI format
    local timetrial = {}
    for _, r in ipairs(records) do
        table.insert(timetrial, {
            rank = r.position,
            name = r.player_name,
            vehicle = "Vehicle",
            time = r.best_time_f,
            track = defaultTrack,
            avatar = nil
        })
    end

    TriggerClientEvent('SPZ:showLeaderboard', source, {
        points = points,
        timetrial = timetrial,
        tracks = tracks,
        defaultTab = 'points'
    })
end)
