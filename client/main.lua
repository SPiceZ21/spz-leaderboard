-- SPZ Leaderboard Client
local isVisible = false

function SetLeaderboardVisible(visible, data)
    isVisible = visible
    SetNuiFocus(visible, visible)
    SendNUIMessage({
        action = visible and 'showLeaderboard' or 'hideLeaderboard',
        data = data
    })
end

RegisterNUICallback('close', function(data, cb)
    SetLeaderboardVisible(false)
    cb('ok')
end)

-- Test Command
RegisterCommand('testleaderboard', function()
    SetLeaderboardVisible(true, {
        defaultTab = "points",
        points = {
            { rank = 1, name = "SPiceZ", points = 1250, wins = 12 },
            { rank = 2, name = "User123", points = 1100, wins = 8 },
            { rank = 3, name = "RacerX", points = 950, wins = 5 }
        },
        timetrial = {
            { rank = 1, name = "SPiceZ", vehicle = "T20", time = "01:05.123", track = "track1" },
            { rank = 2, name = "User123", vehicle = "Zentorno", time = "01:06.456", track = "track1" },
            { rank = 3, name = "RacerX", vehicle = "Jester", time = "01:07.789", track = "track2" }
        },
        tracks = {
            { id = "track1", name = "Los Santos Circuit" },
            { id = "track2", name = "Vespucci Sprints" }
        }
    })
end, false)

-- Event listener for real data
RegisterNetEvent('SPZ:showLeaderboard', function(data)
    SetLeaderboardVisible(true, data)
end)
