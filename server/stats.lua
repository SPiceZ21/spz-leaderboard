local function FormatHistoryRows(rows)
    local formatted = {}
    for _, row in ipairs(rows) do
        table.insert(formatted, {
            track          = row.track,
            track_type     = row.track_type,
            car_class      = row.car_class,
            position       = row.position,
            finish_time_f  = row.finish_time and FormatTime(row.finish_time) or "DNF",
            best_lap_f     = row.best_lap and FormatTime(row.best_lap) or nil,
            points_earned  = row.points_earned,
            sr_change      = row.sr_change,
            irating_change = row.irating_change,
            personal_best  = row.personal_best == 1,
            dnf            = row.dnf == 1,
            date           = row.created_at
        })
    end
    return formatted
end

local function GetPlayerStats(source)
    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then return nil end

    -- Aggregated stats from race_results
    local aggregation = MySQL.Sync.fetchAll(
        [[SELECT 
            COUNT(*) as total_races,
            SUM(CASE WHEN position = 1 THEN 1 ELSE 0 END) as wins,
            SUM(CASE WHEN position <= 3 THEN 1 ELSE 0 END) as top3,
            SUM(CASE WHEN dnf = 1 THEN 1 ELSE 0 END) as dnf_count,
            AVG(NULLIF(position, 99)) as avg_position
          FROM race_results 
          WHERE player_id = ?]],
        { profile.id }
    )

    local agg = aggregation[1] or {}
    local totalRaces = agg.total_races or 0
    local winRate = totalRaces > 0 and (agg.wins / totalRaces * 100) or 0

    -- Best times (Top 5 PBs)
    local pbs = MySQL.Sync.fetchAll(
        [[SELECT track, track_type as type, car_class as class, best_time
          FROM track_records 
          WHERE player_id = ?
          ORDER BY best_time ASC
          LIMIT 5]],
        { profile.id }
    )

    local bestTimes = {}
    for _, pb in ipairs(pbs) do
        table.insert(bestTimes, {
            track = pb.track,
            class = pb.class,
            time_f = FormatTime(pb.best_time),
            type = pb.type
        })
    end

    -- Recent form (last 10 races)
    local recent = MySQL.Sync.fetchAll(
        [[SELECT rs.track, rr.position, rr.points_earned, rr.finish_time
          FROM race_results rr
          JOIN race_sessions rs ON rs.race_id = rr.race_id
          WHERE rr.player_id = ?
          ORDER BY rr.created_at DESC
          LIMIT 10]],
        { profile.id }
    )

    local recentResults = {}
    for _, r in ipairs(recent) do
        table.insert(recentResults, {
            track = r.track,
            position = r.position,
            points = r.points_earned,
            time_f = r.finish_time and FormatTime(r.finish_time) or "DNF"
        })
    end

    -- Join with crew for tag
    local playerFull = MySQL.Sync.fetchAll(
        [[SELECT c.tag, p.rank_name FROM players p 
          LEFT JOIN crews c ON p.crew_id = c.id 
          WHERE p.id = ?]], 
        { profile.id }
    )
    local extra = playerFull[1] or {}

    return {
        player_name    = profile.name,
        rank           = profile.rank,
        rank_name      = extra.rank_name or profile.rank_name or "Racer", 
        license_tier   = profile.license_tier,
        xp             = profile.xp,
        class_points   = profile.class_points,
        alltime_points = profile.alltime_points,
        sr             = profile.sr,
        i_rating       = profile.i_rating,
        crew_tag       = extra.tag and ("[" .. extra.tag .. "]") or nil,

        total_races    = totalRaces,
        wins           = agg.wins or 0,
        top3           = agg.top3 or 0,
        dnf_count      = agg.dnf_count or 0,
        win_rate       = string.format("%.1f%%", winRate),
        avg_position   = agg.avg_position and tonumber(string.format("%.1f", agg.avg_position)) or 0,

        best_times     = bestTimes,
        recent_results = recentResults
    }
end

local function GetPlayerHistory(source, page, pageSize)
    pageSize = pageSize or Config.HistoryPageSize
    page     = page or 1
    local offset = (page - 1) * pageSize

    local profile = exports["spz-identity"]:GetProfile(source)
    if not profile then return nil end

    local rows = MySQL.Sync.fetchAll(
        [[SELECT
            rs.track, rs.track_type, rs.car_class, rs.laps,
            rr.position, rr.finish_time, rr.best_lap,
            rr.points_earned, rr.sr_change, rr.irating_change,
            rr.personal_best, rr.dnf, rr.dnf_reason,
            rr.created_at
          FROM race_results rr
          JOIN race_sessions rs ON rs.race_id = rr.race_id
          WHERE rr.player_id = ?
          ORDER BY rr.created_at DESC
          LIMIT ? OFFSET ?]],
        { profile.id, pageSize, offset }
    )

    local total = MySQL.Sync.fetchAll(
        "SELECT COUNT(*) AS n FROM race_results WHERE player_id = ?",
        { profile.id }
    )

    local count = total and total[1] and total[1].n or 0

    return {
        total   = count,
        page    = page,
        pages   = math.ceil(count / pageSize),
        results = FormatHistoryRows(rows),
    }
end

-- Exports
exports('GetPlayerStats', GetPlayerStats)
exports('GetPlayerHistory', GetPlayerHistory)
