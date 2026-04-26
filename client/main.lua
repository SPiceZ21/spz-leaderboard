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
        trackName = "Vespucci Sprints",
        entries = {
            { rank = 1, name = "SPiceZ", vehicle = "T20", time = "01:05.123", date = "2026-04-26" },
            { rank = 2, name = "User123", vehicle = "Zentorno", time = "01:06.456", date = "2026-04-26" },
            { rank = 3, name = "RacerX", vehicle = "Jester", time = "01:07.789", date = "2026-04-25" }
        }
    })
end, false)

-- Event listener for real data
RegisterNetEvent('SPZ:showLeaderboard', function(data)
    SetLeaderboardVisible(true, data)
end)
