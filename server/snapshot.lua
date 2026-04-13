local function GetNextSeasonNumber()
    local result = MySQL.Sync.fetchAll("SELECT MAX(season_num) as last_season FROM season_snapshots")
    local lastSeason = result[1] and result[1].last_season or 0
    return lastSeason + 1
end

AddEventHandler("SPZ:seasonSnapshot", function()
    local seasonNum = GetNextSeasonNumber()

    -- Capture top 100 standings for all license classes
    -- license_tier 0=C, 1=B, 2=A, 3=S
    local snapshotData = {
        season = seasonNum,
        date   = os.date("%Y-%m-%d"),
        standings = {
            C = GetClassStandings(0, 100),
            B = GetClassStandings(1, 100),
            A = GetClassStandings(2, 100),
            S = GetClassStandings(3, 100),
        }
    }

    MySQL.Sync.execute(
        "INSERT INTO season_snapshots (season_num, snapshot) VALUES (?, ?)",
        { seasonNum, json.encode(snapshotData) }
    )

    print(string.format("[spz-leaderboard] Season snapshot #%d written successfully.", seasonNum))
end)

function GetLastSnapshot()
    local result = MySQL.Sync.fetchAll(
        "SELECT snapshot FROM season_snapshots ORDER BY season_num DESC LIMIT 1"
    )
    
    if result[1] and result[1].snapshot then
        return json.decode(result[1].snapshot)
    end
    
    return nil
end

-- Exports
exports('GetLastSnapshot', GetLastSnapshot)
