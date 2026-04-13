function GetPersonalBest(source, track, carClass)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then return nil end

    local result = MySQL.Sync.fetchAll(
        [[SELECT best_time FROM track_records 
          WHERE track = ? AND car_class = ? AND player_id = ? 
          LIMIT 1]],
        { track, carClass, profile.id }
    )

    return result and result[1] and result[1].best_time or nil
end

function GetTrackRecords(track, carClass, limit)
    limit = limit or Config.DefaultRecordsLimit
    if limit > Config.MaxRecordsLimit then limit = Config.MaxRecordsLimit end
    
    local cacheKey = string.format("records:track:%s:%s:%s", track, carClass, limit)
    local cached = Cache.Get(cacheKey)
    if cached then return cached end

    local results = MySQL.Sync.fetchAll(
        [[SELECT tr.*, p.name as player_name, p.crew as crew_tag, p.rank
          FROM track_records tr
          JOIN players p ON tr.player_id = p.id
          WHERE tr.track = ? AND tr.car_class = ?
          ORDER BY tr.best_time ASC
          LIMIT ?]],
        { track, carClass, limit }
    )

    local formatted = {}
    for i, row in ipairs(results) do
        table.insert(formatted, {
            position    = i,
            player_name = row.player_name,
            crew_tag    = row.crew_tag,
            rank        = row.rank,
            best_time   = row.best_time,
            best_time_f = FormatTime(row.best_time),
            best_lap    = row.best_lap,
            best_lap_f  = row.best_lap and FormatTime(row.best_lap) or nil,
            set_at      = row.set_at
        })
    end

    Cache.Set(cacheKey, formatted, Config.RecordsCacheTTL)
    return formatted
end

function GetAllTrackRecords(carClass, limit)
    limit = limit or Config.DefaultRecordsLimit
    if limit > Config.MaxRecordsLimit then limit = Config.MaxRecordsLimit end
    
    local cacheKey = string.format("records:all:%s:%s", carClass, limit)
    local cached = Cache.Get(cacheKey)
    if cached then return cached end

    -- One row per track — the overall fastest time for that class
    local results = MySQL.Sync.fetchAll(
        [[SELECT tr.*, p.name as player_name, p.crew as crew_tag
          FROM track_records tr
          JOIN players p ON tr.player_id = p.id
          WHERE (tr.track, tr.best_time) IN (
              SELECT track, MIN(best_time)
              FROM track_records
              WHERE car_class = ?
              GROUP BY track
          )
          AND tr.car_class = ?
          ORDER BY tr.best_time ASC
          LIMIT ?]],
        { carClass, carClass, limit }
    )

    local formatted = {}
    for _, row in ipairs(results) do
        table.insert(formatted, {
            track       = row.track,
            track_type  = row.track_type,
            player_name = row.player_name,
            crew_tag    = row.crew_tag,
            best_time_f = FormatTime(row.best_time),
            set_at      = row.set_at
        })
    end

    Cache.Set(cacheKey, formatted, Config.RecordsCacheTTL)
    return formatted
end

-- Exports
exports('GetPersonalBest', GetPersonalBest)
exports('GetTrackRecords', GetTrackRecords)
exports('GetAllTrackRecords', GetAllTrackRecords)
