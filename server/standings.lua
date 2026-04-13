function GetGlobalStandings(limit)
    limit = limit or Config.DefaultStandingsLimit
    local cached = Cache.Get("standings:global:" .. limit)
    if cached then return cached end

    local results = MySQL.Sync.fetchAll(
        [[SELECT
            p.name         AS player_name,
            p.rank,
            p.license_tier,
            p.alltime_points,
            p.sr,
            p.i_rating,
            c.tag          AS crew_tag
        FROM players p
        LEFT JOIN crews c ON c.id = p.crew_id
        WHERE p.banned = 0
        ORDER BY p.alltime_points DESC
        LIMIT ?]],
        { limit }
    )

    local standings = {}
    for i, row in ipairs(results) do
        table.insert(standings, {
            position       = i,
            player_name    = row.player_name,
            crew_tag       = row.crew_tag and ("[" .. row.crew_tag .. "]") or nil,
            rank           = row.rank,
            license_tier   = row.license_tier,
            alltime_points = row.alltime_points,
            sr             = row.sr,
            i_rating       = row.i_rating,
        })
    end

    Cache.Set("standings:global:" .. limit, standings, Config.StandingsCacheTTL)
    return standings
end

function GetClassStandings(licenseTier, limit)
    limit = limit or Config.DefaultStandingsLimit
    local cached = Cache.Get("standings:class:" .. licenseTier .. ":" .. limit)
    if cached then return cached end

    local results = MySQL.Sync.fetchAll(
        [[SELECT
            p.name         AS player_name,
            p.rank,
            p.license_tier,
            p.class_points,
            p.alltime_points,
            p.sr,
            p.i_rating,
            c.tag          AS crew_tag
        FROM players p
        LEFT JOIN crews c ON c.id = p.crew_id
        WHERE p.license_tier = ? AND p.banned = 0
        ORDER BY p.class_points DESC
        LIMIT ?]],
        { licenseTier, limit }
    )

    local standings = {}
    for i, row in ipairs(results) do
        table.insert(standings, {
            position       = i,
            player_name    = row.player_name,
            crew_tag       = row.crew_tag and ("[" .. row.crew_tag .. "]") or nil,
            rank           = row.rank,
            license_tier   = row.license_tier,
            class_points   = row.class_points,
            alltime_points = row.alltime_points,
            sr             = row.sr,
            i_rating       = row.i_rating,
        })
    end

    Cache.Set("standings:class:" .. licenseTier .. ":" .. limit, standings, Config.StandingsCacheTTL)
    return standings
end

-- Exports
exports('GetGlobalStandings', GetGlobalStandings)
exports('GetClassStandings', GetClassStandings)
